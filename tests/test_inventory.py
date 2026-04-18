import io
import json
import sys
import unittest
from contextlib import redirect_stdout
from unittest.mock import MagicMock, patch

sys.path.insert(0, "ansible/inventory")
import terraform  # noqa: E402

MOCK_OUTPUTS = {
    "server_ip": {"value": {"fsn-web02": "1.2.3.4", "fsn-web03": "5.6.7.8"}},
    "fqdn": {"value": {"fsn-web02": "fsn-web02.example.com", "fsn-web03": "fsn-web03.example.com"}},
    "docker_app_dirs": {"value": {"fsn-web02": ["/opt/apps"], "fsn-web03": []}},
    "base_domain": {"value": "example.com"},
    "system_email_prefix": {"value": "fail2ban"},
    "smtp_host": {"value": "smtp.example.com"},
    "smtp_port": {"value": 587},
    "smtp_user": {"value": "user@example.com"},
    "smtp_password": {"value": "secret"},
    "smtp_from": {"value": "fail2ban@example.com"},
    "admin_email": {"value": "admin@example.com"},
    "admin_username": {"value": "admin"},
}


class TestInventory(unittest.TestCase):
    def _run_list(self):
        f = io.StringIO()
        with patch("sys.argv", ["terraform.py", "--list"]):
            with patch("terraform.subprocess.run") as mock_run:
                mock_run.return_value = MagicMock(stdout=json.dumps(MOCK_OUTPUTS))
                with redirect_stdout(f):
                    terraform.main()
        return json.loads(f.getvalue())

    def test_hosts_group_contains_all_servers(self):
        result = self._run_list()
        self.assertIn("fsn-web02", result["vps"]["hosts"])
        self.assertIn("fsn-web03", result["vps"]["hosts"])

    def test_each_host_has_correct_ip(self):
        result = self._run_list()
        hostvars = result["_meta"]["hostvars"]
        self.assertEqual(hostvars["fsn-web02"]["ansible_host"], "1.2.3.4")
        self.assertEqual(hostvars["fsn-web03"]["ansible_host"], "5.6.7.8")

    def test_each_host_has_correct_fqdn(self):
        result = self._run_list()
        hostvars = result["_meta"]["hostvars"]
        self.assertEqual(hostvars["fsn-web02"]["fqdn"], "fsn-web02.example.com")
        self.assertEqual(hostvars["fsn-web03"]["fqdn"], "fsn-web03.example.com")

    def test_each_host_has_correct_docker_app_dirs(self):
        result = self._run_list()
        hostvars = result["_meta"]["hostvars"]
        self.assertEqual(hostvars["fsn-web02"]["docker_app_dirs"], ["/opt/apps"])
        self.assertEqual(hostvars["fsn-web03"]["docker_app_dirs"], [])

    def test_shared_vars_applied_to_all_hosts(self):
        result = self._run_list()
        hostvars = result["_meta"]["hostvars"]
        for name in ("fsn-web02", "fsn-web03"):
            self.assertEqual(hostvars[name]["smtp_host"], "smtp.example.com")
            self.assertEqual(hostvars[name]["admin_username"], "admin")
            self.assertEqual(hostvars[name]["base_domain"], "example.com")


if __name__ == "__main__":
    unittest.main()
