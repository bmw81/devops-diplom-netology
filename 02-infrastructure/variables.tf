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

variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = "~/.authorized_key.json"
}
