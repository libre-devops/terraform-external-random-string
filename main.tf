###############################################################################
# Detect the OS
###############################################################################

# Full path to the helper that exists only on Windows
locals {
  windows_helper = "${abspath(path.module)}\\printf.cmd"
}

# If the helper file exists, we’re on Windows; otherwise assume Linux
data "external" "detect_os" {
  program = fileexists(local.windows_helper) ? [local.windows_helper, "{\"os\":\"Windows\"}"] : ["printf", "{\"os\":\"Linux\"}"]
}

locals {
  os         = data.external.detect_os.result.os
  is_windows = lower(local.os) == "windows"
  is_linux   = lower(local.os) == "linux"
}

###############################################################################
# Generate a random string – one data source per platform
###############################################################################

# Linux branch
data "external" "generate_random_string" {
  count       = local.is_linux ? 1 : 0
  working_dir = var.working_dir == null ? path.module : var.working_dir
  program = [
    "bash", "-c",
    "printf '{\"random_string\":\"%s\"}' \"$(head -c 256 /dev/urandom | tr -dc 'A-Za-z0-9' | head -c ${var.random_string_size})\""
  ]
}


# Windows branch
data "external" "generate_random_string_windows" {
  count       = local.is_windows ? 1 : 0
  working_dir = var.working_dir == null ? path.module : var.working_dir
  program     = ["powershell", "-Command", "$randomString = -join ((65..90) + (97..122) | Get-Random -Count ${var.random_string_size} | % {[char]$_}); $json = @{random_string=$randomString} | ConvertTo-Json -Compress; Write-Output $json"]
}

###############################################################################
# Normalise the result
###############################################################################

locals {
  random_string = local.is_linux ? lower(data.external.generate_random_string[0].result.random_string) : lower(data.external.generate_random_string_windows[0].result.random_string)
}
