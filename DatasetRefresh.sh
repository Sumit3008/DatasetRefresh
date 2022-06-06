#! /bin/sh

displayPercentCompleted() {
	echo ----------------------------
	echo grep Transferred
	grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1
}

displayLogFile() {
	echo ----------------------------
	echo display log file
	cat uniprot_current_release_rclone_dryrun.log
}

rcloneSync2() {
	echo ----------------------------
	echo rclone sync command
	retry=2
	while
		rclone sync uniprot:/pub/databases/uniprot/ --exclude /previous_releases/ --exclude /previous_major_releases/ --exclude /current_release --exclude /knowledgebase/ oss_prod:uniprot/ -v --log-file uniprot_current_release_rclone_dryrun.log --dry-run
		: percentageTransferred="$(grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1 | awk '{print $NF}' | rev | cut -c2- | rev)"
		complete="100"
		echo "Percentage Transferred : "
		echo $percentageTransferred
		(("$percentageTransferred" != "$complete" || --retry >= 0))
	do :; done
}

rcloneSync() {
	echo ----------------------------
	echo rclone sync command
	#rclone sync uniprot:/pub/databases/uniprot/ --exclude /previous_releases/ --exclude /previous_major_releases/ --exclude /current_release/ --exclude /knowledgebase/ oss_prod:uniprot/ -v --log-file uniprot_current_release_rclone_dryrun.log --dry-run
	#rclone sync uniprot:/pub/databases/uniprot/ --exclude /previous_releases/ --exclude /previous_major_releases/ --exclude /current_release/ oss_prod:uniprot/ -v --log-file uniprot_current_release_rclone_dryrun.log --dry-run
	rclone sync $1 --exclude /previous_releases/ --exclude /previous_major_releases/ --exclude /current_release/ oss_prod:uniprot/ -v --log-file uniprot_current_release_rclone_dryrun.log --dry-run
}

copyLogFile() {
	rclone copy uniprot_current_release_rclone_dryrun.log oss_prod:refreshTest
}

refreshDataset() {
	rcloneSync $2
	percentageTransferred="$(grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1 | awk '{print $NF}' | rev | cut -c2- | rev)"
	complete="100"
	echo "Percentage Transferred : "
	echo $percentageTransferred
	copyLogFile
	retry=$1
	while [ "$percentageTransferred" != "$complete" ] && [ $retry -le 2 ]
	do
		retry=$(( $retry + 1 ))
		rcloneSync $2
		percentageTransferred="$(grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1 | awk '{print $NF}' | rev | cut -c2- | rev)"
		echo "Percentage Transferred : "
		echo $percentageTransferred
	done
}

listDestinationDirectory() {
	echo ----------------------------
	echo list destination directory
	rclone lsd oss_prod:/
}

listSourceDirectory() {
	echo ----------------------------
	echo list source directory
	rclone lsd uniprot:/
}

showRcloneConfig() {
	echo ----------------------------
	echo rclone config show
	rclone config show
}

updateConfigFile() {
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
}

createRcloneConfigFile() {
	echo ----------------------------
	echo touch /root/.config/rclone/rclone.conf
	touch /root/.config/rclone/rclone.conf
}

moveRcloneConfigFile() {
	echo ----------------------------
	echo moving rclone config filefrom /rclone.conf to /root/.config/rclone/rclone.conf
	mv /rclone.conf /root/.config/rclone/rclone.conf
}

checkRcloneVersion() {
	echo ----------------------------
	echo check rclone version
	rclone version
}

executablePermissionsToDirectory() {
	echo ----------------------------
	echo chmod 755 the rclone folder
	sudo chmod 755 /usr/bin/rclone
}

#Giving rclone folder root permissions
chownRcloneDirectory() {
	echo ----------------------------
	echo Giving rclone folder root permissions
	sudo chown root:root /usr/bin/rclone
}

#copy rclone binary to /usr/bin
copyRcloneBinary() {
	cd rclone-*-linux-amd64
	#ls
	echo ----------------------------
	echo copying rclone to /usr/bin
	sudo cp rclone /usr/bin/
}

#Unzipping the rclone binary
unzipRcloneBinary() {
	echo Unzipping the rclone binary
	unzip rclone-current-linux-amd64.zip
}

#Curl command to fetch the rclone binary
curlToFetchRcloneBinary() {
	echo Curl command to fetch the rclone binary
	curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
}

setupRclone() {
	$1
	curlToFetchRcloneBinary
	unzipRcloneBinary
	copyRcloneBinary
	chownRcloneDirectory
	executablePermissionsToDirectory
	checkRcloneVersion
	#createRcloneConfigFile
	#updateConfigFile
	moveRcloneConfigFile
	showRcloneConfig
	listSourceDirectory
	listDestinationDirectory
	refreshDataset $2 $3

}

echo $env1
echo $envSyncCommandDataset
setupRclone $env1 $envRetryCount $envSyncCommandDataset

#percentageTransferred="$(grep Transferred uniprot_current_release_rclone_dryrun.log | tail -1 | awk '{print $NF}' | rev | cut -c2- | rev)"
#echo $percentageTransferred
#complete="100"
#if [ "$percentageTransferred" = "$complete" ]; then
#    echo "Strings are equal."
#else
#    echo "Strings are not equal."
#fi

