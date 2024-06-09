while read x; do
	item=$(echo "$x" | sed -r "s|$BASE_MOUNT||g")
	if [ -n "$item" ]; then
		if [ -d "$BASE_MOUNT$item" ]; then
			mkdir -p /tmp$item
		else
			cp -v $BASE_MOUNT$item /tmp$item
		fi
	fi
done

if [ "$(ls -A '/tmp')" ]; then
	find /tmp -empty -type d -delete
	s3cmd \
		--host-bucket "%(bucket)s.$S3_URL" \
		-P \
		put /tmp/* s3://$S3_BUCKET/ --recursive

	rm -Rf /tmp/*
fi
