module "name" {
  source  = "app.terraform.io/infoex/namer/terraform"
  version = "0.0.7"

  contact     = "nobody@dell.org"
  environment = "sbx"
  location    = local.location
  program     = "dyl"
  repository  = "terraform-azurerm-diagnostics"
  workload    = "apps"
}