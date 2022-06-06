#! /bin/sh

echo ----------------------------
echo rclone sync command
rclone sync uniprot:/pub/databases/uniprot/ --exclude /previous_releases/ --exclude /previous_major_releases/ oss_prod:uniprot/ -v --log-file uniprot_current_release_rclone_dryrun.log --dry-run
