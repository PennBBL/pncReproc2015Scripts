function GLB_make_WM_dilated_atlas(Glasser_fname,Lausanne_fname,wmprob,Glasser_prefix,Lausanne_prefix)

%%%%%%%%%%%%%%%%%%%%%
%%% Define inputs %%%
%%%%%%%%%%%%%%%%%%%%%

%% Number of voxels dilated
dilate_n_vox = 4

%% Specify Atlas for dilation
fname=Glasser_fname

% '/data/joy/BBL/studies/pnc/processedData/structural/freesurfer53/80010/20100218x2894/label/ROIv_scale125_T1.nii.gz'
% '/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/80010/20100218x2894/GlasserPNCToSubject.nii.gz' 

%% Probabilistic WM Map
wmprob
% '/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/80010/20100218x2894/BrainSegmentationPosteriors3.nii.gz'


%% Output file Prefix
prefix=Glasser_prefix
% '/data/jag/gbaum/test_Lausanne234_dil4_'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run Axel's function for dilating WM %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Repeate for Lausanne Atlas %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fname=Lausanne_fname

prefix=Lausanne_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
