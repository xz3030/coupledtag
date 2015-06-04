function [simTag, Wtag, tags, valid_index] = tool_load_wordnet_sim(Wtag, tags, valid_index)
% load wordnet similarity generated by python script
% input:
%      Wtag: 0/1 entrance of tag-image matrix
%      tags: tag list (cell)
%      valid_index: original valid index
% output:
%       simTag: final tag similarity matrix
coupled_config;
% for clustering
Niter = 6;

class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cp.classInd});

%% read valid index file
f = fopen(sprintf('%s/Run%d/wordnet.txt',class_simpath,Niter), 'r');
l1 = fgetl(f);
% valid indices: a line split by space, last number is the total number of
% input tags
G = regexp(l1, ' ','split');
valid_ind = cellfun(@str2num, G);
numTag = valid_ind(end);
valid_ind = valid_ind(1:end-1);

% index map, 0 for drop, 1 for remain
index_map = zeros(size(valid_index));
index_map(valid_ind) = 1;

%% read similarity file
sims = importdata(sprintf('%s/Run%d/wordnet_sim.txt',class_simpath,Niter));
simTag = eye(numTag);
simTag(valid_ind, valid_ind) = sims;

if cp.plus == 0
    return;
end

simTag1 = simTag-eye(numTag);

%% find syns
disp('----------------------------Finding synonyms------------------------------------')
[tmp,ind] = sort(simTag1(:),'descend');
% a list of component id, init as all zeros, syns share a same component id
component_ids = zeros(1,numTag);
% find all syns
syn_ind = find(tmp==1);
% tmp component id
tmpid = 1;
% search
for i=1:length(syn_ind)
    [x,y]=ind2sub([numTag, numTag], ind(i));
    if component_ids(x)==0 && component_ids(y)==0
        % first appearance
        component_ids(x) = tmpid;
        component_ids(y) = tmpid;
        tmpid = tmpid+1;
    else
        % have already got some syns in the list
        alreadyid = max(component_ids(x), component_ids(y));
        component_ids(x) = alreadyid;
        component_ids(y) = alreadyid;
    end
end

%find syns from components
synlist = cell(1,max(component_ids));
for i=1:max(component_ids)
    synind = find(component_ids==i);
    % keep the tag with smallest id, change it into the form t1||t2||...||tn, 
    % drop other tags, replace the dropped tags by the new tag in their
    % images
    join_tag = tags{synind(1)};
    % how many original images tagged with these tags
    sumOriImages = sum(Wtag(:,synind(1)));
    for j = 2:length(synind)
        % concatenate tags
        join_tag = [join_tag '||' tags{synind(j)}];
        % find images that tagged by the dropped tag
        addbackind = find(Wtag(:,synind(j)));
        sumOriImages = sumOriImages + length(addbackind);
        % tag it with the catenated tag.
        Wtag(addbackind, synind(1)) = 1;
        % drop that tag
        index_map(synind(j)) = 0;
    end
    tags{synind(1)} = join_tag;
    % how many images tagged with catenated tag after the job
    sumFinalImages = sum(Wtag(:,synind(1)));
    fprintf('%d synonyms, join tag: %s, %d->%d tags\n', j, join_tag, sumOriImages, sumFinalImages);
    synlist{i} = synind;
end


% filtering
index_map = find(index_map);
valid_index = valid_index(index_map);
Wtag = Wtag(:, index_map);
tags = tags(index_map);
simTag = simTag(index_map, index_map);

%{
N = sum(tmp>0.9);
for i=1:N
    [x,y]=ind2sub([numTag, numTag], ind(i));
    fprintf('%s-%s: %.4f\n', tags{x}, tags{y},tmp(i));
end
%}


end