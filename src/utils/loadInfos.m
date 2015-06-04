function [W,N,Np,userIdList,users,tags,times,valid_index,imageList] = loadInfos(classInd, valid_imgs)

%
if nargin<2
    isvalid=1;
else
    isvalid=0;
end
%MAX_IMAGES = 5000;

metaDir = '../data/metadata';
filelist=dir(fullfile(metaDir,'*_meta.txt'));
index = 0;
tagIndex = 1;

i = classInd;
%% read file
%{=
imageList = cell(0);
tag_ids = cell(0);
tags=cell(0);
userIdList = cell(0);
users= cell(0);

times = [];
valid_index = [];  %map from index of imageList to index of validimg
fid = fopen(fullfile(metaDir,filelist(i).name), 'r');
while ~feof(fid)
    index = index+1;
    %if index>MAX_IMAGES
    %    break;
    %end
    if mod(index,100)==0
        fprintf('%d\n',index);
    end
    try
    tline = fgetl(fid);
    im = struct();
    S = regexp(tline, '\t', 'split');
    im.id=S{1};
    if isvalid==0
        tmpindex = find(~cellfun(@isempty,strfind(valid_imgs,S{1})));
        if isempty(tmpindex)
            continue
        end
        valid_index = [valid_index tmpindex];
    else
        valid_index = [valid_index index];
    end
    
    im.views=str2num(S{2});
    im.comments=str2num(S{3});
    im.title=S{4};
    im.userID=S{5};
    userIdList = [userIdList S{5}];
    users = [users S{6}];
    im.username=S{6};
    im.time=S{7};
    times = [times datenum(S{7}(1:10),'yyyy-mm-dd')];
    ts = S{8};
    tag = cell(0);
    T = regexp(ts, ' ', 'split');
    for t = 1:length(T)-1
        X = regexp(T{t}, '/', 'split');
        if length(X)<2
            continue
        end
        if isempty(X{2})
            continue
        end
        tag = [tag struct('id',X{1},'tag',X{2})];
        tag_ids = [tag_ids X{1}];
        tags = [tags X{2}];
    end
    im.tag = tag;
    im.tagIndex = tagIndex:tagIndex+length(tag)-1;
    tagIndex = tagIndex+length(tag);
    imageList = [imageList im];
    catch
    end
end
fclose(fid);
%}

[~,time_sort] = sort(times,'ascend');
times = times(time_sort);
imageList = imageList(time_sort);
valid_index = valid_index(time_sort);
userIdList = userIdList(time_sort);
users = users(time_sort);

%% statistics
[ul, um, un]=unique(userIdList);
[ql, qm, qn]=unique(tag_ids);
tags=tags(qm);
users=users(um);
%[dl, m, dn]=unique(times);
tt = sort(times);
mint=tt(floor(length(tt)*0.03)+1);
maxt=tt(floor(length(tt)*0.97)+1);
period = maxt-mint;

%% number
Nu = length(ul);
Nq = length(ql);
Nt = floor(period/3);
Np = length(imageList);
N={Nu,Nq,Nt};

%% declare output files
dpDir = '../data/data_preprocess';
classname = filelist(i).name(1:end-9);
fd_Wuser = fopen(fullfile(dpDir,[classname '_Wuser']), 'wt');
fd_Wtag = fopen(fullfile(dpDir,[classname '_Wtag']), 'wt');
fd_tag = fopen(fullfile(dpDir,[classname '_tag']), 'wt');
fd_user = fopen(fullfile(dpDir,[classname '_user']), 'wt');
fd_image = fopen(fullfile(dpDir,[classname '_photo']), 'wt');
%fd_user_rating_history = fopen(fullfile(dpDir,[classname '_userHistory']), 'wt');
%fd_Wtag_sample = fopen(fullfile(dpDir,[classname '_Wtag_sample']), 'wt');
%fd_Wtag_user = fopen(fullfile(dpDir,[classname '_Wtag_user']), 'wt');
%fd_Wtag_user_sample = fopen(fullfile(dpDir,[classname '_Wtag_user+sample']), 'wt');

