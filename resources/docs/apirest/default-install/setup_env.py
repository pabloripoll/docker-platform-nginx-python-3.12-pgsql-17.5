import subprocess

# Create venv
subprocess.run(["python3", "-m", "venv", "/var/www/venv"], check=True)

# Activate venv and install requirements
subprocess.run(["/var/www/venv/bin/pip", "install", "--no-cache-dir", "-r", "requirements.txt"], check=True)
