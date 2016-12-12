#!/bin/sh

subject_list=$(cat /data/jag/gbaum/PNC/10_subj_test/DTI_R21_TXFR/full_80010_subjID.txt)

# /data/joy/BBL/projects/pncBaumDti/subject_lists/PNC_go1_DTI_IncludeInAnalysis_subject_list_n1357.txt)
# /data/joy/BBL/projects/pncBaumDti/subject_lists/LTN_lowMotion_baumDTI_subjList_n882.txt)
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

	dtiDir=/data/joy/BBL/studies/pnc/processedData/diffusion/deterministic_20161201/${bblid}/"${tp}"x"${scanID}"
	mkdir -p "${dtiDir}"
	mkdir -p "${dtiDir}"/Parcellations/T1
	mkdir -p "${dtiDir}"/Parcellations/diffusion
	mkdir -p "${dtiDir}"/connectivity/lausanne
	mkdir -p "${dtiDir}"/tractography

	# Atlas Path (in T1 space)
	gunzip /data/joy/BBL/studies/pnc/processedData/structural/freesurfer53/${bblid}/"${tp}"x"${scanID}"/label/ROIv_scale125_T1.nii.gz
	# fname=/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53/${bblid}/"${tp}"x"${scanID}"/label/ROIv_scale125_T1.nii
		
	fname=/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/"${tp}"x"${scanID}"/GlasserPNCToSubject.nii.gz 

	# Probabilistic WM Map
	gunzip /data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/"${tp}"x"${scanID}"/BrainSegmentationPosteriors3.nii.gz
	wmprob=/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/"${tp}"x"${scanID}"/BrainSegmentationPosteriors3.nii
	

	# Parcellation Output file Prefix
	prefix=${dtiDir}/Parcellations/T1/${bblid}_"${tp}"x"${scanID}"_T1_Glasser_dil2_

	###########################################
	### Run Axel's function for dilating WM ###
	###########################################	
	pushd /data/jag/gbaum/pncReproc2015Scripts/diffusion/deterministic_20161201
	
	matlab -nosplash -nodesktop -r "GLB_make_WM_dilated_atlas ${fname} ${wmprob} ${prefix}; exit()"
	
	popd

	###########################################################################
	### Co-register Parcellation to Diffusion Space Using dti2xcp Transform ###
	###########################################################################
	
	gzip ${fname}
	gzip ${wmprob}

	# Dilated ROIs
	antsApplyTransforms -d 3 -e 0 -i "${prefix}"dilated.nii -r /data/joy/BBL/studies/pnc/processedData/diffusion/dti2xcp_201606230942/${bblid}/"${tp}"x"${scanID}"/dti2xcp/${bblid}_"${tp}"x"${scanID}"_referenceVolume.nii.gz -t /data/joy/BBL/studies/pnc/processedData/diffusion/dti2xcp_201606230942/${bblid}/"${tp}"x"${scanID}"/coreg/${bblid}_"${tp}"x"${scanID}"_struct2seq.txt -o "${dtiDir}"/Parcellations/diffusion/${bblid}_"${tp}"x"${scanID}"_Glasser_dil2_dilated_GM.nii.gz -n MultiLabel

	# WM-GM Surface ROIs
	antsApplyTransforms -d 3 -e 0 -i "${prefix}"dilated_surface.nii -r /data/joy/BBL/studies/pnc/processedData/diffusion/dti2xcp_201606230942/${bblid}/"${tp}"x"${scanID}"/dti2xcp/${bblid}_"${tp}"x"${scanID}"_referenceVolume.nii.gz -t /data/joy/BBL/studies/pnc/processedData/diffusion/dti2xcp_201606230942/${bblid}/"${tp}"x"${scanID}"/coreg/${bblid}_"${tp}"x"${scanID}"_struct2seq.txt -o "${dtiDir}"/Parcellations/diffusion/${bblid}_"${tp}"x"${scanID}"_Glasser_dil2_dilated_WMsurface.nii.gz -n MultiLabel

	gzip "${dtiDir}"/Parcellations/T1/*.nii

done
