#!/bin/bash

# change to your aws-server name
AWS="<AWS-server Name>"

BACKUP="$(cd "$(dirname "$0")" && pwd)/aws-bakup.bak"
LOG="/var/log/aws-bak.log"

SYNCED_FILES=""

date_print() {
    echo -n "$(date +"%d-%m-%Y %H:%M:%S") - " | tee -a $LOG
}

error_print() {
    date_print
    if [ "$1" == "true" ]; then
        echo "Backup error $2 -/> s3://$AWS : " | tee -a "$LOG"
    else
        echo "Backup succeeded --> s3://$AWS : " | tee -a "$LOG"
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
    if [ -z "$SOURCE_PATH" ] || [[ "$SOURCE_PATH" =~ ^[[:space:]]*$ ]]; then
        continue
    fi

    if [ -d "$SOURCE_PATH" ] || [ -f "$SOURCE_PATH" ]; then
        aws s3 sync "$SOURCE_PATH" "s3://$AWS/$(basename "$SOURCE_PATH")" --delete

        if [ $? -ne 0 ]; then
            error_print true "$SOURCE_PATH"
            echo "Error while syncing $SOURCE_PATH to the AWS server." | tee -a "$LOG"
            exit 1
        fi

        SYNCED_FILES="$SYNCED_FILES\n$SOURCE_PATH"
    else
        error_print true "$SOURCE_PATH"
        echo "$SOURCE_PATH not found or inaccessible." | tee -a "$LOG"
    fi
done < "$BACKUP"

if [ -n "$SYNCED_FILES" ]; then
    error_print false ""
    echo -e "Files synced:$SYNCED_FILES" | tee -a "$LOG"
else
    echo "No files synced." | tee -a "$LOG"
    exit 0;
fi

echo "All files synced to AWS." | tee -a "$LOG"