#MQ 11/18/15 
#This script extracts volume, thickness, and surface area from GO1/GO2 CFN FreeSurer version 5.3 ROIs to create a file for Bruce Turetsky to be used in Roalf et al 2015 
#it can be adapted for any project and ROIs

#call path to where the freesurfer overall stats files live (all subjects in one csv) 
path=`ls -d /data/jag/BBL/projects/pncReproc2015/freesurfer/stats5_3/aparc.stats`

#create csv where extracted roi stats will go
echo "bblid,scanid,icv,L_Amyg_vol,L_Hip_vol,R_Amyg_vol,R_Hip_vol,L_infTemp_SA,L_infTemp_vol,L_infTemp_thickness,R_infTemp_SA,R_infTemp_vol,R_infTemp_thickness,L_parahip_SA,L_parahip_vol,L_parahip_thickness,R_parahip_SA,R_parahip_vol,R_parahip_thickness,L_supTemp_SA,L_supTemp_vol,L_supTemp_thickness,R_supTemp_SA,R_supTemp_vol,R_supTemp_thickness,L_temppole_SA,L_temppole_vol,L_temppole_thickness,R_temppole_SA,R_temppole_vol,R_temppole_thickness,L_entorhinal_SA,L_entorhinal_vol,L_entorhinal_thickness,R_entorhinal_SA,R_entorhinal_vol,R_entorhinal_thickness" > $path/go1_go2_rois_turetsky.csv

#loop through GO1/GO2 cfn freesurfer 5.3 subjects
for i in `ls -d /data/jag/BBL/studies/pnc/processedData/structural/freesurfer53/*/*x????/stats`; do 

#get subject ID, bblid, datexscanid and scanid
subid=`echo $i | cut -d "/" -f 10-11`
bblid=`echo $subid | cut -d "/" -f 1`
datexscanid=`echo $subid | cut -d "/" -f 2`
scanid=`echo $datexscanid | cut -d "x" -f 2`

echo ".............Extracting stats for" $subid

#extract volume, thickness and surface area for each ROI
icv=`grep 'EstimatedTotalIntraCranialVol' $i/aseg.stats | cut -d " " -f 9 | cut -d "," -f 1`

#because not every subject has standard spacing for the ROI values (ie some are 38 spaces from the label, some are 40), to avoid missing data the ROIs must be grepped into a separate file, then that file must have white space changed to commas
#then the specific ROI values can be appropriately extracted. The temp comma separated files are deleted after variables are created for each specific value

#aseg stats file
sed -e 's/\s\+/,/g' < $i/aseg.stats > $i/aseg.stats_temp.txt

#hippocampus
lh_hipp_vol=`grep 'Left-Hippocampus' $i/aseg.stats_temp.txt | cut -d "," -f 5`
rh_hipp_vol=`grep 'Right-Hippocampus' $i/aseg.stats_temp.txt | cut -d "," -f 5`
#amygdala
lh_amy_vol=`grep 'Left-Amygdala' $i/aseg.stats_temp.txt | cut -d "," -f 5`
rh_amy_vol=`grep 'Right-Amygdala' $i/aseg.stats_temp.txt | cut -d "," -f 5`

#aparc stats files (lh and rh)
sed -e 's/\s\+/,/g' < $i/lh.aparc.stats > $i/lh.aparc.stats_temp.txt
sed -e 's/\s\+/,/g' < $i/rh.aparc.stats > $i/rh.aparc.stats_temp.txt

#parahippocampal
lh_parhip_vol=`grep 'parahippocampal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 4`
lh_parhip_thick=`grep 'parahippocampal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 5`
lh_parhip_sa=`grep 'parahippocampal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 3`
rh_parhip_vol=`grep 'parahippocampal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 4`
rh_parhip_thick=`grep 'parahippocampal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 5`
rh_parhip_sa=`grep 'parahippocampal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 3`
#inferior temporal
lh_inftemporal_vol=`grep 'inferiortemporal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 4`
lh_inftemporal_thick=`grep 'inferiortemporal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 5`
lh_inftemporal_sa=`grep 'inferiortemporal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 3`
rh_inftemporal_vol=`grep 'inferiortemporal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 4`
rh_inftemporal_thick=`grep 'inferiortemporal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 5`
rh_inftemporal_sa=`grep 'inferiortemporal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 3`
#superior temporal
lh_suptemporal_vol=`grep 'superiortemporal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 4`
lh_suptemporal_thick=`grep 'superiortemporal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 5`
lh_suptemporal_sa=`grep 'superiortemporal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 3`
rh_suptemporal_vol=`grep 'superiortemporal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 4`
rh_suptemporal_thick=`grep 'superiortemporal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 5`
rh_suptemporal_sa=`grep 'superiortemporal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 3`
#temporal pole
lh_temporal_vol=`grep 'temporalpole' $i/lh.aparc.stats_temp.txt | cut -d "," -f 4`
lh_temporal_thick=`grep 'temporalpole' $i/lh.aparc.stats_temp.txt | cut -d "," -f 5`
lh_temporal_sa=`grep 'temporalpole' $i/lh.aparc.stats_temp.txt | cut -d "," -f 3`
rh_temporal_vol=`grep 'temporalpole' $i/rh.aparc.stats_temp.txt | cut -d "," -f 4`
rh_temporal_thick=`grep 'temporalpole' $i/rh.aparc.stats_temp.txt | cut -d "," -f 5`
rh_temporal_sa=`grep 'temporalpole' $i/rh.aparc.stats_temp.txt | cut -d "," -f 3`
#entorhinal cortex
lh_ent_vol=`grep 'entorhinal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 4`
lh_ent_thick=`grep 'entorhinal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 5`
lh_ent_sa=`grep 'entorhinal' $i/lh.aparc.stats_temp.txt | cut -d "," -f 3`
rh_ent_vol=`grep 'entorhinal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 4`
rh_ent_thick=`grep 'entorhinal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 5`
rh_ent_sa=`grep 'entorhinal' $i/rh.aparc.stats_temp.txt | cut -d "," -f 3`

#delete temp ROI files (comma separated ones)
rm -rf $i/lh.aparc.stats_temp.txt
rm -rf $i/rh.aparc.stats_temp.txt
rm -rf $i/aseg.stats_temp.txt

#append each subject's ROI data to the output file
echo "$bblid,$scanid,$icv,$lh_amy_vol,$lh_hipp_vol,$rh_amy_vol,$rh_hipp_vol,$lh_inftemporal_sa,$lh_inftemporal_vol,$lh_inftemporal_thick,$rh_inftemporal_sa,$rh_inftemporal_vol,$rh_inftemporal_thick,$lh_parhip_sa,$lh_parhip_vol,$lh_parhip_thick,$rh_parhip_sa,$rh_parhip_vol,$rh_parhip_thick,$lh_suptemporal_sa,$lh_suptemporal_vol,$lh_suptemporal_thick,$rh_suptemporal_sa,$rh_suptemporal_vol,$rh_suptemporal_thick,$lh_temporal_sa,$lh_temporal_vol,$lh_temporal_thick,$rh_temporal_sa,$rh_temporal_vol,$rh_temporal_thick,$lh_ent_sa,$lh_ent_vol,$lh_ent_thick,$rh_ent_sa,$rh_ent_vol,$rh_ent_thick" >> $path/go1_go2_rois_turetsky.csv

done

