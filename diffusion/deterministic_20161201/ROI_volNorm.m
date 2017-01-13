function ROI_volNorm(ROIvol_path,adjmatpath,outpath)

count=dlmread(ROIvol_path)
load(adjmatpath)
sprintf(adjmatpath)

numNodes=numel(count);
volMat=zeros(numNodes);

% Create ROI volume matrix where element Aij = sum of ROI(i) volume + ROI(j) volume

for j=1:numNodes

	for k=1:numNodes

		volMat(j,k)= count(j) + count(k);

	end
end

volNorm_connectivity= connectivity./volMat;

save(outpath,'volNorm_connectivity','connectivity','count')
