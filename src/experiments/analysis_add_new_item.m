%function analysis_add_new_item()
% to calculate the performance and time cost to add a new item to the
% result of the coupled algorithm
% prerequisite: having obtained the result of whole algorithm

coupled_config;

%%
%{=
disp('Loading pre-computed COS')
disp('***************************************')
disp('!Note. Only needed to be load once');
disp('If you''ve already loaded it, then comment next block')
disp('i.e. delete the "=" after {')
disp('***************************************')

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

%%
%id_new = 872;
clc
id_new = floor(rand()*Nim)
ims = imageList{id_new};

%% make sure algorithm is right
indu = find(W{1}(id_new,:));
imsu = users{indu};
imst = tags(find(W{2}(id_new,:)));
same_user_ims = find(W{1}(:,indu));
diff_user_ims = setdiff(1:Nim, same_user_ims);

% print 
disp('*---------------------------------------------*')
disp('*---------------------------------------------*')
disp('Judgement whether the data preprocessing is right');
imshow(imread(fullfile(cp.img_main_dir, cp.classname{cp.classInd}, [ims.id '.jpg'])));
assert(strcmp(ims.username, imsu));
fprintf('User: %s\n', imsu);
fprintf('Original Tags, total %d:', length(ims.tag));
for i=1:length(ims.tag)
    fprintf('\t%s', ims.tag{i}.tag);
end
fprintf('\nFiltered Tags, total %d:', length(imst));
for i=1:length(imst)
    fprintf('\t%s', imst{i});
end
fprintf('\n');
disp('*---------------------------------------------*')
disp('*---------------------------------------------*')

%% start converting infos into data for computing
tic;
userindex = find(cellfun(@(x) strcmp(x,ims.username),users));
taginds = [];
for i=1:length(ims.tag)
    tagindex = find(cellfun(@(x) strcmp(x,ims.tag{i}.tag),tags));
    taginds = [taginds tagindex];
end
% don't know how to index cocatenated tags
taginds=vector_Tag{id_new};

vector = {taginds, userindex};
for i=1:length(feature_bow)
    vector = [vector feature_bow{i}(id_new)];
end

[cos_new, sim_new] = coupled_add_new(vector, vectors, CAVS, Idf, Nim);
disp('*---------------------------------------------*')
disp('*---------------------------------------------*')
fprintf('New item finished in %.4f s\n', toc);
disp('*---------------------------------------------*')
disp('*---------------------------------------------*')

sim_new_same_user = sim_new(same_user_ims);
[tmp, ind] = sort(sim_new, 'descend');
disp('*---------------------------------------------*')
disp('*---------------------------------------------*')

fprintf('Same user: max %.4f, min %.4f\n', tmp(2), tmp(end));

disp('*---------------------------------------------*')
disp('*---------------------------------------------*')
sim_new_diff_user = sim_new(diff_user_ims);
disp('Different user:')
[tmp, ind] = sort(sim_new_diff_user, 'descend');
for i=1:10
    disp('**********************************************')
    fprintf('Start index %d*********************************\n',i);
    id2 = diff_user_ims(ind(i));
    analysis_image_similarity(id_new, id2, imageList, Ia, Idf, Ie, CAVS, COS,...
        COS_Final, tags, vector_Tag, vector_User);
    disp('**********************************************')
    keyboard;
end

%end