#!/bin/bash
set -e

TARGET=/var/lib/collectd/rrd/
RUNFOLDER=/run/collectd/

if ! [[ -d "$RUNFOLDER/localhost" ]] || (( "$(find "$RUNFOLDER/localhost" | wc -l)" < 15 )); then
    echo "$RUNFOLDER/localhost doesn't have the expected minimum number of files or doesn't exist!"
    echo "not writing contents to disk!"
    exit 1
fi

echo "writing DB from $RUNFOLDER to disk"

tar --directory "$RUNFOLDER" -cz -f "$RUNFOLDER/localhost.tar.gz" localhost

mv -T "$TARGET/localhost.tar.gz" "$TARGET/auto-backup-$(date +%Y-week_%V).tar.gz" &>/dev/null || true
find "$TARGET" -name 'auto-backup-*.tar.gz' -mtime +60 -delete
cp -fT "$RUNFOLDER/localhost.tar.gz" "$TARGET/localhost.tar.gz"

# remove legacy stuff
rm -rf "$TARGET/graphs1090-writeback-backup1" "$TARGET/graphs1090-writeback-backup2"
# remove localhost folder as it would be used with preference in the readback instead of localhost.tar.gz
rm -rf "$TARGET/localhost"

sync
