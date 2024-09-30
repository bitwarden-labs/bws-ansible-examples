# bws-ansible-examples

A repository giving example use-cases for the Bitwarden Secrets Manager Ansible Integration.  Each directory contains a self-contained Ansible Role.

## demonstration-playbook

This role gives simple demonstrations of how to interact with Secrets retrieved from BWS in a variety of ways, including:

- injecting them directly into playbooks
- injecting them into files on a target system
- constructing dictionaries which can be used for more extensive control of secrets via Jinja2 templating

The role runs on localhost, so should be very simple to get started with!  Detailed instructions are found in the [README-demonstration.md](demonstration-playbook/README-demonstration.md) file.

## certbot-nginx-vikunja

This role stands up an example of Vikunja, an excellent open-source project management tool (<https://vikunja.io/>).
This example features Vikunja run in Docker, with a simple nginx reverse proxy installed on the host OS.
Certificates are managed by Certbot, and a Cloudflare plugin is used to set and remove DNS records.

While this role is more complicated and features several dependancies, it showcases how Bitwarden Secrets Manager can serve a more realistic usecase in securing a simple deployment.

### Instructions and Usage

Detailed Instructions are found in the [README-certbot-nginx-vikunja.md](certbot-nginx-vikunja/README-certbot-nginx-vikunja.md) file.

## General Tips & Tricks

### Retrieving secrets from BWS using a sub-shell:

It can be useful to retrieve secrets from BWS via a subshell:

https://sysxplore.com/subshells-in-bash/

Example syntax for this is found below, setting the 'e' flag of ansible (environmental variable) to the `sudo password` of the remote user, which is obtained securely at runtime via a sub-shell call to bws:

`ansible-playbook ./datto-ssd/vms/certbot/playbooks/main.yml -e@<(echo "ansible_sudo_pass: $(bws secret get '019df44c-9be6-4946-a687-b12500b10690' | jq -r '.value')")`

The -e flag creates a sub-shell, which looks up the sudo password for the user from bws, and then passes this into the ansible playbook, allowing for non-interactive sudo usage.

The output is equivalent to running via the the -k flag in interactive mode, but doing so in this method allow for secure, non-interactive runs, which be extremely granular depending on the scope Access Key being used by the subshell.
