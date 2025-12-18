@echo off
cd /d "%~dp0\..\modules\maintenance\lambda"
powershell -Command "Compress-Archive -Path index.py -DestinationPath maintenance_toggle.zip -Force"
echo Lambda package created: maintenance_toggle.zip
