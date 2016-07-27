#Created by MQ on 5/4/16 for CFN GO1/GO2/GO3 FS 5.3 longitudinal analyses

#this script will run the commands to: 

##### 1) prepare the visual data (QCACHE) for each measure

##### 2) prepare the stats (calculates rate of change, percent change, average) and puts them in each subject timepoint's directory and creates a "stacked" table of each measures for each subject (bblid level) it outputs the following measures:
#####################    1) The temporal average is simply the average thickness: avg = 0.5 * (thick1 + thick2), usually you don't want to analyse this, as you are mainly interested in change
#####################    2) The rate of change is the difference per time unit, so rate = ( thick2 - thick1 ) / (time2 - time1), here thickening in mm/year. In aging or disease we expect it to be negative in most regions (because of noise not necessarily for a single subject, but on average). #####################	    For more than two time points this is the slope of the linear fit.
#####################    3) The percent change (pc1) is the rate with respect to the thickness at the first time point: pc1 = rate / thick1. We also expect it to be negative and it tells how much percent thinning we have at a given cortical location.
#####################    4) The symmetrized percent change (spc) is the rate with respect to the average thickness: spc = rate / avg. This is a more robust measure than pc1, because thickness at time point 1 is more noisy than the average. Also spc is symmetric: when reversing the order of tp1 #####################       and tp2 it switches sign. This is not true for pc1. Therefore, and for other reasons related to increased statistical power, we recommend to use spc. 

##### 3) transform the qdec file to cross sectional format so can do qdec measure analyses

#You need a tab delimited qdec table set up first example is here:  /data/joy/BBL/studies/pnc/subjectData/freesurfer/qdec/long.qdec.table.dat and explanation on wiki here: https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/LongitudinalTutorial

######################################################################################
################################### SCRIPT ###########################################
######################################################################################

#loop through each subject and get the subject specific SUBJECTS_DIR then cd into that directory and also create a variable that gets the qdec table (it changes for each bblid)

#for i in `ls /data/joy/BBL/studies/pnc/processedData/structural/freesurferLongitudinal/fsData/*`; do
for i in `ls /data/joy/BBL/studies/pnc/processedData/structural/freesurferLongitudinal/fsData/112126`; do

SUBJECTS_DIR=$i
cd $SUBJECTS_DIR

#qdec_path=`ls -d /data/joy/BBL/studies/pnc/subjectData/freesurfer/qdec`
qdec_path=$SUBJECTS_DIR/qdec


#1) prepare the visual data

#left hemisphere 
long_mris_slopes --qdec $qdec_path/long.qdec.table.dat --meas thickness --hemi lh --do-avg --do-rate --do-pc1 --do-spc --do-stack --do-label --time months --qcache fsaverage --sd $SUBJECTS_DIR
long_mris_slopes --qdec $qdec_path/long.qdec.table.dat --meas area --hemi lh --do-avg --do-rate --do-pc1 --do-spc --do-stack --do-label --time months --qcache fsaverage --sd $SUBJECTS_DIR
long_mris_slopes --qdec $qdec_path/long.qdec.table.dat --meas volume --hemi lh --do-avg --do-rate --do-pc1 --do-spc --do-stack --do-label --time months --qcache fsaverage --sd $SUBJECTS_DIR

#right hemisphere 
long_mris_slopes --qdec $qdec_path/long.qdec.table.dat --meas thickness --hemi rh --do-avg --do-rate --do-pc1 --do-spc --do-stack --do-label --time months --qcache fsaverage --sd $SUBJECTS_DIR
long_mris_slopes --qdec $qdec_path/long.qdec.table.dat --meas area --hemi rh --do-avg --do-rate --do-pc1 --do-spc --do-stack --do-label --time months --qcache fsaverage --sd $SUBJECTS_DIR
long_mris_slopes --qdec $qdec_path/long.qdec.table.dat --meas volume --hemi rh --do-avg --do-rate --do-pc1 --do-spc --do-stack --do-label --time months --qcache fsaverage --sd $SUBJECTS_DIR

#2) prepare the stats

#left hemisphere
long_stats_slopes --qdec $qdec_path/long.qdec.table.dat --stats lh.aparc.stats --meas thickness --sd $SUBJECTS_DIR --do-rate --do-avg --do-pc1fit --do-pc1 --do-spc --do-stack --stack-avg stack_avg_thickness.dat --stack-rate stack_rate_thickness.dat --stack-pc1fit stack_pc1fit_thickness.dat --stack-pc1 stack_pc1_thickness.dat --stack-spc stack_sp_thicknessc.dat

long_stats_slopes --qdec $qdec_path/long.qdec.table.dat --stats lh.aparc.stats --meas area --sd $SUBJECTS_DIR --do-rate --do-avg --do-pc1fit --do-pc1 --do-spc --do-stack --stack-avg stack_avg_area.dat --stack-rate stack_rate_area.dat --stack-pc1fit stack_pc1fit_area.dat --stack-pc1 stack_pc1_area.dat --stack-spc stack_spc_area.dat

long_stats_slopes --qdec $qdec_path/long.qdec.table.dat --stats lh.aparc.stats --meas volume --sd $SUBJECTS_DIR --do-rate --do-avg --do-pc1fit --do-pc1 --do-spc --do-stack --stack-avg stack_avg_volume.dat --stack-rate stack_rate_volume.dat --stack-pc1fit stack_pc1fit_volume.dat --stack-pc1 stack_pc1_volume.dat --stack-spc stack_spc_volume.dat

#right hemisphere
long_stats_slopes --qdec $qdec_path/long.qdec.table.dat --stats rh.aparc.stats --meas thickness --sd $SUBJECTS_DIR --do-rate --do-avg --do-pc1fit --do-pc1 --do-spc --do-stack --stack-avg stack_avg_thickness.dat --stack-rate stack_rate_thickness.dat --stack-pc1fit stack_pc1fit_thickness.dat --stack-pc1 stack_pc1_thickness.dat --stack-spc stack_spc_thickness.dat

long_stats_slopes --qdec $qdec_path/long.qdec.table.dat --stats rh.aparc.stats --meas area --sd $SUBJECTS_DIR --do-rate --do-avg --do-pc1fit --do-pc1 --do-spc --do-stack --stack-avg stack_avg_area.dat --stack-rate stack_rate_area.dat --stack-pc1fit stack_pc1fit_area.dat --stack-pc1 stack_pc1_area.dat --stack-spc stack_spc_area.dat

long_stats_slopes --qdec $qdec_path/long.qdec.table.dat --stats rh.aparc.stats --meas volume --sd $SUBJECTS_DIR --do-rate --do-avg --do-pc1fit --do-pc1 --do-spc --do-stack --stack-avg stack_avg_volume.dat --stack-rate stack_rate_volume.dat --stack-pc1fit stack_pc1fit_volume.dat --stack-pc1 stack_pc1_volume.dat --stack-spc stack_spc_volume.dat

done


#3) transform the qdec file to cross sectional format so can do qdec measure analyses

long_qdec_table --qdec $qdec_path/long.qdec.table.dat --cross --out $qdec_path/cross.qdec.table.dat

qdec --table $qdec_path/cross.qdec.table.dat

