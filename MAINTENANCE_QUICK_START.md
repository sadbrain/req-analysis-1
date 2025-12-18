# Maintenance Mode Monitoring

Xem chi tiết: [MAINTENANCE_MONITORING.md](MAINTENANCE_MONITORING.md)

## Quick Commands

```powershell
# Bật maintenance
make maintenance-on ENV=dev

# Xem logs realtime
make maintenance-logs ENV=dev

# Check status
make maintenance-status ENV=dev

# Xem ALB rules
make maintenance-check-rules ENV=dev

# Tắt maintenance
make maintenance-off ENV=dev
```

## AWS Console Locations

**Lambda Logs:**
CloudWatch → Log groups → `/aws/lambda/req-analysis-1-dev-maintenance-toggle`

**SSM Parameter:**
Systems Manager → Parameter Store → `/req-analysis-1/dev/maintenance-mode`

**ALB Rules:**
EC2 → Load Balancers → req-analysis-1-dev-internal-alb → Listeners → Port 80

**EventBridge:**
EventBridge → Rules → req-analysis-1-dev-maintenance-toggle
