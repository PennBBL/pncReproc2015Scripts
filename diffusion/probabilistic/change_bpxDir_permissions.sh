#!/bin/sh

# this script by MQ, DRR, and GLB (10/28/15) runs bedpostx using subject specific motion and distortion corrected files.

# Path to diffusion data (input to bedpostx)
path=/data/jag/BBL/studies/pnc/processedData/diffusion/probabilistic

#for each subject in the list of subjects/timepoints that passed DTI QA (from DRR on dtipipe channel on slack 9/10/15)...
	for i in `cat /data/jag/BBL/studies/pnc/subjectData/to_be_run_bedpostX.csv`; do
	
	#create variables for bblid,scanid and the date of scan (day, month, year) (directory structure is bblid/dateofscanxscanid)
	bblid=`echo $i | cut -d "," -f 1`
	scanid=`echo $i | cut -d "," -f 2`
	day=`echo $i | cut -d "," -f 3 | cut -d "/" -f 2`
	month=`echo $i | cut -d "," -f 3 | cut -d "/" -f 1`
	year=`echo $i | cut -d "," -f 3 | cut -d "/" -f 3`
	datexscanid=`echo "20"$year$month$day"x"$scanid`

	echo "........................... Processing subject "$bblid $scanid
	

# Set path variables

bpX_dir=$path/$bblid/$datexscanid


chmod -R 775 /data/jag/BBL/studies/pnc/processedData/diffusion/probabilistic/



done

