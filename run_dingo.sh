#!/bin/bash
socat udp4-datagram:192.168.131.2:11412,bind=:11412,range=192.168.131.1/24 pty,link=/dev/ttycan0 &
sleep 1
slcand -o -c -F -s8 /dev/ttycan0 vcan0 &
sleep 1
ip link set vcan0 txqueuelen 100
sleep 1
ip link set vcan0 up
sleep 1
docker-compose up
