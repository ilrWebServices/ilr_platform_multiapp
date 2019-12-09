#!/usr/bin/env bash

# This script is intended to run via cron on platform.sh
# From https://gitlab.com/contextualcode/platformsh-store-logs-at-s3

# Configured via environment variables. Sensitive vars are set on platform:
# platform variable:create --level=project --name=AWS_ACCESS_KEY_ID --value=<KEY_ID> --json=false --sensitive=true --prefix=env --visible-build=true --visible-runtime=true
# platform variable:create --level=project --name=AWS_SECRET_ACCESS_KEY --value=<ACCESS_KEY> --json=false --sensitive=true --prefix=env --visible-build=true --visible-runtime=true

# Non-sensitive vars are set in ../.environment.

cd $LOGS_TMP_PATH
TODAY_DATE=$(date +%Y-%m-%d)

# This is the name of the log file for a given day.
LOG_FILE=${PLATFORM_PROJECT}-${PLATFORM_APPLICATION_NAME}-${TODAY_DATE}-access.log

# Copy the log file from S3.
aws s3 cp s3://${LOGS_S3_BUCKET}/${LOGS_S3_FOLDER}/${LOG_FILE}.gz ./${LOG_FILE}.gz --quiet

# Unzip the log file, if there was one stored on S3 for today.
if [ -f ./${LOG_FILE}.gz ]; then
  gunzip ./${LOG_FILE}
fi

# If there is no log file for today, create one.
if [ ! -f ./${LOG_FILE} ]; then
  touch ./${LOG_FILE}
fi

# Filter out log entries for today.
cat /var/log/access.log | grep $(date +%d/%b/%Y:) > ./today.log

# Get the new log entries.
diff --changed-group-format='%>' --unchanged-group-format='' $LOG_FILE today.log > new.log

# Append the new log entries to the log file for today.
cat new.log >> $LOG_FILE

# Compress the updated log file.
gzip ./${LOG_FILE}

# Copy the updated, compressed log file back to S3.
aws s3 cp ./${LOG_FILE}.gz s3://${LOGS_S3_BUCKET}/${LOGS_S3_FOLDER}/${LOG_FILE}.gz --quiet

# Clean up.
rm today.log new.log ${LOG_FILE}.gz
