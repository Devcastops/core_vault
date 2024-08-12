terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "devcastops"

    workspaces {
      name = "core_vault"
    }
  }
}