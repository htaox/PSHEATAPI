$public  = @(Get-ChildItem -Path "$PSScriptRoot\Public"  -Filter '*.ps1' -Recurse)
$private = @(Get-ChildItem -Path "$PSScriptRoot\Private" -Filter '*.ps1' -Recurse)

@($public + $private) | ForEach-Object -Process {

    try {

        . $_.FullName

    } catch {

        Write-Error -Message "failed to import function $($_.FullName): $_"

    }

}

Export-ModuleMember -Function $public.BaseName

# automatically connect to the service when the module is loaded
try {

    $config = Get-Content -Path $PSScriptRoot\data\config.json | ConvertFrom-Json

    $credentials = [pscredential](Import-Clixml -Path "$PSScriptRoot\data\cachedCredentials")

    Connect-HEATProxy -TenantID $config.tenantId -Role $config.defaultRole -Credential $credentials | Out-Null

} catch {

    Write-Warning -Message 'unable to initiate web service proxy connection, check cached credentials or manually rerun Connect-HEATProxy'

}