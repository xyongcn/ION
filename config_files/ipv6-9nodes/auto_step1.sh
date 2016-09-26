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

BPCONFIG="bpconfig.conf"

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

sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE1_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE2_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE3_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE4_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE5_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE6_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE7_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE8_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE9_IP} "mkdir ${CONFIG_LOC}"

sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG1} ${USERNAME}@[${NODE1_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG2} ${USERNAME}@[${NODE2_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG3} ${USERNAME}@[${NODE3_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG4} ${USERNAME}@[${NODE4_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG5} ${USERNAME}@[${NODE5_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG6} ${USERNAME}@[${NODE6_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG7} ${USERNAME}@[${NODE7_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG8} ${USERNAME}@[${NODE8_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG9} ${USERNAME}@[${NODE9_IP}]:${CONFIG_LOC}

sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE1_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE2_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE3_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE4_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE5_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE6_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE7_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE8_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE9_IP}]:${CONFIG_LOC}

echo "Stopping IONs if they are already opened..."
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

echo "Starting IONs..."
echo "Starting ION1"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE1_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG1} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION2"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE2_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG2} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION3"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE3_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG3} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION4"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE4_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG4} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION5"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE5_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG5} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION6"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE6_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG6} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION7"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE7_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG7} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION8"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE8_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG8} > ${CONFIG_LOC}/scriptlog &"
echo "Starting ION9"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no -q ${USERNAME}@${NODE9_IP} "ionstart -I ${CONFIG_LOC}/${CONFIG9} > ${CONFIG_LOC}/scriptlog"

echo "Waiting ionstart 6.."
sleep 1
echo "Waiting ionstart 5.."
sleep 1
echo "Waiting ionstart 4.."
sleep 1
echo "Waiting ionstart 3.."
sleep 1
echo "Waiting ionstart 2.."
sleep 1
echo "Waiting ionstart 1.."
sleep 1

sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE1_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE2_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE3_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE4_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE5_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE6_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE7_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE8_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE9_IP} "bpadmin ${CONFIG_LOC}/${BPCONFIG}"

# ´°¸ñ±àºÅ0~9µÄË³ÐòÊÇ
# 0  3  6 
# 1  4  7
# 2  5  8
tmux kill-session
tmux kill-session

tmux new-session -d -s 9nodes
tmux split-window -h -p 67
tmux split-window -h
tmux select-pane -t %0
tmux split-window -v -p 67
tmux split-window -v
tmux select-pane -t %1
tmux split-window -v -p 67
tmux split-window -v
tmux select-pane -t %2
tmux split-window -v -p 67
tmux split-window -v

tmux select-pane -t 1
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE2_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m
tmux select-pane -t 2
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE3_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m
tmux select-pane -t 3
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE4_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m
tmux select-pane -t 4
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE5_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m
tmux select-pane -t 5
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE6_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m
tmux select-pane -t 6
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE7_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m
tmux select-pane -t 7
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE8_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m

tmux select-pane -t 0
tmux attach