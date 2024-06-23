# Use the official Python image
FROM python:3.9-alpine

# Install required packages
RUN apk add --no-cache postgresql-client git bash

# Copy the backup script
COPY backup_script.sh /usr/local/bin/backup_script.sh

# Make the script executable
RUN chmod +x /usr/local/bin/backup_script.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/backup_script.sh"]
