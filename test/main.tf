resource "random_id" "test" {
  byte_length = 4
}

module "application" {
  source = "../"

  name = format("test-%s", random_id.test.hex)

  group_membership_claims = "All"

  end_date = "2020-01-01"

  api_permissions = [
    {
      name = "Microsoft Graph"
      oauth2_permissions = [
        "Directory.Read.All",
        "User.Read"
      ]
      app_roles = [
        "Directory.Read.All"
      ]
    }
  ]

  app_roles = [
    {
      name        = "test"
      description = "test"
      member_types = [
        "Application"
      ]
    }
  ]
}

data "azuread_application" "test" {
  name = module.application.name
}

module "test_assertions" {
  source = "innovationnorway/assertions/test"
  equals = [
    {
      name = "has identifier URIs"
      got  = length(data.azuread_application.test.identifier_uris)
      want = 1
    },
    {
      name = "has expected number of app roles"
      got  = length(data.azuread_application.test.app_roles)
      want = 1
    }
  ]
}
