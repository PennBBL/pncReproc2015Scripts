#checks to make sure every subject has an MPRAGE at every timepoint and is named appropriately

dirList=$(ls -d /data/jag/BBL/studies/pnc/rawData/*/*/)
logfile=/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/reOrg/logs/t1Missing.txt
rm -f $logfile

for d in $dirList; do
	echo ""
	echo $d

	#get paths, ids
	bblid=$(echo $d | cut -d/ -f8)
        sessionid=$(echo $d | cut -d/ -f9)
        outname=${bblid}_${sessionid}_t1.nii.gz


	outfile=$(ls $d/mprage*/$outname 2> /dev/null)
	if [ -e "$outfile" ]; then
		echo "mprage present"
		continue
	else
		echo "MPRAGE MISSING-- WILL LOG!!"
		echo ${bblid}_${sessionid} >> $logfile
	fi

done
