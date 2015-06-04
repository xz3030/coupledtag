function Ia = coupled_IaAVS_imageF( type, classInd )
% IaAVS, only depend on frequency 
coupled_config;

type_ind = find(~cellfun(@isempty,strfind(cp.feature_names,type)));
dictFName = sprintf(cp.dict_path, cp.classname{classInd}, cp.feature_names{type_ind});
load(dictFName);

Ia = tool_dist2(dictionary,dictionary,'ang');


end