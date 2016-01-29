#MQ November 6, 2015
#This script will be used to create aggregate files with CNR and Euler number values for the GO1/GO2 freesurfer version 5.3 re-run (November 2015). 
#The methods for this script were obtained from Chalavi, et al, BMC medical Imaging, 2012. doi:10.1186/1471-2342-12-27.(http://www.biomedcentral.com/1471-2342/12/27). 
#Previous BBL scripts to calculate cnr only pulled the total cnr, in this script we pull total, gray/csf for left and right hemispheres and gray/white for both hemispheres in addition to calculating the euler number (tells how many holes/defects are in the surface) as is done in the methods of the Chalavi, et al paper

#! /bin/bash
#set freesurfer specific variables (unique to GO1/GO2 and cfn)
export SUBJECTS_DIR=/data/jag/BBL/studies/pnc/processedData/structural/freesurfer53
export QA_TOOLS=/data/jag/BBL/applications/QAtools_v1.1/
export FREESURFER_HOME=/share/apps/freesurfer/5.3.0/
export PATH=$FREESURFER_HOME/bin/:$PATH

#set subject list, directory to output aggregated files to, and the filenames of those aggregate files
slist=/data/jag/BBL/studies/pnc/subjectData/go1_go2_freesurfer53_qa_run_list.txt
outdir=/data/jag/BBL/projects/pncReproc2015/freesurfer/stats5_3/cnr
file=$outdir/cnr_buckner.csv
euler_file=$outdir/euler_number.csv

#create the aggregate files for cnr and euler
echo "bblid,scanid,total,graycsflh,graycsfrh,graywhitelh,graywhiterh" > $file
echo "bblid,scanid,left_euler,right_euler" > $euler_file

#for each subject in the subject list, get bblid, scanid (note it is actually datexscanid) and their surf and mri directories
for i in $(cat $slist);do
	bblid=$(echo $i | cut -d"/" -f1)
	scanid=$(echo $i | cut -d"/" -f2)
	echo "working on subject" $i
	surf=`ls -d $SUBJECTS_DIR/$i/surf`
	mri=`ls -d $SUBJECTS_DIR/$i/mri`
		###############CNR#######################		
		#calculate cnr for each subject and output all measures to a file in their stats folder
		mri_cnr $surf $mri/orig.mgz > $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_cnr.txt"
		#create variables for total cnr, gray/csf for left and right hemispheres and gray/white for left and right hemispheres (total and cnr variables are grepping the information from the subject specific file, the 			variables then need to be cut in order to get just the number)
		total=`grep "total CNR" $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_cnr.txt"`
		total2=`echo $total |cut -f 4 -d " "`
		cnr=`grep "gray/white CNR" $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_cnr.txt"`
		graycsflh=`echo $cnr | cut -d "," -f 2 | cut -d "=" -f 2 | cut -d " " -f 2`
		graycsfrh=`echo $cnr | cut -d "," -f 3 | cut -d "=" -f 2 | cut -d " " -f 2`
		graywhitelh=`echo $cnr | cut -d "," -f 1 | cut -d "=" -f 2 | cut -d " " -f 2`
		graywhiterh=`echo $cnr | cut -d "," -f 2 | cut -d "=" -f 3 | cut -d " " -f 2`
		#append this subject's data to the aggregate file
		echo $bblid,$scanid,$total2,$graycsflh,$graycsfrh,$graywhitelh,$graywhiterh >> $file
		
		###############EULER NUMBER#######################
		#calculate the euler number and output left and right hemisphere euler numbers to a file in their stats folder
		script -c "mris_euler_number $surf/lh.orig.nofix" $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_lh_euler.txt"
		script -c "mris_euler_number $surf/rh.orig.nofix" $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_rh_euler.txt"
		#create variables for left and right euler numbers
		left=`grep ">" $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_lh_euler.txt" | cut -d ">" -f 1 | cut -d "=" -f 4 | cut -d " " -f 2`
		right=`grep ">" $SUBJECTS_DIR/$i/stats/$bblid"_"$scanid"_rh_euler.txt" | cut -d ">" -f 1 | cut -d "=" -f 4 | cut -d " " -f 2`
		#append this subject's data to the aggregate file
		echo  $bblid,$scanid,$left,$right >> $euler_file

done #for i in $(cat $slist);do  


