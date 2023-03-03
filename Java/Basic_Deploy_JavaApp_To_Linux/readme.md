# CONFIG with "foo.service" format

## Simple systemd service case:

### BEFORE:
- Make sure - you have java installed with JAVA_HOME environment variables.

### BEGIN:
- Go to `/etc/systemd/`
- Create file `{name.of.your.app}.service` with context as below:
```services
[Unit]
Description=Name Of your service which one will be visible in terminal after 'systemct' command
After=syslog.target network.target

[Service]
SuccessExitStatus=143

User=appuser
Group=appgroup

Type=simple

Environment="JAVA_HOME=/path/to/jvmdir"
WorkingDirectory=/path/to/app/workdir
ExecStart=${JAVA_HOME}/bin/java -jar javaapp.jar
ExecStop=/bin/kill -15 $MAINPID

[Install]
WantedBy=multi-user.target
```


