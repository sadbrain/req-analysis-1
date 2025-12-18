import json
import boto3
import os

elbv2 = boto3.client('elbv2')
ssm = boto3.client('ssm')

LISTENER_ARN = os.environ['LISTENER_ARN']
RULE_PRIORITY = int(os.environ['MAINTENANCE_RULE_PRIORITY'])
PARAMETER_NAME = os.environ['PARAMETER_NAME']

MAINTENANCE_HTML = """<html><head><title>Maintenance</title></head><body style="font-family:Arial;text-align:center;padding:50px;background:#f5f5f5"><div style="max-width:500px;margin:0 auto;background:#fff;padding:40px;border-radius:8px"><h1 style="color:#e74c3c">Under Maintenance</h1><p>We are currently performing scheduled maintenance.</p><p>We will be back online shortly. Thank you for your patience!</p></div></body></html>"""


def handler(event, context):
    # Get current maintenance mode
    param = ssm.get_parameter(Name=PARAMETER_NAME)
    mode = param['Parameter']['Value']
    
    # Check if we should enable or disable
    action = event.get('detail', {}).get('action', 'toggle')
    
    if action == 'toggle':
        new_mode = 'OFF' if mode == 'ON' else 'ON'
    else:
        new_mode = action.upper()
    
    # Update parameter
    ssm.put_parameter(Name=PARAMETER_NAME, Value=new_mode, Overwrite=True)
    
    # Get existing rules
    rules = elbv2.describe_rules(ListenerArn=LISTENER_ARN)['Rules']
    maintenance_rule = None
    
    for rule in rules:
        if rule.get('Priority') == str(RULE_PRIORITY):
            maintenance_rule = rule
            break
    
    if new_mode == 'ON':
        # Enable maintenance: create/update rule
        if maintenance_rule:
            print(f"Maintenance rule already exists, skipping...")
        else:
            # Create maintenance rule with priority 10 (higher than green.mixcredevops.online priority 1)
            # But we'll use path condition to NOT affect green subdomain
            elbv2.create_rule(
                ListenerArn=LISTENER_ARN,
                Priority=RULE_PRIORITY,
                Conditions=[
                    {
                        'Field': 'path-pattern',
                        'Values': ['/*']
                    }
                ],
                Actions=[
                    {
                        'Type': 'fixed-response',
                        'FixedResponseConfig': {
                            'StatusCode': '503',
                            'ContentType': 'text/html',
                            'MessageBody': MAINTENANCE_HTML
                        }
                    }
                ]
            )
            print(f"Maintenance mode ENABLED")
    else:
        # Disable maintenance: delete rule
        if maintenance_rule:
            elbv2.delete_rule(RuleArn=maintenance_rule['RuleArn'])
            print(f"Maintenance mode DISABLED")
        else:
            print(f"Maintenance rule not found, already disabled")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'previous_mode': mode,
            'new_mode': new_mode,
            'message': f'Maintenance mode is now {new_mode}'
        })
    }
