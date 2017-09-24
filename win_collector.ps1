# requires -version 5.0

<#
 # A powershell script for providing a general way to export metrics to prometheus
 #>

Import-Module .\flancy.psd1

function ConvertTo-PromExposition
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSample]
        $Sample
    )

    begin
    {
        $results = New-Object System.Text.StringBuilder
    }

    process
    {
        # Get counter path
        $path = $Sample.Path
        $path = $path.ToLower()

        # Get host name from path
        $hostname = $path.split('\')[2]
        $path = $path -replace $hostname, ''

        # Make sure metric name is valid
        $pattern = '[a-zA-Z_:][a-zA-Z0-9_:]*'
        $name = @()
        [regex]::Matches($path, $pattern) | %{$name += $PSItem.Value}
        $name = $name -join '_'

        # Get value
        $value = $Sample.CookedValue

        $metric = $name + '{{hostname={0}, name="{1}"}}' -f @($hostname, $name)
        
        $result1 = '#HELP {0}' -f $metric
        $result2 = '#TYPE {0} gauge' -f $metric
        $result3 = '{0}' -f $value

        $null = $results.AppendLine($result1)
        $null = $results.AppendLine($result2)
        $null = $results.AppendLine($result3)

    }

    end
    {
        return $results.ToString()
    }
}


# New-Flancy -Url "http://localhost:9000" -Path $PSScriptRoot -WebSchema @(
#     Get '/' {"Welcome to flancy!"}
#     Get '/metrics' {
#         $response = Get-Counter | Select-Object -ExpandProperty 'CounterSamples' | ConvertTo-PromExposition
#         Write-Debug -Message $response
#         Write-Output -InputObject $response
#     }
# )

Get-Counter | Select-Object -ExpandProperty 'CounterSamples' | ConvertTo-PromExposition