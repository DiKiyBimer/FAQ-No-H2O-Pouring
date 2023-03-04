# CONFIG with "foo.service" format

## Simple systemd service case:

### 0. BEFORE:
- Make sure - you have java installed with JAVA_HOME environment variables.

### 1. java-application-daemon.service
- IN:   `/etc/systemd/system`
- CREATE: `{name.of.your.app}.service` WITH CONTEXT AS:
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
### still 1. example-of-fork.services

```
[Unit]
Description=My Java forking service
After=syslog.target network.target
[Service]
SuccessExitStatus=143
User=appuser
Group=appgroup

Type=forking

ExecStart=/path/to/wrapper
ExecStop=/bin/kill -15 $MAINPID

[Install]
WantedBy=multi-user.target
```
### 2. run-java-application.sh
-IN:  `path which you entered at service "exec"`
-CREATE `where you want but for bash file ('.sh' for example)` with context:
```
#!/bin/bash

JAVA_HOME=/path/to/jvmdir
WORKDIR=/path/to/app/workdir
JAVA_OPTIONS=" -Xms256m -Xmx512m -server "
APP_OPTIONS=" -c /path/to/app.config -d /path/to/datadir "

cd $WORKDIR
"${JAVA_HOME}/bin/java" $JAVA_OPTIONS -jar javaapp.jar $APP_OPTIONS
```


### 3. shell
```shell
sudo systemctl daemon-reload

sudo systemctl start javasimple.service
sudo systemctl status javasimple.service ## for check
```
### 4. automatically startup
`sudo systemctl enable javasimple.service`

### 5. EXTRA SWEET THINGS

Spring Boot Application server under Linux service example:

- quick start-server.sh
```
#!/bin/bash
nohup java -jar /path/to/app.jar > /path/to/app.log 2>&1 &
echo $! > /path/to/app.pid
```
- quick stop-server.sh
```
#!/bin/bash
kill $(cat /path/to/app.pid)
```
- server-config.sh
```
#!/bin/bash

JAVA_HOME=`echo $JAVA_HOME`
APPLICATION_NAME=previous-named-java-app
APPLICATION_PORT=443
APPLICATION_PATH="$SCRIPT_DIR/target/$APPLICATION_NAME.jar" ## can be 'war' if necessary
PID_PATH="$SCRIPT_DIR/target/$APPLICATION_NAME.pid"
OUTPUT_PATH="$SCRIPT_DIR/target/$APPLICATION_NAME.out"
```
- real start-server.sh
```
#!/bin/bash

SCRIPT_PATH=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_PATH"`

. "$SCRIPT_DIR/server-config.sh"

if [ ! -f "$APPLICATION_PATH" ];
then
    echo "Incorrect application path '$APPLICATION_PATH'."
    exit 1
fi

if lsof -t "-i:$APPLICATION_PORT" -sTCP:LISTEN &> /dev/null;
then
    echo "Port $APPLICATION_PORTis in use.";
    exit 1
fi

if [ -f "$PID_PATH" ];
then
    PROCESS_PID=`cat "$PID_PATH"`

    if [ -n "$PROCESS_PID" ];
    then
        echo "$APPLICATION_NAME start operation error!"
        echo "Wait until previous start operation will be done or remove '$PID_PATH' file manually if you are sure the application is not starting."
        exit 1
    fi
fi

nohup "$JAVA_HOME/bin/java" -jar "$APPLICATION_PATH" "--server.port=$APPLICATION_PORT" > "$OUTPUT_PATH" 2>&1 &

if [ "$?" -eq 0 ];
then
    echo "$APPLICATION_NAME started!"
    echo "Monitor application output with: less +F '$OUTPUT_PATH'"
    echo "$!" > "$PID_PATH" || echo "Save PID $! in '$PID_PATH' file operation error."
    exit 0
else
    echo "$APPLICATION_NAME start operation error!"
    exit 1
fi
```
- real stop-server.sh
```
#!/bin/bash

SCRIPT_PATH=`readlink -f "$0"`
SCRIPT_DIR=`dirname "$SCRIPT_PATH"`

. "$SCRIPT_DIR/server-config.sh"

if [ -f "$PID_PATH" ];
then
    PROCESS_PID=`cat "$PID_PATH"`

    if [ -n "$PROCESS_PID" ];
    then
        if kill "$APPLICATION_NAME" &> /dev/null;
        then
            echo "$APPLICATION_PORT stopped!"
            rm -f "$PID_PATH" &> /dev/null || echo "" > "$PID_PATH"
            exit 0
        else
            echo "$APPLICATION_NAME stop operation error!"
            echo "Check process with PID $PROCESS_PID or remove '$PID_PATH' file manually."
            exit 1
        fi
    fi
fi

if lsof -t "-i:$APPLICATION_PORT" -sTCP:LISTEN &> /dev/null;
then
    echo "Kill process operation failed!";
    echo "It is necessary to kill process that uses port $APPLICATION_PORT manually.";
    echo "Use following command to find PID: lsof -t -i:$APPLICATION_PORT";
    exit 1
fi
```
- next shell:
`chmod u+x server-config.sh start-server.sh stop-server.sh`
