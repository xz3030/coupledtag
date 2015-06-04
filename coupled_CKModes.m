function coupled_CKModes(COS_Final,W,users,tags,times,valid_imgs1,classname,result_all_path,etime)
% config
coupled_config;
K = cp.Ncluster;
Nitem = size(COS_Final,1);
COStemp = COS_Final.*(ones(Nitem)-eye(Nitem));



%%
%{=
P = randperm(Nitem);
modes = cell(1,K);
for i=1:K
    modes{i} = P((i-1)*cp.Nmode+1:i*cp.Nmode);
end




Niter = 50;
iter = 0;
preLoss = 0;
Loss = 1;
while iter<Niter && (Loss-preLoss)/Loss>0.0001
    iter = iter+1;
    preLoss = Loss;
    
    mode_index = zeros(1,Nitem);
    Loss = 0;
    for i=1:Nitem
        tmp = zeros(1,K);
        for k=1:K
            for j=1:cp.Nmode
                tmp(k) = tmp(k)+COStemp(i, modes{k}(j));
            end
        end
        [tempmax,ind]=max(tmp);
        mode_index(i) = ind;
        Loss = Loss+tempmax;
    end
    Loss
    
    for k=1:K
        ind = find(mode_index==k);
        tmp1 = COStemp(ind,ind);
        [~,maxind] = sort(sum(tmp1,1),'descend');
        modes{k} = ind(maxind(1:cp.Nmode));
    end
end


[Overall, Total_account, Inclass_account] = result_figure1(W,mode_index,users,tags,times,result_all_path);
save(sprintf(cp.tag_result_path, cp.sim_file_path, classname),...
    'Overall', 'Total_account', 'Inclass_account');
%}

for k=1:K
    ind = find(mode_index==k);
    %R = randperm(length(ind));
    R = modes{k};
    k
    for i=1:cp.Nmode
        I = imread(fullfile(cp.img_main_dir, cp.classname{cp.classInd}, valid_imgs1{R(i)}));
        %imshow(I);
        outFName = fullfile(result_all_path, sprintf('%d_%d_%d.jpg',cp.classInd,k,i));
        imwrite(I, outFName, 'jpg');
        %pause;
    end
end

result_mat_file = fullfile(result_all_path, 'result.mat');
save(result_mat_file, 'mode_index', 'modes', 'etime');


end