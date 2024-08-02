data "digitalocean_ssh_key" "terraform" {
  name = "terraform"
}

data "digitalocean_project" "bitwarden" {
  name = "bitwarden"
}
