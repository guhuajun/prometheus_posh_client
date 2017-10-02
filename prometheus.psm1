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
        try
        {
            # Get counter path
            $path = $Sample.Path
            $path = $path.ToLower()

            # Get host name from path
            $hostname = $path.split('\')[2]
            $path = $path -replace $hostname, ''

            # Get instance name from path then remove it
            $instanceName = $Sample.InstanceName.ToLower()
            $path = $path -replace $instanceName, ''
            
            # Make sure metric name is valid
            $pattern = '[a-zA-Z_:][a-zA-Z0-9_:]*'
            $metricNames = @()
            [regex]::Matches($path, $pattern) | %{$metricNames += $PSItem.Value}
            $metric = $metricNames -join '_'
            $PSCmdlet.WriteVerbose('Metric name is {0}' -f $metric)

            # Make sure instance name is valid
            $instanceNames = @()
            [regex]::Matches($instanceName, $pattern) | %{$instanceNames += $PSItem.Value}
            $instanceName = $instanceNames -join '_'
            $PSCmdlet.WriteVerbose('Instance name is {0}' -f $instanceName)

            # Get value
            $value = $Sample.CookedValue
        
            $result1 = "#HELP {0}`n" -f $metric
            $result2 = "#TYPE {0} gauge`n" -f $metric
            $result3 = "{0}{{host=`"{1}`", instance=`"{2}`"}} {3}`n" -f @(
                $metric, $hostname, $instanceName, $value)
            $null = $results.Append($result1)
            $null = $results.Append($result2)
            $null = $results.Append($result3)            
        }
        catch
        {
            $PSCmdlet.WriteError($Error[0])
        }
    }

    end
    {
        return $results.ToString()
    }
}

Export-ModuleMember -Function 'ConvertTo-PromExposition'
