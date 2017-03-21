function GLB_dilate_atlas(wmprob, dilate_nVox, Glasser_path, scale33_Lausanne_T1, scale60_Lausanne_T1, scale125_Lausanne_T1, scale250_Lausanne_T1, scale500_Lausanne_T1, LausanneScale33_prefix, LausanneScale60_prefix, LausanneScale125_prefix, LausanneScale250_prefix, LausanneScale500_prefix)

%%%%%%%%%%%%%%%%%%%%%
%%% Define inputs %%%
%%%%%%%%%%%%%%%%%%%%%

%% Number of voxels to dilate (modal dilation)
dilate_nVox
dilate_n_vox = 4

%% Probabilistic WM Map
wmprob         

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run Axel's function for dilating Atlases %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%
%%% GlasserPNC %%%
%%%%%%%%%%%%%%%%%%
fname=Glasser_path

prefix=Glasser_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);


%%%%%%%%%%%%%%%%%%%%%%%
%%% LausanneScale33 %%%
%%%%%%%%%%%%%%%%%%%%%%%
fname=scale33_Lausanne_T1

prefix=LausanneScale33_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);


%%%%%%%%%%%%%%%%%%%%%%%
%%% LausanneScale60 %%%
%%%%%%%%%%%%%%%%%%%%%%%
fname=scale60_Lausanne_T1

prefix=LausanneScale60_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LausanneScale125 %%%
%%%%%%%%%%%%%%%%%%%%%%%%
fname=scale125_Lausanne_T1

prefix=LausanneScale125_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);


%%%%%%%%%%%%%%%%%%%%%%%%
%%% LausanneScale250 %%%
%%%%%%%%%%%%%%%%%%%%%%%%
fname=scale250_Lausanne_T1

prefix=LausanneScale250_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LausanneScale500 %%%
%%%%%%%%%%%%%%%%%%%%%%%%
fname=scale500_Lausanne_T1

prefix=LausanneScale500_prefix

[S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix);
