# prometheus_posh_client
A Windows PowerShell script module for providing a general way to export metrics to prometheus.

## How to setup a development environment
__NOTE__ You may use cmder (with Git for Windows, http://cmder.net/ or 7-zip) to extarct files from a tarball.

1. Download Prometheus Windows binary from this page, https://prometheus.io/download/#prometheus. 
2. Extract files to a directory, like c:\apps\prometheus\
3. Using Visual Studio Code or Notepad++ to open prometheus.yml and add following parameters.
```
  - job_name: 'pushgateway'
    static_configs:
      - targets: ['localhost:9091']
    honor_labels: true
```
4. Download Prometheus Pushgateway from this page, https://prometheus.io/download/#pushgateway
5. Extract files to a directory, like c:\apps\prometheus-pushgateway\
6. Download Grafana from this page, https://grafana.com/grafana/download?platform=windows
7. Extract files to a directory, like c:\apps\granafa\
8. Follow the instructions in following link to start grafana.
http://docs.grafana.org/installation/windows/


You can also read official documentation for more details.
* https://prometheus.io/docs/introduction/getting_started/
* https://github.com/prometheus/pushgateway
* http://docs.grafana.org/installation/windows/


## TODO
* Add support for accepting CimInstance instances
