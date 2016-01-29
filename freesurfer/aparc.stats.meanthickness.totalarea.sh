#! /bin/bash
# gets mean thickness and total surface area for each subject in list
# returns NA if not available.
export SUBJECTS_DIR=$2
slist=$1

if [ ! -e $SUBJECTS_DIR/stats/aparc.stats ]; then
	mkdir $SUBJECTS_DIR/stats/aparc.stats
fi
# header
echo bblid,scanid,rh.meanthickness,rh.totalarea,lh.meanthickness,lh.totalarea > $SUBJECTS_DIR/stats/aparc.stats/bilateral.meanthickness.totalarea.csv
for i in $(cat $slist); do
	bblid=$(echo $i | cut -d"/" -f1)
	scanid=$(echo $i | cut -d"/" -f2)
	if [ ! -e $SUBJECTS_DIR/$i ]; then
		echo "no subject directory for" $i
	else
		### RH MEAN THICKNESS AND TOTAL AREA ###
		########################################
		subdir=$SUBJECTS_DIR/$i
		if [ ! -e "$subdir/stats/rh.aparc.stats" ]; then
			echo "no rh.aparc.stats file for" $i
			rmt="NA"
			rta="NA"
		else
			string=`grep MeanThickness,  $subdir/stats/rh.aparc.stats` 
			rmt=`echo $string | cut -d "," -f 4`
			string=`grep SurfArea,  $subdir/stats/rh.aparc.stats` 
			rta=`echo $string | cut -d "," -f 4`
		fi
		
		### LH MEAN THICKNESS AND TOTAL AREA ###
		########################################
		if [ ! -e "$subdir/stats/lh.aparc.stats" ]; then
			echo "no lh.aparc.stats file for" $i
			lmt="NA"
			lta="NA"
		else
			string=`grep MeanThickness,  $subdir/stats/lh.aparc.stats` 
			lmt=`echo $string | cut -d "," -f 4`
			string=`grep SurfArea,  $subdir/stats/lh.aparc.stats` 
			lta=`echo $string | cut -d "," -f 4`
		fi
		echo $bblid,$scanid,$rmt,$rta,$lmt,$lta >> $SUBJECTS_DIR/stats/aparc.stats/bilateral.meanthickness.totalarea.csv
	fi
done
