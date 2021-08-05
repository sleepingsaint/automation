#! /usr/bin/python3

# this script helps to change the installation directory
# for docker images by configuring the /etc/docker/daemon.json
import json
import argparse
import subprocess

def getDockerRootDir():
	proc = subprocess.run(["docker", "info", "--format", "'{{json .}}'"], stdout=subprocess.PIPE)
	data = json.loads(proc.stdout.decode('utf-8')[1:-2])
	return data["DockerRootDir"]
	
def changeDir(config, dir):
	try:
		with open(config, 'r') as f:
			print("[step 1]: Loading the config file...")
			conf = json.load(f)
		
		with open(config, 'w') as f:
			print("[step 2]: Updating the config file...")
			conf['data-root'] = dir
			json.dump(conf, f, indent=4)

		print("[step 3]: Restarting the docker daemon...")
		subprocess.run(["systemctl", "restart", "docker"])
		
		print("[step 4]: Getting the updated installation path")
		dir = getDockerRootDir()

		print(f"[SUCCESS]: Docker installation changed to {dir}")
	except PermissionError:
		print("[ERROR]: You don't have sufficient permissions to perform this operation. Please try again with sudo!")
	except FileNotFoundError:
		print("[ERROR]: Config file not found")

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='Helper script to change Docker installation directory')
	parser.add_argument("--config", "-c", type=str, help="path to the config file", default="/etc/docker/daemon.json")
	parser.add_argument("--dir", "-d", type=str, help="path to the new directory", default="")
	args = parser.parse_args()
	
	changeDir(args.config, args.dir)