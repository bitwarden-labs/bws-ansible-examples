variable do_token {
  description = "DO API token (retrieved via BWS at runtime)"
}

variable "digitalocean_ssh_key" {
  description = "Path to DigitalOcean SSH key"
  type        = string
  default     = "/Users/adambramley/.ssh/digitalOcean/terraform"
}

variable "digitalocean_project_id" {
  description = "DO Project to use"
  type = string
  default = "bitwarden_terraform"
}

variable "droplet_names" {
  type = list(string)
  default = ["digitalocean_qa", "digitalocean_production"]
}

variable "environment_tags" {
  type = list(string)
  default = [ "qa", "production" ]
}