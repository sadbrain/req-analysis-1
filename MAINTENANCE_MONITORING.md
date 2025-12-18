# ============================================================================
# MAINTENANCE MODE - MONITORING GUIDE
# ============================================================================

## 1. Theo dõi qua Makefile Commands

### Gửi event và kiểm tra
```powershell
# Bật maintenance
make maintenance-on ENV=dev

# Xem logs Lambda ngay lập tức (follow mode)
make maintenance-logs ENV=dev

# Xem logs 5 phút gần nhất
make maintenance-logs-recent ENV=dev

# Check trạng thái hiện tại
make maintenance-status ENV=dev

# Xem ALB listener rules
make maintenance-check-rules ENV=dev
```

### Manual test Lambda (bypass EventBridge)
```powershell
make maintenance-invoke-lambda ENV=dev
```

## 2. Theo dõi trên AWS Console

### A. Kiểm tra EventBridge Event đã gửi chưa

**Cách 1: CloudWatch Logs Insights**
1. Console → CloudWatch → Logs Insights
2. Select log group: `/aws/events/rule/req-analysis-1-dev-maintenance-toggle`
3. Query:
```
fields @timestamp, @message
| filter @message like /custom.maintenance/
| sort @timestamp desc
| limit 20
```
4. Run query → Xem events đã gửi

**Cách 2: EventBridge Console**
1. Console → EventBridge → Rules
2. Tìm rule: `req-analysis-1-dev-maintenance-toggle`
3. Click vào rule → Tab "Monitoring"
4. Xem metrics: Invocations, FailedInvocations

### B. Xem Lambda Logs

**Cách 1: CloudWatch Logs (Recommended)**
1. Console → CloudWatch → Log groups
2. Tìm: `/aws/lambda/req-analysis-1-dev-maintenance-toggle`
3. Click vào log stream mới nhất
4. Xem logs:
```
START RequestId: xxx
[INFO] Current mode: OFF
[INFO] Maintenance rule already exists, skipping...
[INFO] Maintenance mode ENABLED
END RequestId: xxx
REPORT RequestId: xxx Duration: 234ms Memory: 128MB
```

**Cách 2: Lambda Console**
1. Console → Lambda → Functions
2. Tìm: `req-analysis-1-dev-maintenance-toggle`
3. Tab "Monitor" → "Logs" → "View CloudWatch logs"
4. Hoặc tab "Monitor" → "View metrics in CloudWatch"

**Cách 3: CLI (Real-time)**
```powershell
aws logs tail /aws/lambda/req-analysis-1-dev-maintenance-toggle --follow
```

### C. Verify Maintenance Mode hoạt động

**1. Check SSM Parameter**
```powershell
# CLI
aws ssm get-parameter --name "/req-analysis-1/dev/maintenance-mode"

# Console
Console → Systems Manager → Parameter Store
→ Tìm: /req-analysis-1/dev/maintenance-mode
→ Xem Value: ON hoặc OFF
```

**2. Check ALB Listener Rules**
```powershell
# CLI
aws elbv2 describe-rules --listener-arn <ALB_LISTENER_ARN>

# Console
Console → EC2 → Load Balancers
→ Chọn ALB req-analysis-1-dev-internal-alb
→ Tab "Listeners and rules"
→ Click listener port 80
→ Xem rules:
   - Priority 1: green.mixcredevops.online
   - Priority 10: /* (Maintenance - chỉ có khi ON)
   - Default: forward to FE
```

**3. Test thực tế**
```powershell
# Test maintenance page
curl https://d15qrqs46w2yc8.cloudfront.net
# Kỳ vọng: 503 với HTML maintenance page

# Test green vẫn hoạt động
curl https://green.mixcredevops.online
# Kỳ vọng: 200 OK
```

### D. Troubleshooting

**Lambda không chạy?**
```powershell
# 1. Check Lambda có permission không
aws lambda get-policy --function-name req-analysis-1-dev-maintenance-toggle

# 2. Check EventBridge rule có active không
aws events describe-rule --name req-analysis-1-dev-maintenance-toggle

# 3. Manual invoke để test
aws lambda invoke --function-name req-analysis-1-dev-maintenance-toggle \
  --payload '{"detail":{"action":"ON"}}' \
  response.json && cat response.json
```

**Event không trigger Lambda?**
```powershell
# 1. Check event pattern
aws events describe-rule --name req-analysis-1-dev-maintenance-toggle \
  --query 'EventPattern' --output text

# 2. Test event pattern
aws events test-event-pattern \
  --event-pattern '{"source":["custom.maintenance"],"detail-type":["Maintenance Toggle"]}' \
  --event '{"source":"custom.maintenance","detail-type":"Maintenance Toggle","detail":{"action":"ON"}}'

# Output: true nếu match
```

**Lambda error?**
```powershell
# Xem error gần nhất
aws logs tail /aws/lambda/req-analysis-1-dev-maintenance-toggle --since 1h \
  --filter-pattern "ERROR"
```

## 3. CloudWatch Metrics Dashboard

Tạo dashboard để theo dõi:

**Lambda Metrics:**
- Invocations (số lần chạy)
- Errors (số lỗi)
- Duration (thời gian chạy)
- Throttles (bị rate limit)

**ALB Metrics:**
- HTTPCode_Target_5XX_Count (maintenance trả 503)
- RequestCount (tổng requests)

**Tạo dashboard:**
```powershell
# Console → CloudWatch → Dashboards → Create dashboard
# Add widgets:
#   - Lambda: req-analysis-1-dev-maintenance-toggle
#   - ALB: req-analysis-1-dev-internal-alb
```

## 4. Quick Debug Checklist

```bash
✓ Event đã gửi?        → make maintenance-logs-recent
✓ Lambda đã chạy?       → make maintenance-logs
✓ SSM Parameter đúng?   → make maintenance-status
✓ ALB rule đã tạo?      → make maintenance-check-rules
✓ Maintenance page ok?  → curl CloudFront URL
✓ Green vẫn hoạt động?  → curl green.mixcredevops.online
```

## 5. Log Messages cần chú ý

**Success:**
```
[INFO] Maintenance mode ENABLED
[INFO] Maintenance mode DISABLED
```

**Already in desired state:**
```
[INFO] Maintenance rule already exists, skipping...
[INFO] Maintenance rule not found, already disabled
```

**Errors:**
```
[ERROR] Failed to create rule: <reason>
[ERROR] Access denied: <permission issue>
```
