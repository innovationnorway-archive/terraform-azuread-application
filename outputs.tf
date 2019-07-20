output "name" {
  value       = azuread_application.main.name
  description = "The display name of the application."
}

output "application_id" {
  value       = azuread_application.main.application_id
  description = "The ID of the application."
}

output "object_id" {
  value       = azuread_application.main.object_id
  description = "The object ID of the application."
}

output "app_roles" {
  value = {
    for r in azuread_application.main.app_role :
    r.display_name => {
      id          = r.id
      name        = r.display_name
      value       = r.value
      description = r.description
      enabled     = r.is_enabled
    }
  }
}
