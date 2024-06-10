[ -z "$S3_URL" ] && { echo "Need to set S3_URL"; exit 1; }
[ -z "$S3_BUCKET" ] && { echo "Need to set S3_BUCKET"; exit 1; }
[ -z "$S3_ACCESS_KEY" ] && { echo "Need to set S3_ACCESS_KEY"; exit 1; }
[ -z "$S3_SECRET" ] && { echo "Need to set S3_SECRET"; exit 1; }
if [ -z "$BASE_MOUNT" ]; then
	export BASE_MOUNT=/mnt/data
fi

export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$S3_SECRET

if [ -n "$STARTUP_DELAY" ]; then
	echo "Delaying startup for $STARTUP_DELAY seconds..."
	sleep "$STARTUP_DELAY"
	echo "Resuming startup"
fi

folder=""
if [ "$SUBFOLDERS" ]; then
	echo "Watching the following folders:"
	dirs=$(echo $SUBFOLDERS | tr "," "\n")
	for dir in $dirs; do
		echo $dir
		folder="$folder $BASE_MOUNT/$dir"
	done
else
	folder="$BASE_MOUNT"
fi

if [ -n "$STARTUP_SYNC" ]; then
	args="$folder"

	echo "Starting first synchronization..."
	eval "find $args" | sh ./files-to-cdn.sh
	echo "First synchronization finished."
fi


args="-1rl 5"

args="$args $folder"
while true; do
	eval "fswatch $args" | sh ./files-to-cdn.sh
done
