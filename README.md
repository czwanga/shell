# Shell + HTML realizes simple monitoring server online and service status, alarm
Simple on-line monitoring server, service status and alarm are realized by shell + HTML

Usage：

1.edit config_list file,add need monitored ip port application

    172.17.0.2 8080 tomcat
    172.17.0.1 6379 redis
    192.168.18.203 80 nginx
    172.16.14.158 3306 mysql
         
2.add crontab

*/5 * * * *  /data/service_status/status_service_monitor.sh

Monitoring graphics following

![graphics](https://github.com/czwanga/shell/blob/master/Monitoring%20graphics.png)
    
