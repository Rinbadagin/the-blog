#!bash

# Configuration
APP_DIR="storage"
BUCKET_NAME="backup-bucket"
NAMESPACE="sdnafdgym8g3"

# Check if a timestamp argument is provided
if [ ! $# -eq 2 ]; then
	echo "Please provide the backup timestamp & bucket prefix to restore from."
	echo "Usage: $0 <bucket-prefix> <timestamp>"
	exit 1
fi

TIMESTAMP=$1

# Create a temporary directory for download
TEMP_DOWNLOAD_DIR=$(mktemp -d)

# Download the backup from Oracle Cloud Storage
echo "Downloading backup from Oracle Cloud Storage..."
oci os object bulk-download \
	--namespace $NAMESPACE \
	--bucket-name "$1-$BUCKET_NAME" \
	--download-dir "$TEMP_DOWNLOAD_DIR" \
	--prefix "backups/$TIMESTAMP"

# Check if the download was successful
if [ ! -d "$TEMP_DOWNLOAD_DIR/backups/$TIMESTAMP" ]; then
	echo "Error: Backup not found or download failed."
	rm -rf "$TEMP_DOWNLOAD_DIR"
	exit 1
fi

# Restore the SQLite database
echo "Restoring SQLite database..."
sqlite3 "$APP_DIR/production.sqlite3" ".restore '$TEMP_DOWNLOAD_DIR/backups/$TIMESTAMP/sqlite_backup_$TIMESTAMP.sqlite3'"

# Restore application files
echo "Restoring application files..."
rsync -av --delete \
	"$TEMP_DOWNLOAD_DIR/backups/$TIMESTAMP/" \
	"$APP_DIR/"

# Clean up the temporary directory
rm -rf "$TEMP_DOWNLOAD_DIR"

echo "Restore completed successfully."
