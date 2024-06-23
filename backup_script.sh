#!/bin/bash

# Check if required environment variables are set
if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_HOST" ] || [ -z "$REPO_DIR" ] || [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPO" ]; then
  echo "One or more required environment variables are not set."
  exit 1
fi

# Variables
BACKUP_DIR="/backup/backups"
BACKUP_FILE="$BACKUP_DIR/$(date +%Y%m%d%H%M%S)_backup.sql"
COMMIT_MSG="Database backup $(date +%Y-%m-%d)"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Export the PostgreSQL password
export PGPASSWORD=$DB_PASSWORD

# Dump the database to a file
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -b -v -f $BACKUP_FILE


git config --global user.email "nishant.poonia6396@gmail.com"
git config --global user.name "poonia6396"


# Clone the repo if it doesn't exist
if [ ! -d "$REPO_DIR/.git" ]; then
  git clone https://$GITHUB_TOKEN@github.com/$GITHUB_REPO.git $REPO_DIR
fi

mkdir -p $REPO_DIR/backups

# Copy the backup file to the repo
cp $BACKUP_FILE $REPO_DIR/backups

# Navigate to the repo directory
cd $REPO_DIR

# Add, commit, and push the backup file to GitHub
git add backups/$(basename $BACKUP_FILE)
git commit -m "$COMMIT_MSG"
git push origin main

# Clean up old backups (optional)
find $BACKUP_DIR -type f -mtime +7 -name '*_backup.sql' -exec rm {} \;

# Unset the PostgreSQL password
unset PGPASSWORD
