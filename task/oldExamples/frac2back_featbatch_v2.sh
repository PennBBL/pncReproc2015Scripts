########EDITABLE PARAMTERS###########
bblids=80010
#bblids=$(cat /import/speedy/eons/redcap/subject_variables/n1445_bblids.txt)
#85054-- don't have permissions here
#bblids=$(cat /import/speedy/eons/group_results_n1445/frac2back/subject_lists/frac2back_n951_bblids_final.txt)
logpath=/import/speedy/eons/progs/frac2back/bash/logs/
fsfpath=/import/speedy/eons/progs/design_files/frac2back  #looks here to find  fsf template
#featname=test  #this is output directory name ("test.feat") AND the template name it will find in fsfpath above ("test.fsf")
featname=frac2back_stats_behav_6EV_nodico  #note that the output name must be same as tempalte fsf name for this to work in terms of checking output
####################################


rm -f $logpath/${featname}_incomplete.txt
rm -f $logpath/frac_missing4d.txt
rm -f $logpath/frac_missing_scores.txt
rm -f $logpath/${featname}_subjects_run.txt

for b in $bblids; do
	echo ""
	echo "*******NEXT SUBJECT***********"
	echo $b
	seriespath=$(ls -d /import/speedy/eons/subjects/${b}*/*frac2back1_231/ 2> /dev/null)
	prestats=$(ls -d ${seriespath}/prestats/ 2> /dev/null)
	scoresdir=$(ls -d /import/speedy/eons/subjects/${b}*/scores/*frac* 2> /dev/null)
	fourd=$(ls ${prestats}/filtered_func_data.nii.gz 2> /dev/null)

	#check if series directory present
	if [ ! -d "$seriespath" ]; then
		echo "no series, skipping"
		continue
	fi
	
	#check if 4D file present in prestats
	if [ ! -s "$fourd" ]; then
		echo "4D file NOT present-- will log"
		echo $b  >> $logpath/frac_missing4d.txt
		continue
	fi

	#check that scores directory is present
	if [ ! -d "$scoresdir" ]; then
		echo "NO SCORES DIRECTORY-- skipping & logging"
		echo $b >> $logpath/frac_missing_scores.txt
		continue
	fi

	featdir=$(ls -d $seriespath/stats/${featname}.feat 2> /dev/null)
	echo $featdir



	
	if [ -d "${featdir}" ]; then
		echo "featdir exists"
		if [ -e ${featdir}/stats/res4d.nii.gz ]; then
			echo "already run"
			continue
		else
			echo "feat directory present but incomplete, will rerun featbatch"	
			echo "$b" >> $logpath/${featname}_incomplete.txt
		fi
	fi




	cd $seriespath
	pwd
	design=$(ls $fsfpath/${featname}.fsf)

	
	echo "***running feat for $design***"	
	
	#get subject ID data from path
	idtmp=$(pwd | cut -d/ -f6)
	bblid=$(echo $idtmp | cut -d_ -f1)
	scanid=$(echo $idtmp | cut -d_ -f2)
	#echo $bblid
	#echo $scanid
	series=$(pwd | cut -d/ -f7)
	#echo $series
	scores_id_tmp=$(ls -d /import/speedy/eons/subjects/${bblid}_${scanid}/scores/frac2B_1.00/*all_all_all.csv | cut -d/ -f9)
	

	scores_bblid=$(echo $scores_id_tmp | cut -d_ -f1)
	scores_scanid=$(echo $scores_id_tmp | cut -d_ -f2)
	#echo $scores_id_tmp
	#echo $scores_bblid
	#echo $scores_scanid
	#get sequence from nifti file [not always used but named this way]
	niftipath=$(ls -d /import/speedy/eons/subjects/${bblid}_${scanid}/*frac2back*/nifti/*.nii.gz)
	nifti=$(basename $niftipath)
	seq=$(echo $nifti | cut -d_ -f5 | cut -d. -f1)
	echo $seq


	#find/replace varaibles in .fsf file
	cp $design ./${featname}_preproctmp.fsf
	sed "s/XBBLIDX/$bblid/g"  ${featname}_preproctmp.fsf > ${featname}_preproctmp1.fsf
	sed "s/XSCANIDX/$scanid/g"  ${featname}_preproctmp1.fsf > ${featname}_preproctmp2.fsf
	sed "s/XSERIESX/$series/g" ${featname}_preproctmp2.fsf > ${featname}_preproctmp3.fsf
	sed "s/XSCORES_BBLIDX/$scores_bblid/g" ${featname}_preproctmp3.fsf > ${featname}_preproctmp4.fsf
	sed "s/XSCORES_SCANIDX/$scores_scanid/g"  ${featname}_preproctmp4.fsf > ${featname}_preproctmp5.fsf
	sed "s/XSEQX/$seq/g" ${featname}_preproctmp5.fsf > ${featname}_preproctmp6.fsf 
	mv ${featname}_preproctmp6.fsf ${featname}.fsf
	rm ${featname}_preproctmp*.fsf

	echo "running feat now"
	echo $b >> $logpath/${featname}_subjects_run.txt
	feat ${featname}.fsf 
		
	rm -f ${featname}.fsf #cleanup initial design.fsf file-- it now exists in feat folder. but this does't work if "&" after Feat call for non-grid testing.
	
done
