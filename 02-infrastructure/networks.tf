# ============================================
# 1. Создать облачную сеть (VPC)
# ============================================
resource "yandex_vpc_network" "develop" {
  name = "devops"
}

# ============================================
# 2. Публичная подсеть (для NAT-инстанса и мастер-ноды)
# ============================================
resource "yandex_vpc_subnet" "subnet-a" {
  name           = "subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# ============================================
# 3. Приватные подсети (для worker-нод)
# ============================================
resource "yandex_vpc_subnet" "subnet-b" {
  name           = "subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id  # Выход в интернет через NAT
}

resource "yandex_vpc_subnet" "subnet-d" {
  name           = "subnet-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id  # Выход в интернет через NAT
}

# ============================================
# 4. NAT-инстанс (шлюз для выхода в интернет)
# ============================================
resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-vm"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      # Официальный образ NAT-инстанса от Yandex Cloud
      image_id = "fd8eag95cjr8pasn9c4r"  # Ubuntu 22.04 LTS with NAT
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet-a.id
    nat                = true  # Публичный IP
    ip_address         = "192.168.10.254"  # Статический IP для маршрутизации
    security_group_ids = [yandex_vpc_security_group.nat_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/tf_ed25519.pub")}"
    user-data = <<-EOF
      #cloud-config
      runcmd:
        # Включаем IP-форвардинг
        - echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
        - sysctl -p
        # Настраиваем NAT (MASQUERADE)
        - iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
        # Сохраняем правила iptables
        - apt-get update
        - apt-get install -y iptables-persistent
        - netfilter-persistent save
      EOF
  }
}

# ============================================
# 5. Таблица маршрутизации для приватных подсетей
# ============================================
resource "yandex_vpc_route_table" "rt" {
  name       = "rt"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"  # Внутренний IP NAT-инстанса
  }
}

# ============================================
# 6. Security Group для NAT-инстанса
# ============================================
resource "yandex_vpc_security_group" "nat_sg" {
  name       = "nat-sg"
  network_id = yandex_vpc_network.develop.id

  # Разрешаем весь внутренний трафик из подсетей
  ingress {
    description    = "Allow all internal traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  # Разрешаем SSH из публичной подсети (для управления)
  ingress {
    description    = "Allow SSH from public subnet"
    protocol       = "TCP"
    v4_cidr_blocks = ["192.168.10.0/24"]
    port           = 22
  }

  # Разрешаем весь исходящий трафик (в интернет)
  egress {
    description    = "Allow ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# ============================================
# 7. Security Group для мастер-ноды и воркеров (LAN)
# ============================================
resource "yandex_vpc_security_group" "lan_sg" {
  name       = "lan-sg"
  network_id = yandex_vpc_network.develop.id

  # Разрешаем весь внутренний трафик между узлами кластера
  ingress {
    description    = "Allow all internal traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24"]
    from_port      = 0
    to_port        = 65535
  }

  # Разрешаем SSH из интернета (только для мастер-ноды, если она публичная)
  ingress {
    description    = "Allow SSH from internet"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Разрешаем весь исходящий трафик
  egress {
    description    = "Allow ANY"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}