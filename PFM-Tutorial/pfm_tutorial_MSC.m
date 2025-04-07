%% Pipeline precision functional mapping

%% Before you begin.
main_dir = pwd(); 

% add dependencies to Matlab search path
addpath(genpath([main_dir, '/Utilities']));

addpath(genpath([main_dir, '/read_write_cifti']));

% define path to some software packages that will be needed
InfoMapBinary = [main_dir, '/Resources'];
WorkbenchBinary =[main_dir, '/workbench/bin_rh_linux64/wb_command'];

% number of workers
nWorkers = 4;

%% Step 1: Temporal Concatenation of fMRI data from all sessions.

% define subject directory and name;
Subject = 'MSC01';
Subdir = [pwd '/MSC/derivatives/surface_pipeline/sub-' Subject '/'];


% define & create
% the pfm directory;
PfmDir = [pwd '/PFM-Tutorial/sub-' Subject '/pfm'];
mkdir(PfmDir);

% count the number of imaging sessions;
nSessions = length(dir([Subdir '/processed_restingstate_timecourses/ses-func*']));

% preallocate;
ConcatenatedData = [];

% sweep through
% the sessions;
for i = 1:nSessions
            
        % load the denoised & fs_lr_32k surface-registered CIFTI file for run "ii" from session "i"...
        Cifti = ft_read_cifti_mod([Subdir 'processed_restingstate_timecourses/ses-func' sprintf('%02d',i) '/cifti/sub-' Subject '_ses-func' sprintf('%02d',i) '_task-rest_bold_32k_fsLR.dtseries.nii']);
        Cifti.data = Cifti.data - mean(Cifti.data,2); % demean
        Tmask = load([Subdir 'processed_restingstate_timecourses/ses-func' sprintf('%02d',i) '/cifti/sub-' Subject '_ses-func' sprintf('%02d',i) '_task-rest_bold_32k_fsLR_tmask.txt']);
        ConcatenatedData = [ConcatenatedData Cifti.data(:,Tmask==1)]; % 1 (Low motion timepoints) == FD < 0.3mm, 0 (High motion timepoints) == FD > 0.3mm
           
end

% make a single CIFTI containing 
% time-series from all scans;
ConcatenatedCifti = Cifti;
ConcatenatedCifti.data = ConcatenatedData;

%% Step 2: Make a distance matrix.

% define fs_lr_32k midthickness surfaces;
MidthickSurfs{1} = [Subdir 'fs_LR_Talairach/fsaverage_LR32k/' Subject '.L.midthickness.32k_fs_LR.surf.gii'];
MidthickSurfs{2} = [Subdir 'fs_LR_Talairach/fsaverage_LR32k/' Subject '.R.midthickness.32k_fs_LR.surf.gii'];

% make the distance matrix;
pfm_make_dmat(ConcatenatedCifti,MidthickSurfs,PfmDir,nWorkers,WorkbenchBinary); %

% optional: regress adjacent cortical signal from subcortex to reduce artifactual coupling 
% (for example, between cerebellum and visual cortex, or between putamen and insular cortex)
[ConcatenatedCifti] = pfm_regress_adjacent_cortex(ConcatenatedCifti,[PfmDir '/DistanceMatrix.mat'],20);

% write out the CIFTI file;
ft_write_cifti_mod([PfmDir '/sub-' Subject '_task-rest_concatenated_32k_fsLR.dtseries.nii'],ConcatenatedCifti);

%% Step 2b: Compute surface area that each vertex in the individual midthickness surface is responsible for. 
%Define output names for files computing surface area taken by each vertex
MidthickSurfs_va{1} = [PfmDir '/sub-' Subject '.L.midthickness_va.32k_fs_LR.shape.gii'];
MidthickSurfs_va{2} = [PfmDir '/sub-' Subject '.R.midthickness_va.32k_fs_LR.shape.gii'];

%Compute surface area that each vertex is taking
system([WorkbenchBinary ' -surface-vertex-areas ' MidthickSurfs{1}  ' ' MidthickSurfs_va{1}]);
system([WorkbenchBinary ' -surface-vertex-areas ' MidthickSurfs{2} ' '  MidthickSurfs_va{2}]);

