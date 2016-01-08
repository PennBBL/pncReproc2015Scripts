#This a wrapper that runs mark's tools to make the b0 map.

#input argument is series directory for a subject.



subjects=$(ls -d /import/speedy/eons/subjects/*) # all 1445 subjects
b0dir=B0map_fsl
logdir=/import/speedy/eons/progs/dico/logs/


# -- Clear error log files
rm -f $logdir/*.txt

for s in $subjects; do
	echo "****************NEXT SUBJECT*************************"
	bblid=$(echo $s | cut -f6 -d/ | cut -f1 -d_)
	scanid=$(echo $s | cut -f6 -d/ | cut -f2 -d_)
	echo $bblid $scanid
	subjpath=$s

	# Skip if no B0 map directory
	b0_list=`ls -d $subjpath/*B0map_onesizefitsall*` 
	if [ -z "$b0_list" ]; then
		echo "no B0 map acquired -skipping"
		echo $bblid >> $logdir/no_b0.txt

		continue
	else

	#NOW CREATE B0 MAP
		b0_dir=$subjpath/${b0dir}
		if [ -d "$b0_dir" ]; then
			echo "b0 map directory exists"
		else
			echo "making b0 map directory"
			echo $subjpath
			mkdir $subjpath/${b0dir}
			b0_dir=$subjpath/${b0dir}
		fi

		if [ -s "$subjpath/${b0dir}/rpsmap.nii" ]; then
			echo "rps map present, skipping dico_b0calc"
		else
			echo " will run b0calc"
			echo $b0_list			
			b0_run1=`echo $b0_list |cut -d' ' -f1`
			b0_run2=`echo $b0_list |cut -d' ' -f2`
			echo "b01 is $b0_run1"
			t1_brain=$(ls -d $subjpath/*mprage*/biascorrection/*correctedbrain.nii.gz)
			t1_head=$(ls -d $subjpath/*mprage*/biascorrection/*corrected.nii.gz)

			if [ ! -s "$t1_brain" ]; then
				echo "no brain exracted image, exiting"
				echo "$bblid" >> $logdir/no_T1_brain.txt
				continue
			fi

			/import/speedy/eons/progs/dico/dico_b0calc -T $t1_head -B $t1_brain -xmu $b0_run1/Dicoms $b0_run2/Dicoms $b0_dir
#			/import/monstrum/Applications/sge/bin/lx24-amd64/qsub -V -q short.q /import/speedy/eons/progs/dico/dico_b0calc -T $t1_head -B $t1_brain -xmu $b0_run1/Dicoms $b0_run2/Dicoms $b0_dir 


		fi
	fi
done
