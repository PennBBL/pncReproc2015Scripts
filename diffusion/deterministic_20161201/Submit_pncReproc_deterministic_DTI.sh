#!/bin/sh

# Subject_list is in 'bblid_scanID_dateofscan' format

subject_list=$(cat /data/jag/gbaum/PNC/10_subj_test/DTI_R21_TXFR/full_80010_subjID.txt)

# /data/joy/BBL/projects/pncBaumDti/subject_lists/BaumDTI_n1103_lowMotion_subjectList.txt)
# /data/joy/BBL/projects/pncBaumDti/subject_lists/PNC_go1_DTI_IncludeInAnalysis_subject_list_n1357.txt)
# /data/joy/BBL/projects/pncBaumDti/subject_lists/Baum_newFS_DtiPipe_n1110_subjList.txt)

for name in ${subject_list}; do

	bblid=$(basename ${name} | cut -d_ -f1)
	scanID=$(basename ${name} | cut -d_ -f2)
	tp=$(basename ${name} | cut -d_ -f3)


	echo $bblid
	echo $scanID
	echo $tp

	roalfDir=/data/joy/BBL/studies/pnc/processedData/diffusion/pncDTI_2016_04/${bblid}/"${tp}"x"${scanID}"/DTI_64
	
	baumDir=/data/joy/BBL/studies/pnc/processedData/diffusion/deterministic_20161201/${bblid}/"${tp}"x"${scanID}"

	##################################################
	### Create baumDTI_detPipe directory structure ###
	##################################################
	log_dir=${baumDir}/logfiles
	mkdir -p ${log_dir}

	tract_dir=${baumDir}/tractography
	mkdir -p ${tract_dir}

	# DTI_dir=/data/joy/BBL/studies/pnc/processedData/diffusion/baumDti/deterministic/${bblid}/"${tp}"x"${scanID}"/raw_merged_dti
	# Rec_dir=${baumDir}/tractography
	# lausannedir=${baumDir}/parcellations/diffusion


	### Define Wm-Boundary Seed Volume ###

	# seedVol=$(ls ${lausannedir}/ROIv_scale125_dilated_wmEdge_seedVol.nii.gz)

	########################################################################


	echo " "
	echo "DTI input directory"
	echo " "
	echo ${roalfDir}
	echo ""


	# Copy roalfDTI (raw data) to new directory
	# cp -R /data/jag/BBL/studies/pnc/processedData/diffusion/roalfDti/${bblid}/"${tp}"x"${scanID}"/raw_merged_dti/* ${DTI_dir}/.
	# cp /data/jag/BBL/studies/pnc/processedData/diffusion/roalfDti/${bblid}/"${tp}"x"${scanID}"/eddy_results/dico_corrected/${scanID}.dico_dico.nii ${DTI_dir}/.

	##################################################
	### Define subject-specific Rotated bvecs file ###
	##################################################
	bvecs=${roalfDir}/corrected_b_files/"${bblid}"_"${tp}"x"${scanID}"_dti_merged_rotated.bvec
	echo " "
	echo "Subject-specific rotated bvecs file"
	echo " "
	echo ${bvecs}

	bvals=$(ls /data/jag/gbaum/PNC/10_subj_test/DTIparameters/bvals.txt)
	echo " "
	echo "bval file"
	echo " "
	echo ${bvals}

	indexfile=/data/jag/gbaum/PNC/10_subj_test/DTIparameters/index.txt
	acqparams=/data/jag/gbaum/PNC/10_subj_test/DTIparameters/acqparams.txt 

	########################################################################################
	### Assign image variables for DTI -- Use eddy, motion, and distortion-corrected DWI ###
	########################################################################################
	emoDico_Dti=${roalfDir}/dico_corrected/"${bblid}"_"${tp}"x"${scanID}"_dico_dico.nii.gz

	echo " "
	echo "Eddy, Motion, and Distortion-corrected Image for Reconstruction and Tractography in DSI Studio"
	echo " "
	echo ${emoDico_Dti}

	# rawDtiFile=${roalfDir}/raw_merged_dti/"${bblid}"_"${tp}"x"${scanID}"_dti_merged.nii.gz
	# echo ""
	# echo "Subject-specific Fiber Count (# Seed voxels in wmEdge template * 20)"
	# echo ${ subj_FibCount}
	# echo ${subj_FibCount} >> ${lausannedir}/${bblid}.${tp}.${scanID}.wmEdge_DetTract_FibCount.txt
	# cp ${lausannedir}/${bblid}.${tp}.${scanID}.wmEdge_DetTract_FibCount.txt ${tract_dir}/

	############################################## 
	#### Assign inputs for processing scripts #### 
	############################################## 

	var1="pncReproc_process_dti_20161210 --in=${emoDico_Dti} --subject=${bblid} --method=DTI --paramsdir=/data/jag/gbaum/PNC/10_subj_test/DTIparameters"

	echo " "
	echo "Process DTI call"
	echo " "
	echo ${var1}

#	var2="PNC_end2end_wholebrain_1mill_parcellate --subject=${bblid}/"${tp}"x"${scanID}" --fiber_count=end --in=${emoDico_Dti} --method=DTI"


#	echo " "
#	echo "Parcellate call"
#	echo " "
#	echo ${var2}


	### Delete old executable scripts ###
	# rm ${log_dir}/"${bblid}"_"${tp}"x"${scanID}"_wholeBrain_1mill_10_400mm_PNC_DTI_detPipe.*
	
	##############################################################################################################################
	### Write out the desired processes for each temporary qsub job file; It is CRUCIAL Process_DTI is run *before* Parcellate ###
	##############################################################################################################################
	echo ${var1} >> ${log_dir}/PNC_DTI_detPipe_"${bblid}"_"${tp}"x"${scanID}"_wholeBrain_1mill_10_400mm.sh

#	echo ${var2} >> ${log_dir}/"${bblid}"_"${tp}"x"${scanID}"_wholeBrain_1mill_10_400mm_PNC_DTI_detPipe.sh

	########################################
	### SUBMIT qsub job for each subject ###
	########################################

	qsub -V -v emoDico_Dti="${emoDico_Dti}",roalfDir="${roalfDir}",bblid="${bblid}",scanID="${scanID}",tp="${tp}",baumDir="${baumDir}",log_dir="${log_dir}",tract_dir="${tract_dir}" -wd ${log_dir} -l h_vmem=6G,s_vmem=5G ${log_dir}/PNC_DTI_detPipe_"${bblid}"_"${tp}"x"${scanID}"_wholeBrain_1mill_10_400mm.sh

	# rm ${log_dir}/"${bblid}"_"${tp}"x"${scanID}"_wholeBrain_1mill_10_400mm_PNC_DTI_detPipe.sh

done
