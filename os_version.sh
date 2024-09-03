#!/bin/bash

# VM list
#VBoxManage list runningvms
for i in {1..4}
do
  os=`ssh vagrant@node${i} "head -1 /etc/system-release" 2>/dev/null`
  ifdb=`ssh vagrant@node${i} -o LogLevel=ERROR "cat /etc/passwd | grep enterprisedb | wc -l"`
  if [ "$ifdb" -eq "1" ]; then
    db=`ssh vagrant@node${i} -o LogLevel=ERROR "sudo su - enterprisedb -c 'pgd show-version  2>/dev/null'" | grep node${i} | awk '{print $3}' 2>/dev/null`
    printf "node${i}: OS version: ${os}\t Database version: ${db}\n"
  fi
done
for i in {6..6}
do
  os=`ssh vagrant@node${i} "head -1 /etc/system-release" 2>/dev/null`
  printf "node${i}: OS version: ${os}\t Database version: ${db}\n"
done
