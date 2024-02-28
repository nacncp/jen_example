#provider.tf
variable "access_key" {
}

variable "secret_key" {
}

provider "ncloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  region      = "KR"
  site        = "public"
  support_vpc = "true"
}
