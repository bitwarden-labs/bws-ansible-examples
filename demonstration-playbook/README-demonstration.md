# Introduction

This role uses a single Ansible to demonstrate ways to dynamically retrieve secrets from Bitwarden Secrets Manager.  The purpose of the role is to give users a kick-start by providing syntax examples, as well as a few ideas as to how secrets can be stored and manipulated.

## Usage Instructions

- Install ansible, including the Bitwarden SM SDK and the necessary modules from ansible galaxy:

  - git clone https://github.com/bitwarden-labs/bws-ansible-examples.git
  - cd bws-ansible-examples/demonstration-playbook
  - python3 -m venv ./venv (Optional - creates a Python virtual environment to work in)
  - source ./venv/bin/activate (Optional - actives the virtual environment. Use 'deactivate' to return to your normal namespace)
  - python3 -m pip install ansible bitwarden-sdk
  - ansible-galaxy collection install community.docker bitwarden.secrets
  - export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES (for macOS only)

- Run the example playbook

  - `ansible-playbook site.yml`

### Usage Notes

The playbook creates two files - `example.txt` and `injected_secrets.txt`.  These files will both be created on the users' desktop at ~/Desktop/

It is important to ensure that the user running the playbook has write permissions to this location and that the location exists.  If not, simply substitute this location for an alternative in /demo-playbook/tasks/main.yml
