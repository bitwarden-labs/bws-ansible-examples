resource "digitalocean_droplet" "exampleserver" {
  name     = "example"
  image    = "ubuntu-20-04-x64"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [data.digitalocean_ssh_key.terraform.id]


  # provisioner "remote-exec" {
  #   connection {
  #     host        = self.ipv4_address
  #     user        = "root"
  #     type        = "ssh"
  #     private_key = file(var.digitalocean_ssh_key)
  #     timeout     = "2m"
  #   }

  #   inline = [
  #     "apt-get update",
  #     "apt-get install -y ansible",
  #     # currently failing - unable to obtain lock file
  #     "ansible-pull -U https://github.com/bitwarden-labs/bws-ansible-examples.git certbox-nginx-vikunja/runner.yml"
  #   ]
  # }
}

resource "digitalocean_project_resources" "bitwarden_tf" {
  project   = var.digitalocean_project_id
  resources = [digitalocean_droplet.exampleserver.urn]
}
