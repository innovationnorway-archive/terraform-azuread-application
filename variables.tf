variable "name" {
  type        = string
  description = "The display name of the application"
}

variable "homepage" {
  type        = string
  default     = ""
  description = "The URL of the application's homepage."
}

variable "identifier_uris" {
  type        = list(string)
  default     = []
  description = "List of unique URIs that Azure AD can use for the application."
}

variable "reply_urls" {
  type        = list(string)
  default     = []
  description = "List of URIs to which Azure AD will redirect in response to an OAuth 2.0 request."
}

variable "available_to_other_tenants" {
  type        = bool
  default     = false
  description = "Whether the application can be used from any Azure AD tenants."
}

variable "oauth2_allow_implicit_flow" {
  type        = bool
  default     = false
  description = "Whether to allow implicit grant flow for OAuth2."
}

variable "native" {
  type        = bool
  default     = false
  description = "Whether the application can be installed on a user's device or computer."
}

variable "group_membership_claims" {
  type        = string
  default     = "SecurityGroup"
  description = "Configures the groups claim issued in a user or OAuth 2.0 access token that the app expects."
}

variable "password" {
  type        = string
  default     = ""
  description = "The application password (aka client secret)."
}

variable "end_date" {
  type        = string
  default     = "1Y"
  description = "The RFC3339 date after which credentials expire."
}

variable "api_permissions" {
  type        = any
  default     = []
  description = "List of API permissions."
}

variable "app_roles" {
  type        = any
  default     = []
  description = "List of App roles."
}

locals {
  homepage = format("https://%s", var.name)

  type = var.native ? "native" : "webapp/api"

  public_client = var.native ? true : false

  default_identifier_uris = [format("http://%s", var.name)]

  identifier_uris = var.native ? [] : coalescelist(var.identifier_uris, local.default_identifier_uris)

  api_permissions = [
    for p in var.api_permissions : merge({
      id                 = ""
      name               = ""
      app_roles          = []
      oauth2_permissions = []
    }, p)
  ]

  api_names = local.api_permissions[*].name

  service_principals = {
    for s in data.azuread_service_principal.main : s.display_name => {
      application_id     = s.application_id
      display_name       = s.display_name
      app_roles          = { for p in s.app_roles : p.value => p.id }
      oauth2_permissions = { for p in s.oauth2_permissions : p.value => p.id }
    }
  }

  required_resource_access = [
    for a in local.api_permissions : {
      resource_app_id = local.service_principals[a.name].application_id
      resource_access = concat(
        [for p in a.oauth2_permissions : {
          id   = local.service_principals[a.name].oauth2_permissions[p]
          type = "Scope"
        }],
        [for p in a.app_roles : {
          id   = local.service_principals[a.name].app_roles[p]
          type = "Role"
        }]
      )
    }
  ]

  app_roles = [
    for r in var.app_roles : merge({
      name         = ""
      description  = ""
      member_types = []
      enabled      = true
      value        = ""
    }, r)
  ]

  date_pattern     = "/^(?:(\\d{4})-(\\d{2})-(\\d{2}))[Tt]?(?:(\\d{2}):(\\d{2})(?::(\\d{2}))?(?:\\.(\\d+))?)?([Zz]|[\\+|\\-]\\d{2}:\\d{2})?$/"
  duration_pattern = "/^(?:(\\d?)Y)?(?:(\\d?)M)?(?:(\\d+)W)?(?:(\\d+)D)?(?:(\\d+)h)?(?:(\\d+)m)?(?:(\\d+)s)?$/"

  is_date_relative = replace(var.end_date, "/^(?:(\\d+)[Y|M|W|D|h|m|s])+$/", "$1") != var.end_date ? true : false

  date = {
    year  = replace(var.end_date, local.date_pattern, "$1")
    month = replace(var.end_date, local.date_pattern, "$2")
    day   = replace(var.end_date, local.date_pattern, "$3")
  }

  time = {
    hour     = replace(var.end_date, local.date_pattern, "$4")
    minute   = replace(var.end_date, local.date_pattern, "$5")
    second   = replace(var.end_date, local.date_pattern, "$6")
    fraction = replace(var.end_date, local.date_pattern, "$7")
    offset   = replace(var.end_date, local.date_pattern, "$8")
  }

  duration = {
    years   = replace(var.end_date, local.duration_pattern, "$1")
    months  = replace(var.end_date, local.duration_pattern, "$2")
    weeks   = replace(var.end_date, local.duration_pattern, "$3")
    days    = replace(var.end_date, local.duration_pattern, "$4")
    hours   = replace(var.end_date, local.duration_pattern, "$5")
    minutes = replace(var.end_date, local.duration_pattern, "$6")
    seconds = replace(var.end_date, local.duration_pattern, "$7")
  }

  end_date_relative = local.is_date_relative ? format(
    "%dh",
    (
      (coalesce(local.duration.years, 0) * 24 * 365) +
      (coalesce(local.duration.months, 0) * 24 * 30) +
      (coalesce(local.duration.days, 0) * 24) +
      coalesce(local.duration.hours, 0)
    )
  ) : null

  end_date = local.is_date_relative ? null : format(
    "%02d-%02d-%02dT%02d:%02d:%02d.%02d%s",
    local.date.year,
    local.date.month,
    local.date.day,
    coalesce(local.time.hour, "23"),
    coalesce(local.time.minute, "59"),
    coalesce(local.time.second, "00"),
    coalesce(local.time.fraction, "00"),
    coalesce(local.time.offset, "Z")
  )
}
