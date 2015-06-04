function [feature_all, valid_ind, valid_imgs] = load_features_v2(classInd)

MAX_IMAGES = 3000;
%MAX_IMAGES = 100000;

feature_dir = '../data/features';
sift_feature_dir = '../data/sift_features';
img_main_dir = '../data/images/';

cm_feature = dir([feature_dir '/*_colormoment.mat']);
ch_feature = dir([feature_dir '/*_colorhist.mat']);
cblp_feature = dir([feature_dir '/*_cblp.mat']);


categs = dir(img_main_dir);
categs = categs(3:end);

c=classInd;
classname = categs(c).name;
imgs = dir(fullfile(img_main_dir,classname));
imgs = imgs(3:end);

Nim = length(imgs);
filenames=cell(1,Nim);
for t = 1:Nim
    filenames{t}=imgs(t).name;
end


load(fullfile(feature_dir,[classname '_colormoment.mat']));%cms
cl_ind = load(fullfile(feature_dir,[classname '_imageList.mat']));
cl_ind = cl_ind.valid_ind;

max_var = max(max(cms));
for t=1:16
    cms(:,t*6-5:t*6-3) = cms(:,t*6-5:t*6-3)/256;
    %xx = cms(:,t*6-2:t*6);
    %cms(:,t*6-2:t*6) = xx./repmat(max(xx),size(xx,1),1);
    cms(:,t*6-2:t*6) = cms(:,t*6-2:t*6)/max_var;
end
cms = cms./repmat(sum(cms,2),1,size(cms,2));

cms_all = zeros(Nim, size(cms,2));
cms_all(find(cl_ind), :) = cms;

load(fullfile(feature_dir,[classname '_colorhist.mat']));%hist_all
hist_all = hist_all./repmat(sum(hist_all),size(hist_all,1),1);

hist_all1 = zeros(Nim,size(hist_all,1));
hist_all1(find(cl_ind), :) = hist_all';
hist_all = hist_all1;

load(fullfile(feature_dir,[classname '_cblp.mat']));%CLBP_SH_all,CLBP_MH_all
CLBP_SH_all = CLBP_SH_all/mean(mean(CLBP_SH_all));
CLBP_SH_all = 2./(1+exp(-CLBP_SH_all))-1;
CLBP_MH_all = CLBP_SH_all/mean(mean(CLBP_MH_all));
CLBP_MH_all = 2./(1+exp(-CLBP_MH_all))-1;

CLBP_SH_all = CLBP_SH_all./repmat(sum(CLBP_SH_all,2),1,size(CLBP_SH_all,2));
CLBP_MH_all = CLBP_MH_all./repmat(sum(CLBP_MH_all,2),1,size(CLBP_MH_all,2));
CLBP_all = [CLBP_SH_all CLBP_MH_all];

lbp_ind = load(fullfile(feature_dir,[classname '_imageList_texture.mat']));
lbp_ind = lbp_ind.valid_ind;

CLBP_all1 = zeros(Nim,size(CLBP_all,2));
CLBP_all1(find(lbp_ind), :) = CLBP_all;
CLBP_all = CLBP_all1;

%tmp=1;

ims = dir(fullfile(sift_feature_dir,classname));
ims = ims(3:end);
sift_filenames=zeros(1,length(ims));
for t = 3:length(ims)
    sift_filenames(t)=str2num(ims(t).name(1:end-4));
end

iii=0;
sift_ind = zeros(1,Nim);
for i=1:min(MAX_IMAGES,Nim)
    image_id = str2num(filenames{i}(1:end-4));
    tmpindex = find(sift_filenames==image_id);
    %while ~strcmp(imgs(tmp).name(1:end-4),ims(i).name(1:end-4)) && tmp<=length(imgs)
    %    tmp = tmp+1;
    %end
    if isempty(tmpindex)
        continue
    end
    sift_ind(i)=1;
    iii=iii+1;
    if mod(i,100)==0
        fprintf('%d/%d\n',i,Nim);
    end
    [d , f] = readBinaryDescriptors(fullfile(sift_feature_dir,classname,ims(tmpindex).name));
    if iii==1
        siftbow_all = zeros(Nim, length(d));
    end
    siftbow_all(i,:) = d;
end

valid_ind = sift_ind & cl_ind & lbp_ind';


feature_all = {cms_all(valid_ind,:), hist_all(valid_ind,:),...
    CLBP_all(valid_ind,:), siftbow_all(valid_ind, :)};


valid_imgs = filenames(valid_ind);

end