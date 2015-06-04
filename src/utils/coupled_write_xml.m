function coupled_write_xml(imageList)

coupled_config;

class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cp.classInd});
result_file_path = [class_simpath sprintf('/Run%d/result_%d.mat',6,cp.nnnum) ];
result_all_path = sprintf('%s/%d_CP',cp.result_path,cp.classInd);
load(sprintf(cp.tag_result_path, cp.sim_file_path, cp.classname{cp.classInd}));

Overall_count = zeros(1,length(Overall));
for i = 1:length(Overall)
    Overall_count(i) = Overall{i}.count;
end
Overall_count = 100 + 200*(Overall_count-min(Overall_count))/(max(Overall_count)-min(Overall_count));
tags_xml = coupled_tag2xml(Overall, Overall_count, Inclass_account, result_all_path);


result_mat_file = fullfile(result_all_path, 'result.mat');
xx=load(result_mat_file);

coupled_img2xml( imageList, xx.modes, xx.mode_index, result_all_path);
end


function tags = coupled_tag2xml(Overall, Overall_count, Inclass_account, result_all_path)
% turn result into xml

coupled_config;

%
tags = struct;
tags.ATTRIBUTE.groupName = cp.classname{cp.classInd};
%XMLRoot.ATTRIBUTE.type = 'image';
for o=1:length(Overall)
    tname = Overall{o}.name;
    tcount = Overall_count(o);
    tags.tag(o).name = tname;
    tags.tag(o).tid = o;
    tags.tag(o).meuPeso = 5;
    tags.tag(o).size = tcount;
end

wPref.StructItem = false;
outFName = fullfile(result_all_path, 'tag_all.xml');
xml_write(outFName,tags,'tags',wPref);

tags = struct;
tags.ATTRIBUTE.groupName = cp.classname{cp.classInd};
for c = 1:size(Inclass_account,1)
    tempcluster = struct;
    for i = 1:size(Inclass_account,2)
        if isempty(Inclass_account{c,i})
            continue
        end
        tempcluster.tag(i).name = Inclass_account{c,i}.name;
        tempcluster.tag(i).count = Inclass_account{c,i}.count;
    end
    tags.cluster(c) = tempcluster;
end

wPref.StructItem = false;
outFName = fullfile(result_all_path, 'tag_cluster.xml');
xml_write(outFName,tags,'tags',wPref);
end




function coupled_img2xml( imageList, modes, mode_index, result_all_path)
% turn result into xml
coupled_config;
%
group = struct;
group.ATTRIBUTE.groupName = cp.classname{cp.classInd};

for c = 1:length(modes)
    tempcluster = struct;
    cind = find(mode_index==c);
    for i = 1:length(modes{c})
        ims = imageList{modes{c}(i)};
        ims = rmfield(ims,'tagIndex');
        tags = ims.tag;
        tempimg = rmfield(ims,'tag');
        for j=1:length(tags)
            tempimg.tag(j).ATTRIBUTE = tags{j};
        end
        tempcluster.img(i) = tempimg;
    end
    group.cluster(c) = tempcluster;
end

wPref.StructItem = false;
outFName = fullfile(result_all_path, 'image_cluster.xml');
xml_write(outFName,group,'group',wPref);
end