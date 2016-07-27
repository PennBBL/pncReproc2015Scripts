#echo "bblid,scanid,ICVMm3,vol_Cortical_White_Matter_Volume,vol_Cortex_Volume,ct_lh_entorhinal,ct_lh_inferiortemporal,ct_lh_parahippocampal,ct_lh_superiortemporal,ct_lh_temporalpole,ct_rh_entorhinal,ct_rh_inferiortemporal,ct_rh_parahippocampal,ct_rh_superiortemporal,ct_rh_temporalpole,vol_lh_entorhinal,vol_lh_inferiortemporal,vol_lh_parahippocampal,vol_lh_superiortemporal,vol_lh_temporalpole,vol_rh_entorhinal,vol_rh_inferiortemporal,vol_rh_parahippocampal,vol_rh_superiortemporal,vol_rh_temporalpole,area_lh_entorhinal,area_lh_inferiortemporal,area_lh_parahippocampal,area_lh_superiortemporal,area_lh_temporalpole,area_rh_entorhinal,area_rh_inferiortemporal,area_rh_parahippocampal,area_rh_superiortemporal,area_rh_temporalpole" > /home/mquarmley/GO/freesurfer/data_for_dr.csv

echo "bblid,scanid,ICVMm3,vol_Cortical_White_Matter_Volume,vol_Cortex_Volume,lh_entorhinal,lh_inferiortemporal,lh_parahippocampal,lh_superiortemporal,lh_temporalpole,rh_entorhinal,rh_inferiortemporal,rh_parahippocampal,rh_superiortemporal,rh_temporalpole" > /home/mquarmley/GO/freesurfer/data_for_dr.csv

for i in `cat /home/mquarmley/GO/freesurfer/missing_subjs.txt`; do

bblid=`echo $i | cut -d "," -f 1`
scanid=`echo $i | cut -d "," -f2`
lh_aparc=/data/jag/BBL/studies/pnc/processedData/structural/freesurfer/"$bblid"/*"$scanid"/stats/lh.aparc.stats
rh_aparc=/data/jag/BBL/studies/pnc/processedData/structural/freesurfer/"$bblid"/*"$scanid"/stats/rh.aparc.stats
aseg=/data/jag/BBL/studies/pnc/processedData/structural/freesurfer/"$bblid"/*"$scanid"/stats/aseg.stats

#cortical thickness
lh_entorhinal_ct=`cat $lh_aparc | grep "entorhinal"`
lh_inferior_temporal_ct=`cat $lh_aparc | grep "inferiortemporal"`
lh_parahippocampal_ct=`cat $lh_aparc | grep "parahippocampal"`
lh_superiortemporal_ct=`cat $lh_aparc | grep "superiortemporal"`
lh_temporalpole_ct=`cat $lh_aparc | grep "temporalpole"`

rh_entorhinal_ct=`cat $rh_aparc | grep "entorhinal"`
rh_inferior_temporal_ct=`cat $rh_aparc | grep "inferiortemporal"`
rh_parahippocampal_ct=`cat $rh_aparc | grep "parahippocampal"`
rh_superiortemporal_ct=`cat $rh_aparc | grep "superiortemporal"`
rh_temporalpole_ct=`cat $rh_aparc | grep "temporalpole"`

#volume
#lh_entorhinal_vol=`cat $lh_aparc | grep "entorhinal" | cut -d " " -f 40`
#lh_inferior_temporal_vol=`cat $lh_aparc | grep "inferiortemporal" | cut -d " " -f 31`
#lh_parahippocampal_vol=`cat $lh_aparc | grep "parahippocampal" | cut -d " " -f 34`
#lh_superiortemporal_vol=`cat $lh_aparc | grep "superiortemporal" | cut -d " " -f 31`
#lh_temporalpole_vol=`cat $lh_aparc | grep "temporalpole" | cut -d " " -f 38`

#rh_entorhinal_vol=`cat $rh_aparc | grep "entorhinal" | cut -d " " -f 40`
#rh_inferior_temporal_vol=`cat $rh_aparc | grep "inferiortemporal" | cut -d " " -f 31`
#rh_parahippocampal_vol=`cat $rh_aparc | grep "parahippocampal" | cut -d " " -f 34`
#rh_superiortemporal_vol=`cat $rh_aparc | grep "superiortemporal" | cut -d " " -f 31`
#rh_temporalpole_vol=`cat $rh_aparc | grep "temporalpole" | cut -d " " -f 38`

#area
#lh_entorhinal_area=`cat $lh_aparc | grep "entorhinal" | cut -d " " -f 37`
#lh_inferior_temporal_area=`cat $lh_aparc | grep "inferiortemporal" | cut -d " " -f 29`
#lh_parahippocampal_area=`cat $lh_aparc | grep "parahippocampal" | cut -d " " -f 31`
#lh_superiortemporal_area=`cat $lh_aparc | grep "superiortemporal" | cut -d " " -f 29`
#lh_temporalpole_area=`cat $lh_aparc | grep "temporalpole" | cut -d " " -f 35`

#rh_entorhinal_area=`cat $rh_aparc | grep "entorhinal" | cut -d " " -f 37`
#rh_inferior_temporal_area=`cat $rh_aparc | grep "inferiortemporal" | cut -d " " -f 29`
#rh_parahippocampal_area=`cat $rh_aparc | grep "parahippocampal" | cut -d " " -f 31`
#rh_superiortemporal_area=`cat $rh_aparc | grep "superiortemporal" | cut -d " " -f 29`
#rh_temporalpole_area=`cat $rh_aparc | grep "temporalpole" | cut -d " " -f 35`


#aseg
icv=`cat $aseg | grep "ICV" | cut -d "," -f 4`
#total_area
#mean_thickness
cortical_white_matter_vol=`cat $aseg | grep "Total cortical white matter volume" | cut -d "," -f 4`
cortex_vol=`cat $aseg | grep "Total cortical gray matter volume" | cut -d "," -f 4`


#echo "$bblid,$scanid,$icv,$cortical_white_matter_vol,$cortex_vol,$lh_entorhinal_ct,$lh_inferior_temporal_ct,$lh_parahippocampal_ct,$lh_superiortemporal_ct,$lh_temporalpole_ct,$rh_entorhinal_ct,$rh_inferior_temporal_ct,$rh_parahippocampal_ct,$rh_superiortemporal_ct,$rh_temporalpole_ct,$lh_entorhinal_vol,$lh_inferior_temporal_vol,$lh_parahippocampal_vol,$lh_superiortemporal_vol,$lh_temporalpole_vol,$rh_entorhinal_vol,$rh_inferior_temporal_vol,$rh_parahippocampal_vol,$rh_superiortemporal_vol,$rh_temporalpole_vol,$lh_entorhinal_area,$lh_inferior_temporal_area,$lh_parahippocampal_area,$lh_superiortemporal_area,$lh_temporalpole_area,$rh_entorhinal_area,$rh_inferior_temporal_area,$rh_parahippocampal_area,$rh_superiortemporal_area,$rh_temporalpole_area" >> /home/mquarmley/GO/freesurfer/data_for_dr.csv

echo "$bblid,$scanid,$icv,$cortical_white_matter_vol,$cortex_vol,$lh_entorhinal_ct,$lh_inferior_temporal_ct,$lh_parahippocampal_ct,$lh_superiortemporal_ct,$lh_temporalpole_ct,$rh_entorhinal_ct,$rh_inferior_temporal_ct,$rh_parahippocampal_ct,$rh_superiortemporal_ct,$rh_temporalpole_ct" >> /home/mquarmley/GO/freesurfer/data_for_dr.csv

done