%Combine left and right vertex area (shape.gii) into a dscalar
system([WorkbenchBinary ' -cifti-create-dense-scalar ' PfmDir '/sub-' Subject '.midthickness_va.32k_fs_LR.dscalar.nii' ' -left-metric ' MidthickSurfs_va{1} ' -right-metric ' MidthickSurfs_va{2}]);

 
%% Step 3: Apply spatial smoothing.

% define a range of gaussian 
% smoothing kernels (in sigma)
KernelSizes = [0.85 1.7 2.55];

% sweep a range of
% smoothing kernels;
for k = KernelSizes
    
    % smooth with geodesic (for surface data) and Euclidean (for volumetric data) Gaussian kernels;
    system([WorkbenchBinary ' -cifti-smoothing ' PfmDir '/sub-' Subject '_task-rest_concatenated_32k_fsLR.dtseries.nii '...
    num2str(k) ' ' num2str(k) ' COLUMN ' PfmDir '/sub-' Subject '_task-rest_concatenated_smoothed' num2str(k) '_32k_fsLR.dtseries.nii -left-surface ' MidthickSurfs{1} ' -right-surface ' MidthickSurfs{2} ' -merged-volume']);
        
end

%% Step 4: Run infomap.

% load your concatenated resting-state dataset, pick whatever level of spatial smoothing you want
ConcatenatedCifti = ft_read_cifti_mod([PfmDir '/sub-' Subject '_task-rest_concatenated_smoothed2.55_32k_fsLR.dtseries.nii']);

% define inputs;
DistanceMatrix = [PfmDir '/DistanceMatrix.mat']; % can be path to file
DistanceCutoff = 10; % in mm; usually between 10 to 30 mm works well.
GraphDensities = flip([0.0001 0.0002 0.0005 0.001 0.002 0.005 0.01 0.02 0.05]); % 
NumberReps = 50; % number of times infomap is run;
BadVertices = []; % optional, but you could include regions to ignore, if you know there is bad signal there.
Structures = {'CORTEX_LEFT','CEREBELLUM_LEFT','ACCUMBENS_LEFT','CAUDATE_LEFT','PALLIDUM_LEFT','PUTAMEN_LEFT','THALAMUS_LEFT','HIPPOCAMPUS_LEFT','AMYGDALA_LEFT','CORTEX_RIGHT','CEREBELLUM_RIGHT','ACCUMBENS_RIGHT','CAUDATE_RIGHT','PALLIDUM_RIGHT','PUTAMEN_RIGHT','THALAMUS_RIGHT','HIPPOCAMPUS_RIGHT','AMYGDALA_RIGHT'};

% run infomap
pfm_infomap(ConcatenatedCifti,DistanceMatrix,PfmDir,GraphDensities,NumberReps,DistanceCutoff,BadVertices,Structures,nWorkers,InfoMapBinary);

% remove some intermediate files (optional)
system(['rm ' PfmDir '/*.net']);
system(['rm ' PfmDir '/*.clu']);
system(['rm ' PfmDir '/*Log*']);

% define inputs;
Input = [PfmDir '/Bipartite_PhysicalCommunities.dtseries.nii'];
Output = 'Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii';
MinSize = 50; % in mm^2

% perform spatial filtering
pfm_spatial_filtering(Input,PfmDir,Output,MidthickSurfs,MinSize,WorkbenchBinary);

%% Step 5: Algorithmic assignment of network identities to infomap communities.

% load the priors;
load('priors.mat');

% define inputs;
Ic = ft_read_cifti_mod([PfmDir '/Bipartite_PhysicalCommunities+SpatialFiltering.dtseries.nii']);
Output = 'Bipartite_PhysicalCommunities+AlgorithmicLabeling';
Column = 6; % column 6 corresponding to graph density

% run the network identification algorithm;
pfm_identify_networks(ConcatenatedCifti,Ic,MidthickSurfs,Column,Priors,Output,PfmDir,WorkbenchBinary);

