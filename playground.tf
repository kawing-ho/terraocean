variable "do_token" {}
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
        image = "ubuntu-18-04-x64"
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

        provisioner "remote-exec" {

                # clone the repository (requires repo keys)
                inline = [
                        "ps",
                        "date",
                        "echo test > /tmp/test"
                ]
        }

        provisioner "local-exec" {
                # can be used to update SSH config when done perhaps
                command = "echo ${self.ipv4_address} > /tmp/terraform.log"
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
