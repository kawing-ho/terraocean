/* Secret variables that I'm not gonna commit to the repo lol */
variable "do_token" {}
variable "github_token" {}
variable "pull_image" {}
variable "repo" {}
variable "yarn" {}
variable "HOME" {}

locals {
        keyfile = "${var.HOME}/.ssh/terraform_key"
}

provider "digitalocean" {

        # included in the super secret local variables file
        token = "${var.do_token}"
}

data "digitalocean_image" "playground" {
        name = "playground-img-1545567755"
}

resource "digitalocean_droplet" "playground" {

        # we use our own packer-baked custom image
        image = "${data.digitalocean_image.playground.image}"
        # image = "ubuntu-18-04-x64"
        name = "playground"
        region = "sgp1"

        # s-4vcpu-8gb (example format, $40/month ooft) 
        size = "s-4vcpu-8gb"
        ssh_keys = [ "23705689", "23728621" ]

        connection {
                user = "root"
                type = "ssh"
                timeout = "2m"
                private_key = "${file("${local.keyfile}")}"
        }

        # copy repo keys over
        provisioner "file" {
                source = "${var.HOME}/.ssh/id_rsa"
                destination = ".ssh/id_rsa"
        }

        provisioner "file" {
                source = "${var.HOME}/.ssh/id_rsa.pub"
                destination = ".ssh/id_rsa.pub"
        }

        provisioner "remote-exec" {

                # clone the repository (requires repo keys)
                inline = [
                        "touch .hushlogin",
                        "chmod 600 .ssh/id_rsa",
                        "export GITHUB_TOKEN=${var.github_token}",
                        "git config --global user.email kawing-ho@users.noreply.github.com",
                        "git config --global user.name kawing-ho",
                        "ssh-keyscan -H github.com >> ~/.ssh/known_hosts",
                        "git clone ${var.repo}",
                        "git clone ${var.yarn}",
                        "docker pull ${var.pull_image}"
                ]
        }

        provisioner "local-exec" {
                # update local SSH config file 
                command = "sed -i \"s/$(ssh -G playground | egrep ^hostname | tr -d [:space:] | tr -d hostname)/${self.ipv4_address}/\" ${var.HOME}/.ssh/config"
        }

        provisioner "local-exec" {
                # add new IP to known hosts
                command = "ssh-keyscan -H ${self.ipv4_address} >> ~/.ssh/known_hosts"
        }

        # DESTROY-TIME PROVISIONER
        provisioner "local-exec" {
                # remove IP from known hosts
                when = "destroy"
                command = "ssh-keygen -R ${self.ipv4_address}"
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
