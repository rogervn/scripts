#!/bin/bash

# This script requires you to have already pre-installed and configured rclone,
# docker compose for all containers and have a list of directories and files
# to backup. It will stop all containers for the duration of the backup and
# restore it at the end, updating them all as part of the process.
# A gpg passphrase will be used for encryption and should be long enough to provide
# good security.

# Fill up all <> placeholders with your own configs
DOCKER_COMPOSE_DIR=<docker-compose-root-dir>
BACKUP_FILES_FILE=<text-file-with-files-or-dirs-to-backup>
BACKUP_DIR=<local-directory-to-store-backups>
REMOTE_BACKUP_DIR=<rclone-format-remote-backup-dir>
PASSPHRASE_FILE=<gpg-passphrase-file>

NECESSARY_FILES=($DOCKER_COMPOSE_DIR $BACKUP_FILES_FILE $BACKUP_DIR $PASSPHRASE_FILE)
BACKUP_PREFIX=<backup-file-prefix>
BACKUPS_TO_STORE_PLUS1=11  # We store 10 backups

# Validation
for file in "${NECESSARY_FILES[@]}"; do
  if [ ! -e "$file" ]; then
    echo "$file not found. Exitting."
    exit 1
  fi
done

# Stop docker containers
echo "Stopping containers"
find $DOCKER_COMPOSE_DIR -mindepth 1 -type d -exec bash -c "cd '{}' && docker compose down" \;

# Compress and encrypt files, keeping only the latest
current_time=$(date "+%Y%m%d-%H%M%S")
backup_filename="$BACKUP_PREFIX$current_time.backup"

echo "Backing up files in $BACKUP_FILES_FILE to $backup_filename"
tar czf - -T $BACKUP_FILES_FILE | gpg --symmetric --batch --passphrase "$(cat $PASSPHRASE_FILE)" 1> /dev/null > $BACKUP_DIR/$backup_filename

# Start docker containers
echo "Starting containers"
find $DOCKER_COMPOSE_DIR -mindepth 1 -type d -exec bash -c "cd '{}' && docker compose up -d" \;

# Sync backup dir to remote
echo "Cleaning up old backups"
ls -td $BACKUP_DIR/* | tail -n +$BACKUPS_TO_STORE_PLUS1 | xargs rm -f || true
echo "Syncing $BACKUP_DIR to $REMOTE_BACKUP_DIR"
rclone sync $BACKUP_DIR $REMOTE_BACKUP_DIR
