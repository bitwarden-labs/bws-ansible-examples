data "digitalocean_ssh_key" "terraform" {
  name = "~/.ssh/digital-ocean"
}

data "digitalocean_project" "bitwarden" {
  name = "bitwarden"
}
