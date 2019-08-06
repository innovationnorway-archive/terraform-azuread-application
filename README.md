# Azure AD Application

Create Azure AD Application.

> ⚠️ **Warning**: This module will happily expose application credentials. All arguments including the application password will be persisted into Terraform state, into any plan files, and in some cases in the console output while running `terraform plan` and `terraform apply`. Read more about [sensitive data in state](https://www.terraform.io/docs/state/sensitive-data.html).

## Example Usage

```hcl
module "application" {
  source = "innovationnorway/application/azuread"

  name = "example"

  group_membership_claims = "All"

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
}
```

## Arguments

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | The display name of the application. |
| `homepage` | `string` | The URL of the application's homepage. |
| `identifier_uris` | `list` | List of unique URIs that Azure AD can use for the application. |
| `reply_urls` | `list` | List of URIs to which Azure AD will redirect in response to an OAuth 2.0 request. |
| `available_to_other_tenants` | `bool` | Whether the application can be used from any Azure AD tenants. Default: `false`. |
| `native` | `bool` | Whether the application can be installed on a user's device or computer (aka public client). Default: `false`. |
| `oauth2_allow_implicit_flow` | `bool` | Whether to allow implicit grant flow for OAuth2. Default: `false`. |
| `group_membership_claims` | `string` | Configures the groups claim issued in a user or OAuth 2.0 access token that the app expects. The options are: `None`, `SecurityGroup` and `All`. Default: `SecurityGroup`. |
| `password` | `string` | The application password (aka client secret). If empty, Terraform will generate a password. |
| `end_date` | `string` | The date after which the password expire. This can either be relative duration or RFC3339 date. Default: `1Y`. |
| `api_permissions` | `list` | List of API permissions. |
| `app_roles` | `list` | List of App roles. |

The `api_permissions` object accepts the following keys:

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | Name of the API. |
| `oauth2_permissions` | `list` | List of OAuth2 permissions (scopes). |
| `app_roles` | `list` | List of App roles. |

The `app_roles` object must have the following keys:

| Name | Type | Description |
| --- | --- | --- |
| `name` | `string` | Name of the the App role. |
| `description` | `string` | Description of the App role. |
| `member_types` | `list` | List of allowed member types. The options are: `User`, `Application`. |
