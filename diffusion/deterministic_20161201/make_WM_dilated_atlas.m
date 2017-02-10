function [S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix)
% function [S, SD, YD] = make_WM_dilated_atlas(fname, wmprob, dilate_n_vox, prefix)
%
% Dilates atlas only into direction of increasing white matter probabilty
% Inputs:   
%       fname           Atlas image
%       wmprob          White matter probability map
%       dilate_n_vox   how many voxel to dilate (not mm)
%       prefix          file output prefix
% Outputs:
%       S               Surface data
%       SD              Dilated surface data
%       YD              Dialted atlas data

dl = dilate_n_vox;
wm_prob = 0.0;

V = spm_vol(fname);
Y = spm_read_vols(V);

Vwm = spm_vol(wmprob);
Ywm = spm_read_vols(Vwm);

sY = size(Y);
S = zeros(sY);

% create surface points
for k=1:sY(3) % loop over slices
    for i=1:sY(1)
        for j=1:sY(2)
            if (Y(i,j,k) ~= 0)
                vals = [Y(i-1,j,k), Y(i+1,j,k), Y(i,j-1,k), Y(i,j+1,k), Y(i,j,k-1), Y(i,j,k+1)];
                if any(vals == 0)
                    S(i,j,k) = Y(i,j,k); % surface point
                else
                    S(i,j,k) = -Y(i,j,k); % inner point
                end
            end
        end
    end
end

% again, now find all surface points and expand into WM direction
SD = S;
for k=1:sY(3)
    for i=1:sY(1)
        for j=1:sY(2)
            if S(i,j,k) > 0 % surface point
                
                % get neighbours
                section = Y((i-dl):(i+dl), (j-dl):(j+dl), (k-dl):(k+dl));
                vals = reshape(section, numel(section),1);

                % and most likely value (mode of all values >0 from original mask)
                toval = mode(vals(vals > 0));
                
                % expand into white matter (x,y direction only)
                for x=1:dl
                    if (SD(i-x,j,k) == 0) && ((Ywm(i-x,j,k)-Ywm(i,j,k)) > 0) && (Ywm(i-1,j,k) > wm_prob)
                        SD(i-x,j,k) = toval;
                    end
                    if (SD(i+x,j,k) == 0) && ((Ywm(i+x,j,k)-Ywm(i,j,k)) > 0) && (Ywm(i+1,j,k) > wm_prob)
                        SD(i+x,j,k) = toval;
                    end
                    if (SD(i,j-x,k) == 0) && ((Ywm(i,j-x,k)-Ywm(i,j,k)) > 0) && (Ywm(i,j-1,k) > wm_prob)
                        SD(i,j-x,k) = toval;
                    end
                    if (SD(i,j+x,k) == 0) && ((Ywm(i,j+x,k)-Ywm(i,j,k)) > 0) && (Ywm(i,j+1,k) > wm_prob)
                        SD(i,j+x,k) = toval;
                    end
                end
                
            end
        end
    end
end

% prepare output
Vout = V;

% write out surface (S)
Vout.fname=[prefix 'surface.nii'];
spm_write_vol(Vout, S);

% write out dilated surface (SD)
Vout.fname=[prefix 'dilated_surface.nii']; 
spm_write_vol(Vout, SD);

% create and write dilated atlas
YD = abs(SD);
Vout.fname=[prefix 'dilated.nii'];
spm_write_vol(Vout, YD);
