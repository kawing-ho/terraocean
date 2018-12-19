provider "digitalocean" {

        # included in the super secret local variables file
        token = "${var.do_access_token}"
        ssh_fingerprint = "dd:2a:04:8f:f8:69:64:94:a8:de:86:f2:1a:af:b5:3c"


}

resource "digitalocean-droplet" "playground" {

        image = "ubuntu-18-04-x64"
        name = "playground"
        region = "sgp1"
        size = "s-1vcpu-1gb"
}
