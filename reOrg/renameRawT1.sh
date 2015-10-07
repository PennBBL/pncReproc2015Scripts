#renames raw T1 data into a more consistent directory structure i.e. bblid/datexscanid/mprage/bblid_datexscanid_t1.nii.gz

dirList=$(ls -d /data/jag/BBL/studies/pnc/rawData/*/*/mprage)
logfile=/data/jag/BBL/projects/pncTemplate/logs/rawDataLog.txt
rm -f $logfile

for d in $dirList; do
	echo ""
	echo $d

	bblid=$(echo $d | cut -d/ -f8)
        sessionid=$(echo $d | cut -d/ -f9)
        outname=${bblid}_${sessionid}_t1.nii.gz
	outfile=$(ls $d/$outname 2> /dev/null)
	if [ -e "$outfile" ]; then
		echo "output already present"
		continue
	fi

	image=$(ls $d/nifti/*nii.gz)
	echo $image
	numImg=$(echo $image | wc | awk '{print $2}')
	echo $numImg
	if [ "$numImg" -gt 1 ]; then
		echo "more than one mprage found!!!"
		echo "$d >> $logfile"
	fi
	if [ ! -e "$image" ]; then
		echo "no mprage found"
                echo "$d >> $logfile"
	fi
	
	mv $image $d/$outname
	#will remove empty directory "nifti" separately
done
