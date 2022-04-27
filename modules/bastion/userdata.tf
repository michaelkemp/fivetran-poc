
locals {
  userdata = <<-USERDATA
    #!/bin/bash

    sudo groupadd fivetran
    sudo useradd -m -g fivetran fivetran
    sudo mkdir -p /home/fivetran/.ssh
    sudo touch /home/fivetran/.ssh/authorized_keys
    sudo chown -R fivetran:fivetran /home/fivetran
    sudo chmod 700 /home/fivetran/.ssh
    sudo chmod 600 /home/fivetran/.ssh/authorized_keys

  USERDATA
}
