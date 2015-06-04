%function analysis_tag_sim
% analysis on tag similarity
coupled_config;
%cp.classInd=13;
% ************************************ %
% change tag id if you want, the id x stands for the top x-th tag sorted by frequency.
selected_ind = 23;
% ************************************ %


disp('Loading pre-computed COS')
disp('***************************************')
disp('!Note. Only needed to be load once');
disp('If you''ve already loaded it, then comment next block')
disp('i.e. delete the "=" after {')
disp('***************************************')
%{
times = 6;

if cp.plus == 1
    version = 'context_';
else
    version='';
end
classname = cp.classname{cp.classInd};
class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);
Ia_fileName = sprintf('%s/Run%d/%sIa.mat', class_simpath, times, version);
Ie_fileName = sprintf('%s/Run%d/%sIe.mat', class_simpath, times, version);
CAVS_fileName = sprintf('%s/Run%d/%sCAVS.mat', class_simpath, times, version);
COS_fileName = sprintf('%s/Run%d/%sCOS.mat', class_simpath, times, version);
load(Ia_fileName);
load(Ie_fileName);
load(CAVS_fileName);
load(COS_fileName);
%[simTag, Wtag, tags, valid_index] = tool_load_wordnet_sim(Wtag, tags, valid_index);
%}

% find tags
[~,ind_tags]=sort(tag_freq,'descend');
tags(ind_tags(1:10))
sorted_tags = tags(ind_tags);


%keyboard;
tag_id = ind_tags(selected_ind)
selected_tag = tags{tag_id}

% tag co-occurrence
tag_coc = Wtag1'*Wtag1;
tag_coc_tmp = tag_coc+tag_coc';
tag_freq = diag(tag_coc);
cot = tag_coc(:,tag_id)./(tag_freq+tag_freq(tag_id))*2;
[tmp,ind] = sort(cot,'descend');
disp('tag co-occurrence:')
for i=1:20
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

%{
% intra
disp('Intra coupled');
intra_tag = Ia{1}(:,tag_id);
[tmp,ind] = sort(intra_tag,'descend');
for i=1:10
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')
%}
% inter user
disp('Inter user');
inter_user = Ie{1,2}(:,tag_id);
[tmp,ind] = sort(inter_user,'descend');
for i=1:10
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

% inter cms
disp('Inter color');
inter_color = Ie{1,3}(:,tag_id);
inter_cms = Ie{1,2}(:,tag_id);
[tmp,ind] = sort(inter_color,'descend');
for i=1:10
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

% inter lbp
disp('Inter LBP');
inter_lbp = Ie{1,4}(:,tag_id);
[tmp,ind] = sort(inter_lbp,'descend');
for i=1:10
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

% inter sift
disp('Inter SIFT');
inter_sift = Ie{1,5}(:,tag_id);
[tmp,ind] = sort(inter_sift,'descend');
for i=1:10
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

% inter all
disp('Inter all');
%inter_all = inter_user.*inter_lbp.*inter_sift.*inter_color;
inter_all = [inter_user inter_cms inter_lbp inter_sift inter_color]*...
    cp.feature_weight(2:end)'/sum(cp.feature_weight(2:end));
[tmp,ind] = sort(inter_all,'descend');
for i=1:20
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

% final
disp('Final CAVS');
cavs = CAVS{1}(:,tag_id);
[tmp,ind] = sort(cavs,'descend');
for i=1:20
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')

% wordnet
disp('WordNet');
st = simTag(:,tag_id);
[tmp,ind] = sort(st,'descend');
for i=1:20
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')


% wordnet
disp('WordNet+Coupled');
[tmp,ind] = sort(st*.2+inter_all*.8,'descend');
for i=1:20
    fprintf('%s: %.4f\n', tags{ind(i)}, tmp(i));
end
disp('*************************************')
