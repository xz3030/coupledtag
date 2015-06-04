%function analysis_tag_sim_on_inter
coupled_config;

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

[~,ind_tags]=sort(tag_freq,'descend');
ind_tags = ind_tags(1:100);

for i=2:6
    if i==2
        fprintf('\nMost similar tags on user\n');
    else
        fprintf('\nMost similar tags on %s\n', cp.feature_names{i-2});
    end
    Ietag = Ie{1,i};
    Ietag = Ietag-eye(size(Ietag));
    Ietag = Ietag(ind_tags, ind_tags);
    Ietag = Ietag.*(tril(ones(size(Ietag))));
    [tmp,ind]=sort(Ietag(:), 'descend');
    for j=1:10
        [x,y] = ind2sub(size(Ietag), ind(j));
        fprintf('%s to %s: %.4f\n', tags{ind_tags(x)}, tags{ind_tags(y)}, tmp(j));
    end
    keyboard;
end
%end
