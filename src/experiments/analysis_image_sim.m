%function analysis_image_sim
coupled_config;


disp('Loading pre-computed COS')
disp('***************************************')
disp('!Note. Only needed to be load once');
disp('If you''ve already loaded it, then comment next block')
disp('i.e. delete the "=" after {')
disp('***************************************')
%{=
times = 6;
if cp.plus == 1
    version = 'context_';
else
    version='';
end
classname = cp.classname{cp.classInd};
cp.sim_file_path = ['../data/coupled_sim_' cp.mode];
class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);
Ia_fileName = sprintf('%s/Run%d/%sIa.mat', class_simpath, times, version);
Ie_fileName = sprintf('%s/Run%d/%sIe.mat', class_simpath, times, version);
CAVS_fileName = sprintf('%s/Run%d/%sCAVS.mat', class_simpath, times, version);
COS_fileName = sprintf('%s/Run%d/%sCOS.mat', class_simpath, times, version);
load(Ia_fileName);
load(Ie_fileName);
load(CAVS_fileName);
load(COS_fileName);
COS_Final = zeros(Nim);
%weight = ones(1,Ndim)/Ndim;
weight = cp.feature_weight;
for i=1:length(COS)
    COS_Final = COS_Final+COS{i}*weight(i);
end
%}

fprintf('All together %d images\n\n', Nim);

% dhisect = cell(1,4);
% for i=1:4
%     f = feature_all{i};
%     dhisect{i} = hist_isect_c(f,f);
% end

while 1
%% start
%id1 = 270;
%id2 = 290;
%id1 = floor(rand()*Nim)+1
%id2 = floor(rand()*Nim)+1
id1 = 438;
id2 = 1709;
analysis_image_similarity(id1, id2, imageList, Ia, Idf, Ie, CAVS, COS,...
COS_Final, tags, vector_Tag, vector_User);

keyboard;
end
%end