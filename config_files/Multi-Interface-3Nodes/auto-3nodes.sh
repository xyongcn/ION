#!/bin/sh

NODE1_IP="s2"
NODE2_IP="s1"
NODE3_IP="l1"

BPCONFIG="bpconfig.conf"

CONFIG1="Multi-Interface-Node1-S2.conf"
CONFIG2="Multi-Interface-Node2-S1.conf"
CONFIG3="Multi-Interface-Node3-L1.conf"

USERNAME="wjbang"

CONFIG_LOC=/home/${USERNAME}/3nodes
PASSWORD_FILE="password"

set -x

sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE1_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE2_IP} "mkdir ${CONFIG_LOC}"
sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE3_IP} "mkdir ${CONFIG_LOC}"

sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG1} ${USERNAME}@[${NODE1_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG2} ${USERNAME}@[${NODE2_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${CONFIG3} ${USERNAME}@[${NODE3_IP}]:${CONFIG_LOC}

sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE1_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE2_IP}]:${CONFIG_LOC}
sshpass -f ${PASSWORD_FILE} scp -o StrictHostKeyChecking=no ${BPCONFIG} ${USERNAME}@[${NODE3_IP}]:${CONFIG_LOC}

tmux kill-session
tmux kill-session

tmux new-session -d -s 3nodes
tmux split-window -h -p 67
tmux split-window -h

tmux set-option -t 3nodes mouse-select-pane on

tmux select-pane -t 0 
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE1_IP}" C-m
#tmux send-keys "set -x" C-m
tmux send-keys "ionstop" C-m
tmux send-keys "ionstart -I ${CONFIG_LOC}/${CONFIG1}" C-m
tmux send-keys "bpadmin ${CONFIG_LOC}/${BPCONFIG}" C-m
tmux send-keys "clear" C-m

tmux send-keys "sleep 5" C-m
tmux send-keys "md5sum /home/wjbang/ION/tcpclo" C-m
tmux send-keys "bpsendfile ipn:1.1 ipn:3.1 /home/wjbang/ION/tcpclo" C-m
tmux send-keys "bprecvfile ipn:1.1 1" C-m
tmux send-keys "md5sum testfile1" C-m

tmux select-pane -t 1 
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE2_IP}" C-m
#tmux send-keys "set -x" C-m
tmux send-keys "ionstop" C-m
tmux send-keys "ionstart -I ${CONFIG_LOC}/${CONFIG2}" C-m
tmux send-keys "bpadmin ${CONFIG_LOC}/${BPCONFIG}" C-m
tmux send-keys "clear" C-m

#tmux send-keys "tail -f ${CONFIG_LOC}/scriptlog" C-m

tmux select-pane -t 2
tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE3_IP}" C-m
#tmux send-keys "set -x" C-m
tmux send-keys "ionstop" C-m
tmux send-keys "ionstart -I ${CONFIG_LOC}/${CONFIG3}" C-m
tmux send-keys "bpadmin ${CONFIG_LOC}/${BPCONFIG}" C-m
tmux send-keys "clear" C-m

tmux send-keys "bprecvfile ipn:3.1 1" C-m
tmux send-keys "md5sum testfile1" C-m
tmux send-keys "bpsendfile ipn:3.1 ipn:1.1 testfile1" C-m

#tmux send-keys "sshpass -f ${PASSWORD_FILE} ssh -o StrictHostKeyChecking=no ${USERNAME}@${NODE2_IP} \"tail -f ${CONFIG_LOC}/scriptlog\"" C-m

tmux select-pane -t 0
tmux attach
