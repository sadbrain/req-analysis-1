# DEVOPS-WEBSITE-STUDY (Terraform)

## ⚠️ Recent Fixes (Dec 2025)

**Issues Fixed**:
- ✅ ECS tasks không thể chạy được do thiếu internet connectivity
- ✅ NAT instances không forward traffic về ECS properly
- ✅ Security group configuration không đúng

**Quick Start**: Xem [QUICK_FIX.md](QUICK_FIX.md)  
**Detailed Guide**: Xem [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md)  
**Troubleshooting**: Xem [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────┬────────────────────────────────┬────────────────┘
                 │                                │
                 │ (user traffic)                 │ (NAT traffic)
                 ▼                                ▼
         ┌───────────────┐              ┌──────────────────┐
         │  Internet     │              │   Internet       │
         │  Gateway      │              │   Gateway        │
         └───────┬───────┘              └────────┬─────────┘
                 │                               │
    ┌────────────┴────────────┐         ┌────────┴──────────┐
    │                         │         │                   │
    │  Public Subnet AZ-1     │         │ Public Subnet     │
    │  ┌──────────────┐       │         │ AZ-2              │
    │  │    ALB       │       │         │ ┌──────────────┐  │
    │  └──────┬───────┘       │         │ │  NAT-1       │  │
    │         │               │         │ │  Instance    │  │
    │         │               │         │ └──────┬───────┘  │
    │  ┌──────────────┐       │         │ ┌──────────────┐  │
    │  │  NAT-0       │       │         │ │  NAT-2       │  │
    │  │  Instance    │       │         │ │  Instance    │  │
    │  └──────┬───────┘       │         │ └──────┬───────┘  │
    └─────────┼───────────────┘         └────────┼──────────┘
              │                                  │
              │ (forward/return)                 │
    ┌─────────┼──────────────────────────────────┼──────────┐
    │         │                                  │          │
    │         │  Private App Subnet AZ-1         │          │
    │         │  ┌─────────────────┐             │          │
    │         └─►│  ECS Instance   │◄────────────┘          │
    │            │  ┌───────────┐  │                        │
    │            │  │ FE Task   │  │                        │
    │            │  └───────────┘  │                        │
    │            └─────────┬───────┘                        │
    │                      │                                │
    │            Private App Subnet AZ-2                    │
    │            ┌─────────────────┐                        │
    │            │  ECS Instance   │                        │
    │            │  ┌───────────┐  │                        │
    │            │  │ BE Task   │  │                        │
    │            │  └─────┬─────┘  │                        │
    │            └────────┼────────┘                        │
    │                     │                                 │
    │  Private DB Subnet  │                                 │
    │  ┌──────────────────▼──┐                              │
    │  │                     │                              │
    │  │   RDS MySQL         │                              │
    │  │                     │                              │
    │  └─────────────────────┘                              │
    └───────────────────────────────────────────────────────┘

KEY SECURITY GROUP RULES (Fixed):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ALB → ECS: ports 80, 8080
✅ ECS → RDS: port 3306
✅ NAT → ECS: all (CRITICAL FIX - allows return traffic)
✅ ECS → NAT: all egress
✅ NAT → Internet: all egress
```

## Network Flow

### Flow 1: User Access (Working)
```
User → ALB (public) → ECS Tasks (private) → RDS (private)
```

### Flow 2: ECS Internet Access (FIXED)
```
ECS Task → NAT Instance → Internet → NAT Instance → ECS Task
                                                      ↑
                                    ✅ FIXED: Allow NAT SG → ECS SG
```

## Infrastructure Components

### VPC Module (6 Subnets)
- **2 Public Subnets**: ALB + NAT instances
- **2 Private App Subnets**: ECS instances + Tasks
- **2 Private DB Subnets**: RDS instances

### ECS on EC2
- Launch Type: EC2
- Network Mode: awsvpc
- Auto Scaling Group with capacity provider
- Services: FE (port 80), BE (port 8080)

### NAT Instances (Fixed)
- Amazon Linux 2023
- IP forwarding enabled
- iptables MASQUERADE
- **NEW**: Persistent iptables rules
- **NEW**: Better logging

### ALB
- Application Load Balancer
- 2 Target Groups (FE + BE)
- Health checks enabled

### RDS
- MySQL instance
- Private subnets only
- Accessed by ECS tasks only

## Deployment

### Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- AWS credentials with appropriate permissions

### Deploy
```bash
# Initialize
terraform init -backend-config=env/dev/backend.hcl

# Plan
terraform plan \
  -var-file=env/dev/commons.tfvars \
  -var-file=env/dev/vpcs.tfvars \
  -var-file=env/dev/nat.tfvars \
  -var-file=env/dev/alb.tfvars \
  -var-file=env/dev/ecs.tfvars \
  -var-file=env/dev/rds.tfvars

# Apply
terraform apply \
  -var-file=env/dev/commons.tfvars \
  -var-file=env/dev/vpcs.tfvars \
  -var-file=env/dev/nat.tfvars \
  -var-file=env/dev/alb.tfvars \
  -var-file=env/dev/ecs.tfvars \
  -var-file=env/dev/rds.tfvars
```

### Verify Deployment
```bash
# Check cluster
aws ecs describe-clusters --clusters <cluster-name>

# Check services
aws ecs list-services --cluster <cluster-name>

# Check tasks
aws ecs list-tasks --cluster <cluster-name>

# Get ALB DNS
terraform output alb_dns_name
```

## Files Structure

```
├── *-main.tf              # Resource definitions
├── *-variables.tf         # Variable declarations
├── *-outputs.tf          # Output definitions
├── locals.tf             # Local values
├── backend.tf            # Backend configuration
├── providers.tf          # Provider configuration
├── versions.tf           # Version constraints
├── env/
│   └── dev/
│       ├── *.tfvars      # Environment-specific values
│       └── backend.hcl   # Backend config
├── modules/
│   └── vpc-6subnets/     # Custom VPC module
├── QUICK_FIX.md          # Quick reference for recent fixes
├── CHANGES_SUMMARY.md    # Detailed changes explanation
└── TROUBLESHOOTING.md    # Debugging guide
```

## Recent Changes (Dec 2025)

### Security Groups
- ✅ Added NAT → ECS ingress rule (critical for internet access)
- ✅ Reordered resources to avoid circular dependency

### NAT Instances
- ✅ Persistent iptables rules with `iptables-services`
- ✅ Enhanced logging to `/var/log/user-data.log`
- ✅ Better error handling

### ECS Configuration  
- ✅ Enable IAM roles for tasks
- ✅ Configure awslogs driver
- ✅ Enable detailed monitoring
- ✅ Better logging in user-data

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for:
- Common issues and solutions
- Debugging commands
- Verification steps
- Network flow diagrams

## Support

For issues or questions about this infrastructure:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review [CHANGES_SUMMARY.md](CHANGES_SUMMARY.md)
3. Check CloudWatch Logs: `/ecs/<cluster-name>`
4. Review ECS service events

## License

[Your License]
