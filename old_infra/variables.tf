variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
  default     = "b1g1ap7lhncbl9q7crfn"
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
  default     = "b1grbnd43egs57caqic6"
}

variable "default_zone" {
  description = "Default zone"
  type        = string
  default     = "ru-central1-a"
}

# Актуальная версия Kubernetes
variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"  # Изменено с 1.28 на 1.31
}

variable "k8s_node_count" {
  description = "Initial number of Kubernetes nodes (min)"
  type        = number
  default     = 3
}

variable "k8s_node_max" {
  description = "Maximum number of Kubernetes nodes"
  type        = number
  default     = 6
}

variable "k8s_node_memory" {
  description = "Memory per Kubernetes node in GB"
  type        = number
  default     = 4
}

variable "k8s_node_cores" {
  description = "CPU cores per Kubernetes node"
  type        = number
  default     = 2
}