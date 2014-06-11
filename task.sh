#!/bin/bash
task_list=${1:-"task.list"}
#set -x
for file in $(ls conf.ini.[0-9]*)
do
    echo $file
    logfile=./log/${file}~translate~$(date +%Y%m%d-%H:%M).log
    #mrun.sh converter $file | tee ./$logfile
    mrun.sh translate_mfcc $file | tee ./$logfile
    SendMail.sh ./$logfile
done
