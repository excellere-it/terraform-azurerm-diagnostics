module "name" {
  source  = "app.terraform.io/infoex/namer/terraform"
  version = "0.0.2"

  contact     = "nobody@infoex.dev"
  environment = "sbx"
  location    = local.location
  repository  = "terraform-azurerm-diagnostics"
  workload    = "apps"
}