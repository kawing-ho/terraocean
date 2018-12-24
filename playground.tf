variable "do_token" {}
variable "image" {}
variable "repo" {}
variable "HOME" {}
locals {
        keyfile = "${var.HOME}/.ssh/terraform_key"
}

provider "digitalocean" {

        # included in the super secret local variables file
        token = "${var.do_token}"
}

resource "digitalocean_droplet" "playground" {

        # we use our own packer-baked custom image
        image = "${var.image}"
        # image = "ubuntu-18-04-x64"
        name = "playground"
        region = "sgp1"

        # s-4vcpu-8gb (example format) 
        size = "s-4vcpu-8gb"
        ssh_keys = [ "23705689", "23728621" ]

        connection {
                user = "root"
                type = "ssh"
                timeout = "2m"
                private_key = "${file("${local.keyfile}")}"
        }

        provisioner "file" {
                source = "${var.HOME}/.ssh/id_rsa"
                destination = ".ssh/id_rsa"
        }

        provisioner "file" {
                source = "${var.home}/.ssh/id_rsa.pub"
                destination = ".ssh/id_rsa/pub"
        }

        provisioner "remote-exec" {

                # clone the repository (requires repo keys)
                inline = [
                        "git clone --single-branch --branch staging ${var.repo}"
                ]
        }

        provisioner "local-exec" {
                # can be used to update SSH config when done perhaps
                command = "sed -i \"s/$(ssh -G playground | egrep ^hostname | tr -d [:space:] | tr -d hostname)/${self.ipv4_address}/\" ${var.HOME}/.ssh/config"
        }
}

output "public_ip" {
        value = "${digitalocean_droplet.playground.ipv4_address}"
}

output "price_hourly" {
        value = "${digitalocean_droplet.playground.price_hourly}"
}

output "price_monthly" { 
        value = "${digitalocean_droplet.playground.price_monthly}"
}

output "status" {
        value = "${digitalocean_droplet.playground.status}"
}
