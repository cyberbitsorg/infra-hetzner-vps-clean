#!/usr/bin/env python3
"""
Dynamic inventory from Terraform state.
Run: ./terraform.py --list
"""
import json
import os
import subprocess
import sys


def get_terraform_output():
    try:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        repo_root = os.path.dirname(os.path.dirname(script_dir))

        result = subprocess.run(
            ["tofu", "output", "-json"],
            capture_output=True,
            text=True,
            cwd=repo_root
        )
        return json.loads(result.stdout)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    if len(sys.argv) == 2 and sys.argv[1] == "--list":
        outputs = get_terraform_output()

        server_ips = outputs.get("server_ip", {}).get("value", {})
        fqdns = outputs.get("fqdn", {}).get("value", {})
        docker_app_dirs_map = outputs.get("docker_app_dirs", {}).get("value", {})
        base_domain = outputs.get("base_domain", {}).get("value", "example.com")
        system_email_prefix = outputs.get("system_email_prefix", {}).get("value", "fail2ban")
        smtp_host = outputs.get("smtp_host", {}).get("value", "")
        smtp_port = outputs.get("smtp_port", {}).get("value", 587)
        smtp_user = outputs.get("smtp_user", {}).get("value", "")
        smtp_password = outputs.get("smtp_password", {}).get("value", "")
        smtp_from = outputs.get("smtp_from", {}).get("value", f"{system_email_prefix}@{base_domain}")
        admin_email = outputs.get("admin_email", {}).get("value", "admin@example.com")
        admin_username = outputs.get("admin_username", {}).get("value", "admin")

        hostvars = {}
        for name, ip in server_ips.items():
            hostvars[name] = {
                "ansible_host": ip,
                "ansible_user": "deployacc",
                "ansible_ssh_private_key_file": "~/.ssh/id_ed25519",
                "fqdn": fqdns.get(name, ""),
                "base_domain": base_domain,
                "system_email_prefix": system_email_prefix,
                "smtp_host": smtp_host,
                "smtp_port": smtp_port,
                "smtp_user": smtp_user,
                "smtp_password": smtp_password,
                "smtp_from": smtp_from,
                "admin_email": admin_email,
                "admin_username": admin_username,
                "docker_app_dirs": docker_app_dirs_map.get(name, []),
            }

        inventory = {
            "vps": {
                "hosts": list(server_ips.keys())
            },
            "_meta": {
                "hostvars": hostvars
            }
        }
        print(json.dumps(inventory, indent=2))
    elif len(sys.argv) == 3 and sys.argv[1] == "--host":
        print(json.dumps({}))
    else:
        print("Usage: --list or --host <hostname>")
        sys.exit(1)


if __name__ == "__main__":
    main()
