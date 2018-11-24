#!/bin/bash
# this script is monitor all the server healthy
# created by wangcz_v 2014-10-14
export LANG=zh_CN.UTF-8

WEB_PAGE=/usr/local/nginx/html/server_status.html
cat <<EOF > $WEB_PAGE
<html>
<head>
<title>xxx系统监控</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="refresh" content="2">
<link rel="shortcut icon" href="favicon.ico" />
</head>
<body >
<div align="center"><embed src="clock.swf" width="460" height="100" wmode="transparent" type="application/x-shockwave-flash" /></div>
<a  href="http://10.202.192.239/filestatus.html">查看缓存文件同步状态</a>
<p>监控频率:5分钟 页面自动刷新频率:2秒</p>
<table width="40%" border="1" cellpading="1" cellspaceing="0" align="center">
<caption><h2>新东方校区缓存监控</h2></caption>
<tr><th>No.</th><th>School Name</th><th>Server IP</th><th>Port</th></tr>
EOF

WORK_DIR=/usr/local/src/network_status
#EMAIL="wangchuzhong@xdf.cn  yuguangxu@xdf.cn wanglei11@xdf.cn wutianlin@xdf.cn"
EMAIL="wangchuzhong@xdf.cn yinjiandong@xdf.cn xuzhiqiang@xdf.cn"
cd $WORK_DIR
if [ ! -e $WORK_DIR/Status.txt ];then
   touch $WORK_DIR/Status.txt
fi
if [ ! -e $WORK_DIR/Alert.log ];then
   touch $WORK_DIR/Alert.log
fi

#############   定义处理函数 ##################
function check_svr
{

ping $ADDRESSS -c 3
  #    echo $?
   if [ $? -eq 0 ] ;then
	     if [ `awk /$ADDRESSS.*down\ / $WORK_DIR/Status.txt |wc -l` -eq 1 ];then         #如果status.txt有，宕机故障恢复，则清除宕机故障记录，发送恢复通知
                echo "$(date) $SVRNAME校区,$ADDRESSS:恢复正常" | mail -s "恢复通知-宕机-$SVRNAME校区-$ADDRESSS" ${EMAIL}
                cat $WORK_DIR/Status.txt |grep -v "$ADDRESSS down" > $WORK_DIR/tmp.txt
                rm -rf $WORK_DIR/Status.txt && mv $WORK_DIR/tmp.txt $WORK_DIR/Status.txt
                echo "$(hostname):$(date):$SVRNAME,$ADDRESSS:$PORT:宕机恢复" >> $WORK_DIR/Alert.log
             fi
         status=`nmap -P0 -n -p$PORT $ADDRESSS |grep tcp |awk '{print $2}'`
               if [[ $status = "filtered" ]] || [[ $status = "closed" ]] ;then
	            if [ `awk /$ADDRESSS.*$PORT\ / $WORK_DIR/Status.txt |wc -l` -eq 0 ];then  #如果status.txt无则记录故障（新端口故障）发送故障邮件 输出
                           echo "$(date) $SVRNAME校区,$ADDRESSS:$PORT:端口故障，请管理员及时处理！" | mail -s "故障通知-端口-$SVRNAME校区-$ADDRESSS:$PORT" ${EMAIL}
                           echo "$ADDRESSS $PORT $status" >> $WORK_DIR/Status.txt
                           echo "$(hostname):$(date):$SVRNAME,$ADDRESSS:$PORT:端口故障" >> $WORK_DIR/Alert.log
                            echo "<tr><th align=center>$i</th><th align=center>$SVRNAME</th><td align=center bgcolor=grea>$ADDRESSS</td><td align=center bgcolor=red>$PORT</td></tr>">>$WEB_PAGE
                    else                                                                     #如果status.txt有，不发邮件 (旧端口故障) 只输出
                        echo "<tr><th align=center>$i</th><th align=center>$SVRNAME</th><td align=center bgcolor=grea>$ADDRESSS</td><td align=center bgcolor=red>$PORT</td></tr>">>$WEB_PAGE
	            fi
               else 
                  if [ $status = "open" ];then
                       if [ `awk /$ADDRESSS.*$PORT\ / $WORK_DIR/Status.txt |wc -l` -eq 1 ];then  #如果status.txt有，端口故障恢复，则清除端口故障记录，发送恢复邮件，输出
                          echo "$(date) $SVRNAME校区,$ADDRESSS:$PORT:恢复正常" | mail -s "恢复通知-端口-$SVRNAME校区-$ADDRESSS:$PORT" ${EMAIL}
                          cat $WORK_DIR/Status.txt |grep -v "$ADDRESSS $PORT" > $WORK_DIR/tmp.txt
                          rm -rf $WORK_DIR/Status.txt && mv $WORK_DIR/tmp.txt $WORK_DIR/Status.txt
                          echo "$(hostname):$(date):$SVRNAME,$ADDRESSS:$PORT 端口恢复正常" >> $WORK_DIR/Alert.log
			  echo "<tr><th align=center>$i</th><th align=center>$SVRNAME</th><td align=center bgcolor=grea>$ADDRESSS</td><td align=center bgcolor=grea>$PORT</td></tr>">>$WEB_PAGE
                       else echo "<tr><th align=center>$i</th><th align=center>$SVRNAME</th><td align=center bgcolor=grea>$ADDRESSS</td><td align=center bgcolor=grea>$PORT</td></tr>">>$WEB_PAGE                                                        #如果status.txt无，端口一直正常，只输出
                       fi
                  fi	   
	       fi

        
     
   else
       
        if [ `awk /$ADDRESSS.*down\ / $WORK_DIR/Status.txt |wc -l` -eq 0 ];then         #如果status.txt无则记录故障（新宕机故障）发送故障邮件，输出
	   echo "$(date) $SVRNAME校区,$ADDRESSS:宕机故障，请管理员及时处理!" | mail -s "故障通知-宕机-$SVRNAME校区-$ADDRESSS" ${EMAIL}
           echo "$ADDRESSS down down" >> $WORK_DIR/Status.txt
           echo "$(hostname):$(date):$SVRNAME,$ADDRESSS:$PORT:宕机故障" >> $WORK_DIR/Alert.log
	   echo "<tr><th align=center>$i</th><th align=center>$SVRNAME</th><td align=center bgcolor=red>$ADDRESSS</td><td align=center bgcolor=red>$PORT</td></tr>">>$WEB_PAGE
        else echo "<tr><th align=center>$i</th><th align=center>$SVRNAME</th><td align=center bgcolor=red>$ADDRESSS</td><td align=center bgcolor=red>$PORT</td></tr>">>$WEB_PAGE                                                          #如果status.txt有，不发送邮件（旧宕机故障）只输出
        fi
   fi
}

LINES=`awk 'END{print NR}' configlist.txt`                                        #获取总configlist.txt文件的条目数

i=1
while (($i<=$LINES)) 

        do
        ADDRESSS=`sed -n "$i"p configlist.txt | awk -F" " '{print $1}'`    #获取地址
        PORT=`sed -n "$i"p configlist.txt | awk -F" " '{print $2}'`        #获取端口
        SVRNAME=`sed -n "$i"p configlist.txt | awk -F" " '{print $3}'`     #获取校区名 
        check_svr
        i=$(($i+1))
done
echo -e "</table>\n</body>\n</html>\n">>$WEB_PAGE
