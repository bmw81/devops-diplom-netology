data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# Ресурс резервирования статического публичного IP-адреса для мастер-ноды
resource "yandex_vpc_address" "master_ip" {
  name = "master-public-ip"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

# VM для master-node с публичным IP в зоне a
resource "yandex_compute_instance" "vm-a" {
  name        = "vm-a"
  hostname    = "vm-a"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  allow_stopping_for_update = true


  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-a.id
    nat                = true
    # Привязать статический адрес
    nat_ip_address = yandex_vpc_address.master_ip.external_ipv4_address[0].address
  }
}

# VM для worker-node с приватным IP в зоне b
resource "yandex_compute_instance" "vm-b" {
  name        = "vm-b"
  hostname    = "vm-b"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"
  allow_stopping_for_update = true


  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-b.id
    nat                = false
  }
}

# VM для worker-node с приватным IP в зоне d
resource "yandex_compute_instance" "vm-d" {
  name        = "vm-d"
  hostname    = "vm-d"
  platform_id = "standard-v3"
  zone        = "ru-central1-d"
  allow_stopping_for_update = true


  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
    serial-port-enable = 1
  }

  scheduling_policy { preemptible = true }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-d.id
    nat                = false
  }
}