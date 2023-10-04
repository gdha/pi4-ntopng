#!/bin/bash

# set the directory permissions correct before starting redis-server
chown -R redis:redis /var/log/redis
chmod 7755 /var/log/redis
chown -R redis:redis /etc/redis
chown -R redis:redis /var/lib/redis
# disable transparent hugepage in the kernel to please redis
# /tmp/run.sh: line 9: /sys/kernel/mm/transparent_hugepage/enabled: Read-only file system
# echo never > /sys/kernel/mm/transparent_hugepage/enabled
# start redis
/etc/init.d/redis-server start
# start ntopng
ntopng "$@"
