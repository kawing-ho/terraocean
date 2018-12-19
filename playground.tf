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

        image = "ubuntu-18-04-x64"
        name = "playground"
        region = "sgp1"
        size = "s-1vcpu-1gb"
        ssh_keys = [ "23705689", "23728621" ]

        connection {
                user = "root"
                type = "ssh"
                private_key = "$file({${local.keyfile})}"
                timeout = "2m"
        }


        provisioner "remote-exec" {
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
