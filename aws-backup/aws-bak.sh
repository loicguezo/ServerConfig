#!/bin/bash

# change to your aws-server name
AWS="<AWS-server Name>"

BACKUP="$(cd "$(dirname "$0")" && pwd)/backup_file.bak"
LOG="/var/log/save-aws.log"

date_print() {
    echo -n "$(date +"%Y-%m-%d %H:%M:%S") - " | tee -a $LOG
}

error_print() {
    date_print
    if [ "$1" ]; then
        echo -n "Backup error $2 -/> s3://$AWS : " | tee -a "$LOG"
    else
        echo -n "Backup succeeded --> s3://$AWS : " | tee -a "$LOG"
    fi
}

if [ -n "$1" ]; then
    AWS="$1"
fi

if [ ! -e "$BACKUP" ]; then
    touch "$BACKUP"
    error_print true "$BACKUP"
    echo "$BACKUP created. Please include only the dirname in this file." | tee -a "$LOG"
    exit 1
fi

while IFS= read -r SOURCE_PATH || [ -n "$SOURCE_PATH" ]; do
    if [ -d "$SOURCE_PATH" ] || [ -f "$SOURCE_PATH" ]; then
        aws s3 sync "$SOURCE_PATH" "s3://$AWS/$(basename "$SOURCE_PATH")" --delete

        if [ $? -ne 0 ]; then
            error_print true "$SOURCE_PATH"
            echo "Error while syncing $SOURCE_PATH to the AWS server." | tee -a "$LOG"
            exit 1
        fi
    else
        error_print true "$SOURCE_PATH"
        echo "$SOURCE_PATH not found or inaccessible." | tee -a "$LOG"
    fi
done < "$BACKUP"

error_print false ""
echo "All files synced to AWS." | tee -a "$LOG"