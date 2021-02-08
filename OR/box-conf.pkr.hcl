
locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "virtualbox-iso" "mybox" {
  guest_os_type = "Ubuntu_64"
  #iso_url = "http://releases.ubuntu.com/bionic/ubuntu-18.04.5-live-server-amd64.iso"
  iso_url = "http://old-releases.ubuntu.com/releases/18.04.0/ubuntu-18.04-server-amd64.iso"
  iso_checksum = "none"
  #iso_checksum = "sha256:3756b3201007a88da35ee0957fbe6666c495fb3d8ef2e851ed2bd1115dc36446"
  boot_command = ["<esc><wait>",
        "<esc><wait>",
        "<enter><wait>",
        "/install/vmlinuz<wait>",
        " auto<wait>",
        " console-setup/ask_detect=false<wait>",
        " console-setup/layoutcode=us<wait>",
        " console-setup/modelcode=pc105<wait>",
        " debconf/frontend=noninteractive<wait>",
        " debian-installer=en_US<wait>",
        " fb=false<wait>",
        " initrd=/install/initrd.gz<wait>",
        " kbd-chooser/method=us<wait>",
        " keyboard-configuration/layout=USA<wait>",
        " keyboard-configuration/variant=USA<wait>",
        " locale=en_US<wait>",
        " netcfg/get_domain=vm<wait>",
        " netcfg/get_hostname=vagrant<wait>",
        " grub-installer/bootdev=/dev/sda<wait>",
        " noapic<wait>",
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>",
        " -- <wait>",
        "<enter><wait>"]
  http_directory   = "http"
  boot_wait = "10s"
  ssh_wait_timeout = "1800s"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  vboxmanage = [
        [
          "modifyvm",
          "{{.Name}}",
          "--memory",
          "2048"
        ],
        [
          "modifyvm",
          "{{.Name}}",
          "--cpus",
          "2"
        ]
  ]
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["sources.virtualbox-iso.mybox"]
  
  provisioner "shell" {
    inline = ["echo initial provisioning > or.txt"]
  }

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
      "sleep 2",
      "apt-get update",
      "apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
    ]
  }

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
      "sleep 2",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/docker.gpg add -",
      "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable\"",
      "sudo apt-get update && sudo apt-get install -y containerd.io=1.2.13-2 docker-ce=5:19.03.11~3-0~ubuntu-bionic docker-ce-cli=5:19.03.11~3-0~ubuntu-bionic",
    ]
  }

  provisioner "file"{
    source = "configs/docker-daemon.json"
    destination = "/tmp/daemon.json"
  }

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
      "sleep 2",
      "cp /tmp/daemon.json /etc/docker/daemon.json",
    ]
  }

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
      "sleep 2",
      "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -",
      "touch /etc/apt/sources.list.d/kubernetes.list",
      "echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' | sudo tee -a /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl",
    ]
  }

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    script = "configs/cleanup.sh"
  }

}
