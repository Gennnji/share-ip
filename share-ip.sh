#!/bin/bash

remote_server=$1
remote_port=`echo $remote_server | awk -F":" '{print $2}'`
remote_server=`echo $remote_server | awk -F":" '{print $1}'`
ssh_key=$2
remote_path_ip='/var/log/share-ip'
# TODO: есть опасность, что скрипт будет использоваться на нескольких серверах с одинаковыми именами -> надо будет что-то придумать
remote_file_ip="`hostname`.ip"

function howTo() {
    echo 'Share IP by @Genji'
    echo 'Скрипт, сообщающий о своём ip другому серверу'
    echo "Путь к файлу ip по умолчанию: $remote_path_ip/$remote_file_ip"
    echo 'Пример использования: ./share-ip.sh [<Имя пользователя>@]<Имя сервера|IP сервера>[:<Порт>] [<Путь к файлу ssh-ключа>]'
}

if [ -z "$remote_server" ]; then
    echo "[`date`] Ошибка: Не указан сервер, которому нужно сообщить ip"
    howTo
    exit 1
fi

if [ -n "$ssh_key" ]; then
    ssh_key="-i $ssh_key"
fi
echo $ssh_key
if [ -n "$remote_port" ]; then
    remote_port="-p $remote_port"
fi

IP=`dig +short myip.opendns.com @resolver1.opendns.com`

echo "IP: $IP"

echo "ssh $ssh_key $remote_server $remote_port 'mkdir -p $remote_path_ip && echo $IP > $remote_path_ip/$remote_file_ip'"
config=`ssh $ssh_key $remote_server $remote_port "mkdir -p $remote_path_ip && echo $IP > $remote_path_ip/$remote_file_ip"`
if [ $? -gt 0 ]; then
    echo "[`date`] Ошибка: Попытка соединения с удаленным сервером не удалась"
    howTo
    exit 1
fi

exit 0
