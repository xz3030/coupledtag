%function coupled_discovery()
%{=

%% init
coupled_config;

rows=5;
cols=10;
N=rows*cols;

%% load cos
classname = cp.classname{cp.classInd};
class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);
COS_fileName = sprintf('%s/Run%d/%sCOS.mat', class_simpath, 6, '');
load(COS_fileName);
%}
%% iput
% two dimensions
d1=2;
d2=4;
query=880;
%
resultMat=zeros(rows,cols);
resultMat(1:5,1)=1;
resultMat(2:5,2:3)=1;
resultMat(3:5,4:5)=1;
resultMat(4:5,6:7)=1;
resultMat(5,8:9)=1;

%% set candidates
COSd1=COS{d1}(query,:);
COSd2=COS{d2}(query,:);
COS_total=COSd1+COSd2;
%
result_d1=zeros(1,N/2);
result_d2=zeros(1,N/2);
%
[x1,tmp]=sort(COSd1*1000+COSd2,'descend');
cand1=tmp(1:N);
x1=x1(1:N);
%
[x2,tmp]=sort(COSd2*1000+COSd1,'descend');
cand2=tmp(1:N);
x2=x2(1:N);

%% calculate top candidates according to two dimensions
ind=1;
ind_cand1=1;
cand2_map=ones(1,N);
while ind<=N/2
    ind_cand2=find(cand2==cand1(ind_cand1));
    if isempty(ind_cand2)
        result_d1(ind)=cand1(ind_cand1);
        ind=ind+1;
    else
        if ind_cand1<=ind_cand2
            result_d1(ind)=cand1(ind_cand1);
            ind=ind+1;
            cand2_map(ind_cand2)=0;
        end
    end
    ind_cand1=ind_cand1+1;
end
result_d2=cand2(logical(cand2_map));
result_d2=result_d2(1:N/2);
    
%% construct result matrix
[x,y]=ind2sub(size(resultMat),find(resultMat));
for i=1:N/2
    resultMat(x(i),y(i))=result_d1(i);
end

[x,y]=ind2sub(size(resultMat),find(~resultMat));
for i=1:N/2
    resultMat(x(i),y(i))=result_d2(i);
end

%% contruct result image
wi=320;
hi=240;
bigI = zeros(hi*rows, wi*cols, 3);
for i=1:rows
    for j=1:cols
        I=im2double(imread(fullfile(cp.img_main_dir, classname, valid_imgs1{resultMat(i,j)})));
        I=imresize(I,[hi,wi]);
        bigI((i-1)*hi+1:i*hi, (j-1)*wi+1:j*wi, :)=I;
    end
end
figure,imshow(bigI)
%end