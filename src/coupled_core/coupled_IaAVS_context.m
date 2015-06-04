function [Ia, Idf] = coupled_IaAVS_context( vector, N, type )
% IaAVS, only depend on frequency 
coupled_config;
Idf = [];
class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cp.classInd});

if strcmp(type, 'tag')
    [Ia, Idf] = coupled_IaAVS_multi( vector, N );
    load(fullfile(class_simpath, 'Run6/Ia_wordnet.mat'));
    assert(size(Ia,1)==size(simTag,1));
    Ia = simTag;
elseif strcmp(type, 'user')
    Ia = coupled_IaAVS( vector, N );
    load(fullfile(class_simpath, 'Run6/Ia_usercontact.mat'));
    assert(size(Ia,1)==size(contactMap,1));
    Ia = contactMap;
else
    Ia = coupled_IaAVS_imageF( type, cp.classInd );
end
