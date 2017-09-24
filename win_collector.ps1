# requires -version 5.0

<#
 # A powershell script for providing a general way to export metrics to prometheus
 #>

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
        
        $result1 = '#HELP {0}\n' -f $metric
        $result2 = '#TYPE {0} gauge\n' -f $metric
        $result3 = '{0}\n' -f $value

        $null = $results.Append($result1)
        $null = $results.Append($result2)
        $null = $results.Append($result3)
    }

    end
    {
        return [System.String]::Join($results)
    }
}

$metricItem = Get-Counter | Select-Object -ExpandProperty 'CounterSamples' | ConvertTo-PromExposition

Write-Output $metricItem