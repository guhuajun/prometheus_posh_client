# requires -version 5.0

<#
 # A powershell script module for providing a general way to export metrics to prometheus
 # Author:  Huajun (Greg) Gu
 # Version: 0.1
 #>

 function ConvertTo-PromExposition
{
    <#
    .SYNOPSIS
        A function to generate data that can be post to Prometheus PushGateway.
    .DESCRIPTION
        A function to generate data that can be post to Prometheus PushGateway.
    .INPUTS
        Microsoft.PowerShell.Commands.GetCounter.PerformanceCounterSample
    .OUTPUTS
        System.String
    .LINK
        https://prometheus.io/docs/instrumenting/exposition_formats/
    .EXAMPLE
        $metric = Get-Counter | Select-Object -ExpandProperty 'CounterSamples' | ?{$PSItem.InstanceName -match '[a-zA-Z_:][a-zA-Z0-9_:]*'}
        $metric = $metric | ConvertTo-PromExposition
        $response = Invoke-WebRequest -Uri "http://localhost:9091/metrics/job/pushgateway/" -Method Post -Body $metric
    .NOTES
        None
    #>

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
            $metric = 'windows_' + $metric
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
            $PSCmdlet.WriteError($PSItem.Exception.ToString())
        }
    }

    end
    {
        return $results.ToString()
    }
}

Export-ModuleMember -Function 'ConvertTo-PromExposition'
