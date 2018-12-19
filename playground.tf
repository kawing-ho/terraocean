variable "do_token" {}

provider "digitalocean" {

        # included in the super secret local variables file
        token = "${var.do_token}"
        ssh_fingerprint = "dd:2a:04:8f:f8:69:64:94:a8:de:86:f2:1a:af:b5:3c"
        private_key = "~/.ssh/terraform_key"
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
                private_key = "${file(var.private_key)}"
                timeout = "2m"

        }


        provisioner "remote-exec" {


        }
}
