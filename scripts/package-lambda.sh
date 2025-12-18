#!/bin/bash
cd "$(dirname "$0")/../modules/maintenance/lambda"
zip -r maintenance_toggle.zip index.py
echo "Lambda package created: maintenance_toggle.zip"
