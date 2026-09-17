import subprocess
import time
import sys
import os

os.chdir("f:/portfolia")

PORT = 8080

# 1. Start local HTTP server on port 8080
server_p = subprocess.Popen([sys.executable, "-m", "http.server", str(PORT)])
print(f"[SERVER] HTTP Server started successfully!")
print(f"[SERVER] Local Portfolio URL: http://localhost:{PORT}/")

# 2. Start SSH Tunnel to localhost.run with connect timeout
ssh_cmd = f"ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -R 80:localhost:{PORT} nokey@localhost.run"
tunnel_p = None
try:
    tunnel_p = subprocess.Popen(ssh_cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, shell=True)
    print("[TUNNEL] Public Tunnel process launched...")
except Exception as e:
    print(f"[TUNNEL] SSH Tunnel launch skipped or failed: {e}")

try:
    while True:
        if tunnel_p and tunnel_p.stdout:
            line = tunnel_p.stdout.readline()
            if line:
                print("[TUNNEL LOG]:", line.strip())
        time.sleep(0.1)
except KeyboardInterrupt:
    print("\n[SERVER] Shutting down...")
    server_p.terminate()
    if tunnel_p:
        tunnel_p.terminate()

