########################################################################
# Activate the registry key. (If it does not exist, create a new one.)
# Arguments:
#   Registry key
# Returns:
#   Message informing that a registry key has been created. (Only if the key does not exist.)
########################################################################
function Enable-RegistryKey {
  param (
    $Name
  )
  if (-not (Test-Path $Name)) {
    New-Item $Name
    Write-Output "The registry key ${Name} does not exist. A new one is created."
  }
}
