#!/bin/bash
task_list=${1:-"task.list"}
#set -x
for file in $(ls conf.ini.[0-9]*)
do
    echo $file
    logfile=./log/$(date +%Y%m%d-%H:%M)=${file}.log
    mrun.sh converter $file | tee ./$logfile
    SendMail.sh ./$logfile
done
