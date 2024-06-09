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
	dirs=$(echo $SUBFOLDERS | tr "," "\n")
	for dir in $dirs; do
		folder="$folder $BASE_MOUNT/$dir"
	done
else
	folder="$BASE_MOUNT"
fi

if [ -n "$STARTUP_SYNC" ]; then
	echo "First synchronization"
	args="$folder"

	if [ "$EXCLUDE" ]; then
		exts=$(echo $EXCLUDE | tr "," "\n")
		for ext in $exts; do
			args="$args ! -name '*.$ext'"
		done
	fi

	eval "find $args" | sh ./files-to-cdn.sh
fi


args="-1rl 5"

if [ "$EXCLUDE" ]; then
	extensions=$(echo $EXCLUDE | tr "," "\n")
	for extension in $extensions; do
		args="$args -e '\.$extension$'"
	done
fi

args="$args $folder"
while true; do
	eval "fswatch $args" | sh ./files-to-cdn.sh
done
