function coupled_show(COS, COS_Final, tags, vector_Tag, Nim, classname, valid_imgs1)
% config
coupled_config;
% for i=1:length(COS)
%     tmp = COS{i};
%     tmp1 = tmp-eye(size(tmp));
%     mm = std(tmp1(:));
%     COS{i} = tmp/mm;
% end
%% find nearest neighbour
R=randperm(Nim);
for ii=1:Nim
    i=R(ii);
    similarity = COS_Final(i,:);
    %similarity = COS{1}(i,:)+COS{2}(i,:)+COS{3}(i,:)+COS{4}(i,:)+COS{5}(i,:)+COS{6}(i,:);
    
    [xx,yy]=sort(similarity,'descend');
    disp('Original tags:');
    ti = vector_Tag{i};
    for pp=ti
        fprintf('%s\t',tags{pp});
    end
    fprintf('\n');
    subplot(1,2,1),imshow(imread(fullfile(cp.img_main_dir, classname, valid_imgs1{i})));
    %subplot(1,2,1),imshow(imread(fullfile(cp.img_main_dir, classname, [imageList{valid_index(i)}.id '.jpg'])));
    
    fprintf('Similar Image Tags:\n');
    for j=yy(1:10)
        fprintf('%d: ',j);
        for dd = 1:length(COS)
            fprintf('%f  ',COS{dd}(i,j));
        end
        tj=vector_Tag{j};
        for pp=tj
            fprintf('%s\t',tags{pp});
        end
        fprintf('\n');
        subplot(1,2,2),imshow(imread(fullfile(cp.img_main_dir, classname, valid_imgs1{j})));
        %subplot(1,2,2),imshow(imread(fullfile(cp.img_main_dir, classname, [imageList{valid_index(j)}.id '.jpg'])));
    
        pause;
    end
end


end