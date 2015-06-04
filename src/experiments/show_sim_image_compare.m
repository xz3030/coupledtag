%function show_sim_image_compare
%{=
coupled_config;
ind = find(train_or_test);
R=find(train_or_test==0);
%R=R(randperm(length(R)));

classname = cp.classname{cp.classInd};
class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);

COS_all = cell(1,5);

for Niter = 1:5
    COS_fileName = sprintf('%s/Run%d/%sCOS.mat', class_simpath, Niter, '');
    COS_all{Niter} = load(COS_fileName);
end

m = 200;
h = 160;
dist_pair_tmp = cell(1,4);
for f=1:4
    dist_pair_tmp{f} = tool_dist2(feature_all{f}, feature_all{f}, 'ang');
end
dist_pair_tag = W{2}*W{2}';
dist_pair_tag = dist_pair_tag./repmat(diag(dist_pair_tag),1,Nim);
%}
%%
%R=randperm(Nim);
for ii=131
    bigI = zeros(5*(h+10), cp.nnnum*(m+10), 3);
    i = R(ii);
    us = vector_User(i);
    tj = vector_Tag_all{i};
    fprintf('%d  ',i);
    for pp=1:length(tj)
        fprintf('%s\t',tags{tj(pp)});
    end
    fprintf('\n');
    uind = find(W{1}(:,us));
    ims = imageList{i};
    I1=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{i}));
    figure(1),imshow(I1);
    figure(2)
    
    row_num = 0;
    %% row 1, COS
    for Niter = 1:5
        similarity = COS_all{Niter}.COS_Final(i,ind);
        [xx,yy]=sort(similarity,'descend');
        for j=1:cp.nnnum
            I2=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{ind(yy(j))}));
            %I2=tool_resize_image(I2, m, h);
            I2=imresize(I2,[h,m]);
            I2=im2double(I2);
            w2 = size(I2,1);
            h2 = size(I2,2);
            bigI((h+10)*row_num+1:(h+10)*row_num+w2, (j-1)*(m+10)+1:(j-1)*(m+10)+h2, :)=I2;
        end
        row_num = row_num+1;
    end
    
    %% row 2, imageFeature
    similarity = dist_pair(i,ind);
    [xx,yy]=sort(similarity,'descend');
    for j=1:cp.nnnum
        I2=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{ind(yy(j))}));
        %I2=tool_resize_image(I2, m, h);
        I2=imresize(I2,[h,m]);
        I2=im2double(I2);
        w2 = size(I2,1);
        h2 = size(I2,2);
        bigI((h+10)*row_num+1:(h+10)*row_num+w2, (j-1)*(m+10)+1:(j-1)*(m+10)+h2, :)=I2;
    end
    row_num = row_num+1;
    
    %{
    %% row 3-6, different features
    for rowN=1:4
        dp = dist_pair_tmp{rowN};
        similarity = dp(i,ind);
        [xx,yy]=sort(similarity,'descend');
        for j=1:cp.nnnum
            I2=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{ind(yy(j))}));
            I2=tool_resize_image(I2, m, h);
            I2=im2double(I2);
            w2 = size(I2,1);
            h2 = size(I2,2);
            bigI((m+10)*row_num+1:(m+10)*row_num+w2, (j-1)*(m+10)+1:(j-1)*(m+10)+h2, :)=I2;
        end
        row_num = row_num+1;
    end
    %}
    
    %% row 7, tag
    similarity = sum(dist_pair_tag(i,ind),1);
    [xx,yy]=sort(similarity,'descend');
    for j=1:cp.nnnum
        I2=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{ind(yy(j))}));
        %I2=tool_resize_image(I2, m, h);
        I2=imresize(I2,[h,m]);
        I2=im2double(I2);
        w2 = size(I2,1);
        h2 = size(I2,2);
        bigI((h+10)*row_num+1:(h+10)*row_num+w2, (j-1)*(m+10)+1:(j-1)*(m+10)+h2, :)=I2;
    end
    row_num = row_num+1;
    
    %{
    %% row 8, user image
    uind1 = intersect(ind,uind);
    similarity = dist_pair(i,uind1);
    [xx,yy]=sort(similarity,'descend');
    for j=1:min(cp.nnnum,length(yy))
        I2=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{uind1(yy(j))}));
        I2=tool_resize_image(I2, m, h);
        I2=im2double(I2);
        w2 = size(I2,1);
        h2 = size(I2,2);
        bigI((m+10)*row_num+1:(m+10)*row_num+w2, (j-1)*(m+10)+1:(j-1)*(m+10)+h2, :)=I2;
    end
    row_num = row_num+1;
    
    
    %% row 8, user tag
    uind1 = intersect(ind,uind);
    similarity = sum(dist_pair_tag(i,uind1),1);
    [xx,yy]=sort(similarity,'descend');
    for j=1:min(cp.nnnum, length(yy))
        I2=imread(fullfile(cp.img_main_dir, classname, valid_imgs1{uind1(yy(j))}));
        I2=tool_resize_image(I2, m, h);
        I2=im2double(I2);
        w2 = size(I2,1);
        h2 = size(I2,2);
        bigI((m+10)*row_num+1:(m+10)*row_num+w2, (j-1)*(m+10)+1:(j-1)*(m+10)+h2, :)=I2;
    end
    row_num = row_num+1;
    %}
    
    %%
    imshow(bigI,[]);
    pause;
end
    

%end