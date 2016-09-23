#!/bin/sh

NODE1_IP="2000::1"
NODE2_IP="2000::2"
NODE3_IP="2000::3"
NODE4_IP="2000::4"
NODE5_IP="2000::5"
NODE6_IP="2000::6"
NODE7_IP="2000::7"
NODE8_IP="2000::8"
NODE9_IP="2000::9"

CONFIG1="1.txt"
CONFIG2="2.txt"
CONFIG3="3.txt"
CONFIG4="4.txt"
CONFIG5="5.txt"
CONFIG6="6.txt"
CONFIG7="7.txt"
CONFIG8="8.txt"
CONFIG9="9.txt"

USERNAME="wjbang"

CONFIG_LOC=/home/${USERNAME}/ipv6-9nodes
PASSWORD_FILE="${CONFIG_LOC}/password"

echo "Stopping IONs..."
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE1_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE2_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE3_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE4_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE5_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE6_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE7_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE8_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit &"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE9_IP} "ionstop > ${CONFIG_LOC}/scriptlog_exit"
echo "Waiting ionstop 5.."
sleep 1
echo "Waiting ionstop 4.."
sleep 1
echo "Waiting ionstop 3.."
sleep 1
echo "Waiting ionstop 2.."
sleep 1
echo "Waiting ionstop 1.."
sleep 1