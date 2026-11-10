#!/usr/bin/env python3
import os
import yaml

config_dir = "/octoprint/octoprint"
config_path = os.path.join(config_dir, "config.yaml")

os.makedirs(config_dir, exist_ok=True)

data = {}
if os.path.isfile(config_path):
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}
    except Exception as e:
        print(f"[setup-config] Warning: Failed to parse {config_path}: {e}")
        data = {}

server = data.setdefault("server", {})
commands = server.setdefault("commands", {})

# Configure restart command if not already set or if still pointing to legacy s6
current_restart = commands.get("serverRestartCommand")
if not current_restart or "s6-svc" in str(current_restart):
    print("[setup-config] Setting serverRestartCommand = 'restart-octoprint'")
    commands["serverRestartCommand"] = "restart-octoprint"
    try:
        with open(config_path, "w", encoding="utf-8") as f:
            yaml.safe_dump(data, f, default_flow_style=False)
        print("[setup-config] config.yaml successfully updated.")
    except Exception as e:
        print(f"[setup-config] Error saving config.yaml: {e}")
else:
    print(f"[setup-config] serverRestartCommand already configured: {current_restart}")
