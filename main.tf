terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
#variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  #token = var.do_token
  token = var.do_token
}

# Create a new Web Droplet in the nyc1 region
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.jornada_ssh_key.id] #Vinculando a chave ssh: jornada_ssh_key
}

data "digitalocean_ssh_key" "jornada_ssh_key" {
  name = var.ssh_key_name
}

# Adicionando o Cluster Kubernetes
resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = var.region
  version = "1.26.3-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2

    # taint {Não vamos usar}
  }
}

variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = ""
}

variable "region" {
  default = ""
}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "foo" {
  content  = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config 
  #Temos que seguir pela Doc, após o 0 não há Autocomplete
  filename = "kube_config.yaml"
}