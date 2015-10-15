#renames raw T1 data into a more consistent directory structure i.e. bblid/datexscanid/mprage/bblid_datexscanid_t1.nii.gz

dirList=$(ls -d /data/jag/BBL/studies/pnc/rawData/*/*/MPRAGE_TI1110_ipat2_moco3)
logfile=/data/jag/BBL/projects/pncTemplate/logs/rawDataMocoLog.txt
rm -f $logfile

for d in $dirList; do
	echo ""
	echo $d

	#get paths, ids
	sessionDir=$(dirname $d)
	bblid=$(echo $d | cut -d/ -f8)
        sessionid=$(echo $d | cut -d/ -f9)
        outname=${bblid}_${sessionid}_t1.nii.gz

	#rename mpragedir
	mv $d $sessionDir/mprage_moco3


	outfile=$(ls $sessionDir/mprage_moco3/$outname 2> /dev/null)
	if [ -e "$outfile" ]; then
		echo "output already present"
		continue
	fi

	image=$(ls $sessionDir/mprage_moco3/nifti/*nii.gz)
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
	
	mv $image $sessionDir/mprage_moco3/$outname
	#will remove empty directory "nifti" separately
done
