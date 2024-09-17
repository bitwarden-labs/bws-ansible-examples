# bws-ansible-examples

A repository giving example use-cases for the Bitwarden Secrets Manager Ansible Integration

## certbot-nginx-vikunja

This repository stands up an example of Vikunja, an excellent open-source project management tool (<https://vikunja.io/>).
This example features Vikunja run in Docker, with a simple nginx reverse proxy installed on the host OS.
Certificates are managed by Certbot, and a Cloudflare plugin is used to set and remove DNS records.

## Instructions and Usage

Detailed Instructions are found in the certbot-nginx-vikunja.md file.

## Instructions

- run commands using the following:

`ansible-playbook ./datto-ssd/vms/certbot/playbooks/main.yml -e@<(echo "ansible_sudo_pass: $(bws secret get '019df44c-9be6-4946-a687-b12500b10690' | jq -r '.value')")`

The -e flag creates a sub-shell, which looks up the sudo password for the user from bws, and then passes this into the ansible playbook, allowing for non-interactive sudo usage.

This is equivalent to running the -k flag in interactive mode.