%% write matrices
for i=1:length(ql)
    fprintf(fd_tag,'%d\t%s\t%s\n',i,ql{i},tags{i});
end

for i=1:length(ul)
    fprintf(fd_user,'%d\t%s\t%s\n',i,ul{i},users{i});
end

for i=1:length(imageList)
    fprintf(fd_image,'%d\t%s\n',i,imageList{i}.id);
end

% tag_ids ever used by users
userHistory = cell(0);
for i=1:length(ul)
    userHistory{i} = [];
end

%% construct matrices
Wu = zeros(Np,Nu);
Wq = zeros(Np,Nq);
Wt = zeros(Np,Nt);

for j=1:Np
    if j==722
        1
    end
    Wu(j,un(j))=1;
    Wq(j,qn(imageList{j}.tagIndex))=1;
    userHistory{un(j)} = [userHistory{un(j)} qn(imageList{j}.tagIndex)];
    imageList{j}.tagIndex = qn(imageList{j}.tagIndex);
    fprintf(fd_Wuser,'%d\t%d\n',j,un(j));
    for tt=1:length(imageList{j}.tagIndex)
        fprintf(fd_Wtag,'%d\t%d\n',j,qn(imageList{j}.tagIndex(tt)));
    end
    tindex = floor((times(j)-mint)/3);
    tindex = max(1,tindex);
    tindex = min(tindex,Nt);
    Wt(j,tindex)=1;
    h = gaussfir(.3);
    Wt(j,:) = conv(Wt(j,:),h,'same');
end

W={Wu,Wq,Wt};


%{
%% tag_ids ever used by users
%user stats 
length_list = [];
for u=1:length(ul)
    temp = unique(userHistory{u});
    userHistory{u} = temp;
    length_list=[length_list length(temp)];
    %fprintf('%d\n',length(temp));
    for t = 1:min(10,length(temp))
    %    fprintf('%s\t',tags{temp(t)});
        fprintf(fd_user_rating_history,'%s\t',temp(t));
    end
    fprintf(fd_user_rating_history,'\n');
    %disp('');
end
mean_history_len = mean(length_list);
mean_history_len = floor(mean_history_len)*2;

% write matrices
% 1) random sample
for i=1:Np
    ind_pos = find(Wq(i,:));
    ind_neg = find(Wq(i,:)==0);
    for d = ind_pos
        fprintf(fd_Wtag_sample,'%d\t%d\t1\n',i,d);
    end
    R = randperm(length(ind_neg));
    for d = ind_neg(R(1:mean_history_len))
        fprintf(fd_Wtag_sample,'%d\t%d\t0\n',i,d);
    end
end

% 2) user history based
for i=1:Np
    ind_pos = find(Wq(i,:));
    u = un(i);
    utag_ids = userHistory{u};
    ind_neg = setdiff(utag_ids, ind_pos);
    for d = ind_pos
        fprintf(fd_Wtag_user,'%d\t%d\t1\n',i,d);
    end
    for d = ind_neg
        fprintf(fd_Wtag_user,'%d\t%d\t0\n',i,d);
    end
end


% 3) user history based + random sample
for i=1:Np
    ind_pos = find(Wq(i,:));
    u = un(i);
    utag_ids = userHistory{u};
    ind_neg = setdiff(utag_ids, ind_pos);
    if length(ind_neg)<mean_history_len
        R = randperm(Nq - length(ind_neg)- length(ind_pos));
        remains = setdiff(1:Nq, ind_pos);
        remains = setdiff(remains, ind_neg);
        ind_neg = [ind_neg remains(R(1:mean_history_len - length(ind_neg)))];
    end
        
    for d = ind_pos
        fprintf(fd_Wtag_user_sample,'%d\t%d\t1\n',i,d);
    end
    for d = ind_neg
        fprintf(fd_Wtag_user_sample,'%d\t%d\t0\n',i,d);
    end
end


fclose(fd_user_rating_history);
fclose(fd_Wtag_sample);
fclose(fd_Wtag_user);
fclose(fd_Wtag_user_sample);
%}
fclose(fd_Wuser);
fclose(fd_Wtag);
fclose(fd_user);
fclose(fd_tag);
fclose(fd_image);


end

