#!b/in/bash

# This script requires you to have already pre-installed and configured rclone,
# docker compose for all containers and have a list of directories and files
# to backup. It will stop all containers for the duration of the backup and
# restore it at the end, updating them all as part of the process.
# You should also already have initialised the borg repo with the given
# passphrase contained in the file.

# Fill up all <> placeholders with your own configs
DOCKER_COMPOSE_DIR=<docker-compose-root-dir>
BACKUP_FILES_FILE=<text-file-with-files-or-dirs-to-backup>
BACKUP_REPO_DIR=<local-borg-repo>
REMOTE_BACKUP_REPO_DIR=<remote-borg-repo>
PASSPHRASE_FILE=<gpg-passphrase-file>
BACKUP_PREFIX=<backup-file-prefix>


NECESSARY_FILES=($DOCKER_COMPOSE_DIR $BACKUP_FILES_FILE $BACKUP_REPO_DIR $PASSPHRASE_FILE)
BACKUPS_TO_KEEP=10

export BORG_PASSPHRASE=$(cat $PASSPHRASE_FILE)
export BORG_REPO=$BACKUP_REPO_DIR

# Validation
for file in "${NECESSARY_FILES[@]}"; do
  if [ ! -e "$file" ]; then
    echo "$file not found. Exitting."
    exit 1
  fi
done

# Pull new versions
echo "Pulling  containers"
find $DOCKER_COMPOSE_DIR -mindepth 1 -type d -exec bash -c "cd '{}' && docker-compose pull" \;

# Stop docker containers
echo "Stopping containers"
find $DOCKER_COMPOSE_DIR -mindepth 1 -type d -exec bash -c "cd '{}' && docker-compose down" \;

# Create backup in repo
echo "Backing up files in $BACKUP_FILES_FILE to borg reop"
borg create --stats --compression zstd,6 --exclude-caches $BORG_REPO::"$BACKUP_PREFIX-{now}" $(cat $BACKUP_FILES_FILE)

# Start docker containers
echo "Starting containers"
find $DOCKER_COMPOSE_DIR -mindepth 1 -type d -exec bash -c "cd '{}' && docker-compose up -d" \;

# Pruning the repo
borg prune --keep-last $BACKUPS_TO_KEEP
borg compact

# Sync backup dir to remote
echo "Syncing $BACKUP_REPO_DIR to $REMOTE_BACKUP_REPO_DIR"
rclone sync $BACKUP_REPO_DIR $REMOTE_BACKUP_REPO_DIR
