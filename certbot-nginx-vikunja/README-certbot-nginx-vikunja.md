# Introduction

This project uses Ansible to manage an example implementation of Vikunja, an open-source project management tool (<https://vikunja.io/>), hosted behind an nginx reverse proxy.  Certificates are managed via Cloudflare & Certbot.  Secret management is performed by Bitwarden Secrets Manager.

In addition to being directly useful to existing Vikunja users, it is hoped that this will serve as a useful starting point for anybody wishing to integrate Bitwarden Secrets Manager into their own Ansible playbooks and deployments.

## Usage Instructions

- Install ansible, including the Bitwarden SM SDK and the necessary modules from ansible galaxy:

  - git clone <https://github.com/bitwarden-labs/bws-ansible-examples.git>
  - cd bws-ansible-examples
  - python3 -m venv ./venv (creates a Python virtual environment to work in)
  - source ./venv/bin/activate (actives the virtual environment.  Use 'deactivate' to return to your normal namespace)
  - python3 -m pip install ansible bitwarden-sdk
  - ansible-galaxy collection install community.docker bitwarden.secrets
  - export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES  (for macOS only)

- Configure the ansible role:
  - Set your domains and subdomains in `/inventory/group_vars`
  - Enter the IPs and SSH keys for 2x servers in `/inventory/host_vars` (example terraform is provided for DigitalOcean)

- Configure the machine to access Bitwarden Secrets Manager
  - Import the example BWS Projects to your BWSM vault from `/bws-vault/bws-vault-export.json`
  - Create a Machine Account for the Ansible Host and give it access to the 2 Projects imported in the step above (<https://bitwarden.com/help/machine-accounts/>)
  - Create an Access Token for the Ansible Host and set it as an environmental variable (<https://bitwarden.com/help/access-tokens/>)

- Optional Steps
  - Configure a domain with Cloudflare and set an API Token (<https://developers.cloudflare.com/fundamentals/api/get-started/create-token/>)
  - Edit the secrets created in Bitwarden Secrets Manager to reflect your SMTP and Cloudflare credentials

- Launch!
  - Comment out any roles that you are not ready to use (See TLDR below)
  - from the certbot-nginx-vikunja directory, run ___'ansible-playbook site.yml -i ./inventory/vikunja.yml -e "deployment_env=qa"'___ or ___'ansible-playbook site.yml -i ./inventory/vikunja.yml -e "deployment_env=production"'___ to start the playbooks

### TLDR - I just want to see some code running!

The quickest adaptations to these playbooks to just get the project running and view Bitwarden Secrets Manager in action is to comment out the cloudflare, certbot and nginx playbooks under `roles` in site.yml.  At this point, Vikunja will be exposed on (your-server-ip):3456 over http, but will still make use of the secrets set (SMTP / database) in the Vikunja role.  This allows you not to worry about DNS or HTTPS.  Secrets to configure an SMTP service is also optional - the app will load fine without them.

### I don't use Cloudflare / Ubuntu / Vikunja...

Feel free to use the project as a base for your own work!  Examples could include swapping out DNS management from Cloudflare to another Certbot supported provider (<https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins>), swapping the example app from Vikunja to something else, swapping the base-OS from Ubuntu to RHEL...  the modular nature of ansible should make using this project as a base for your own IaC deployments straightforward.

---

## Secrets management

### An overview of Secrets management in ansible

Ansible allows for the use of Jinja2 templating, in order to evaluate variables dynamically at runtime (<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_templating.html>).  This project uses Jinja2 templating to retrieve secrets from Bitwarden Secrets Manager, allowing for the use of loops to set multiple secrets in a single play.

There are countless other ways to manage secrets in ansible, and the Bitwarden Integration Team would welcome examples of other methods that users have found useful.

### Secrets used in this Project

#### Cloudflare

Cloudflare offers an API, allowing for management of DNS records (<https://developers.cloudflare.com/api/>).  Authentication to the API can arranged via either an API Key, or API Tokens.  API Tokens can be granularly scoped, allowing for use of the Principal of Least Privilege.  This project obtains an API Token (or one per deployment environment!) from Bitwarden Secrets Manager, and uses this to set and delete Cloudflare managed DNS records.

#### Vikunja

##### Database Credentials

Vikunja stores data in a database, the options for which are detailed here (<https://vikunja.io/docs/config-options#database>).  This project uses a combination of the `ansible-core` `set_fact module` (<https://docs.ansible.com/ansible/latest/collections/ansible/builtin/set_fact_module.html>) and lookups from the Bitwarden Secrets Manager ansible plugin to dynamically retrieve secrets at runtime, and inject them into the configuration used by Vikunja.

##### SMTP Credentials

Vikunja allows for alerts and notifications to be sent via SMTP.  4x SMTP credentials are retrieved from Bitwarden Secrets Manager, stored as a dictionary in ansible, and then injected into the configuration files on the host-machine at runtime.

---

## Project Folder Documentation

### Supporting Configuration Files

The project folder contains a few files and folders not directly related to the example ansible role.  These are described below.

#### .config

This folder contains ansible-lint rules, that override a couple of linting warnings for users of ansible lint (<https://ansible.readthedocs.io/projects/lint/>).  Feel free to set these to your taste - they will not impact the running of the project.

#### terraform

Example terraform code is provided that will use DigitalOcean to create two VMs with public IPv4s, and tag each of them according to environment (i.e., 'qa' and 'production')

While dynamic inventory management and automatic launching of ansible playbooks following infrastucture provisioning via Terraform are both possible, they fall outside the current scope of this project and are left to the user to implement.

---

### Ansible Role and Playbook folders

The majority of the code supplied comprises ansible playbooks, which are expected to be run via site.yml.  This structure is described as a Role in ansible (<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html>).

If you do not wish to run certain playbooks, for example because you wish to set DNS manually instead of via Cloudflare, simply comment them out (or delete them) from the roles list in site.yml

Each sub-directory then contains an invididual playbook, along with all its required pre-requisites and configuration.  An overview of the purpose of each is given below.

---

#### Ansible Playbooks

##### certbot

This playbook installs certbot (<https://certbot.eff.org/>) using snap, along with the Cloudflare DNS plugin, which allows certbot to interact with DNS records on Cloudflare via an API key or token (<https://certbot-dns-cloudflare.readthedocs.io/en/stable/>).

Once certbot is installed, it copies a script onto the host machine to obtain an HTTPS certificate for the configured domain, and then obtains the Cloudflare API token stored in Bitwarden Secrets Manager and injects this into the script before running it.

This role also conifgures certificate renewal via the certbot timer systemd service.

##### cloudflare

This playbook checks the public IPv4 of the host, and then uses this to create a DNS record matching that IP via Cloudflare.

There is a commented-out play that will also delete the record, useful for tidying up.  Currently this should be uncommented to run, but it could also be used dependent on ansible playbook conditionals:
<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html>

This playbook uses the same Cloudflare token as the certbot playbook.  No Bitwarden Secrets Manager lookup is required in this playbook, as the variable has already been set by the certbot playbook.

##### debug

The debug module contains examples of how to check the variables that ansible is using.  It is commented out, so will not run by default.

##### docker

This playbook installs and configures docker, as well as the python3-docker module required to allow the community.docker.docker_compose_v2 module used later on in the vikunja playbook to function.  There is also a handler to allow for restarting of services after changes.

No secrets are accessed in this playbook.

##### nginx

This playbook installs nginx with a basic config file, and then uses Jinja2 templating to configure a site config file for the Vikunja service, taking into account the certificates (generated by the certbot playbook) and the exposed ip (configured in the vikunja playbook).  The domain and subdomain are evaluated from the inventory/group_vars files, allowing nginx to respond to the subdomain and domain used for this instance.

No secrets are accessed in this playbook.

##### vikunja

This playbook sets up a directory (/opt/vikunja), and prepares it for the Vikunja installation.  In this project, Vikunja is launched and configured using a docker-compose.yml and config.yml.  Both of these files are copied across without secrets being present (see /vikunja/files/), and the secrets are then evaluated via Bitwarden Secrets Manager lookups, and injected into the appropriate files using Jinja2 templating.

A couple of different ansible modules are demonstrated here, including:

- lineinfile: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html>
- blockinfile: <https://docs.ansible.com/ansible/latest/collections/ansible/builtin/blockinfile_module.html>

Once the secrets are set, Vikunja is run via docker compose.

---

#### Ansible Role Configuration

##### inventory

This directory contains examples of how ansible can be used to manage multiple environments - in this case *'qa'* and *'production'*.  In particular, this provides one example of how secrets can be unique per environment, e.g. the Cloudflare token used to authenticate to Cloudflare can be different between your *QA* environment and your *Production* environment, allowing simple management and restriction of access.

The simplest way to define an environment is then at runtime using command-line flags.  Ansible supports multiple levels of precedence of variables, of defining the variable via a CLI argument using the -e flag takes the highest precedence, e.g.:

- `ansible-playbook site.yml -i ./inventory/vikunja.yml -e "deployment_env=qa"`
- `ansible-playbook site.yml -i ./inventory/vikunja.yml -e "deployment_env=production"`

Full documentation for variable precendence in ansible can be found at:
<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#where-to-set-variables>

##### vikunja.yml

This is the inventory file containing the map of hosts used in the project.  In particular, we define two 'groups', qa and production, each of which contains one host.

In a real-life scenario, you could use these capabilities to scale your service across a fleet of machines.

##### group_vars directory

This directory contains one file per environment - one for our *'production'* environment and one for our *'qa'* environment.  Each file contains variables specific to those environments, i.e. the Bitwarden Secret Manager secret IDs (<https://bitwarden.com/help/secrets/>) are specific to each environment.

At runtime, ansible will evaluate values for these IDs by retrieving secrets from your Vault using the Bitwarden Secrets Manager ansible plugin:
<https://bitwarden.com/help/ansible-integration/>

##### host_vars directory

This directory is only used in an adminstrative fashion in this project, to specify the IP, username and SSH key location of the servers to be controlled.  Ansible has many features that allow for dynamic control of environments, but these are beyond the scope of this example project.  Documentation on these features can be found here:
<https://docs.ansible.com/ansible/latest/inventory_guide/intro_dynamic_inventory.html>

---

## Configuration & Usage

This project is tested against VMs using Ubuntu 20.04 with x86 CPU architecture.
