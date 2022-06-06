#! /bin/sh

echo Curl to fetch rclone binary

curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip

echo Unzip the binary

unzip rclone-current-linux-amd64.zip

echo cd to the dir

cd rclone-*-linux-amd64

echo ls

ls

echo ----------------------------
echo copying rclone to /usr/bin
sudo cp rclone /usr/bin/

echo ----------------------------
echo chown root the rclone folder
sudo chown root:root /usr/bin/rclone

echo ----------------------------
echo chmod 755 the rclone folder
sudo chmod 755 /usr/bin/rclone

echo ----------------------------
echo check rclone version
rclone version

echo ----------------------------
echo touch /root/.config/rclone/rclone.conf
touch /root/.config/rclone/rclone.conf

echo ----------------------------
echo adding uniprot config
echo "[uniprot]" >> /root/.config/rclone/rclone.conf
echo "type = http" >> /root/.config/rclone/rclone.conf
echo "url = https://ftp.uniprot.org/" >> /root/.config/rclone/rclone.conf
echo "" >> /root/.config/rclone/rclone.conf
echo "[oss_prod]" >> /root/.config/rclone/rclone.conf
echo "type = s3" >> /root/.config/rclone/rclone.conf
echo "provider = Other" >> /root/.config/rclone/rclone.conf
echo "access_key_id = ..." >> /root/.config/rclone/rclone.conf
echo "secret_access_key = ..." >> /root/.config/rclone/rclone.conf
echo "endpoint = https://idcxvbiyd8fn.compat.objectstorage.us-ashburn-1.oraclecloud.com/" >> /root/.config/rclone/rclone.conf
echo "location_constraint = us-ashburn-1" >> /root/.config/rclone/rclone.conf
echo "acl = private" >> /root/.config/rclone/rclone.conf

echo ----------------------------
echo rclone config show
rclone config show

echo ----------------------------
echo rclone lsd uniprot:/
rclone lsd uniprot:/

echo ----------------------------
echo rclone lsd oss_prod:/
rclone lsd oss_prod:/

echo ----------------------------
echo pwd
pwd

echo ----------------------------
echo sh ./retrySync.sh
sh ./rclone-v1.58.1-linux-amd64/retrySync.sh

echo ----------------------------
echo rclone sync command
rclone sync uniprot:/pub/databases/uniprot/ --exclude /previous_releases/ --exclude /previous_major_releases/ oss_prod:uniprot/ -v --log-file uniprot_current_release_rclone_dryrun.log --dry-run

echo ----------------------------
echo cat
cat uniprot_current_release_rclone_dryrun.log

echo ----------------------------
echo grep Transferred
grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1

percentageTransferred="$(grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1 | awk '{print $NF}' | rev | cut -c2- | rev)"
echo $percentageTransferred
complete="100"
if [ "$percentageTransferred" = "$complete" ]; then
    echo "Strings are equal."
else
    echo "Strings are not equal."
fi

