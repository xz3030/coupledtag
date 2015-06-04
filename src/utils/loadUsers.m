function [userList, contactMap] = loadUsers(classInd, users, friend_coefficient)
%%
%{=
disp('Load users');
userDir = '../data/user';
img_main_dir = '../data/images/';
groupList = dir(img_main_dir);
groupId = groupList(classInd+2).name;

metaDir = '../data/metadata';
metaFile = fullfile(metaDir, [groupId '_user.txt']);
%{=
N = 5000;
userList = cell(1,N);
profileurls = cell(1,N);
ids = cell(1,N);
%groups = cell(0);
index = 0;
fid = fopen(metaFile, 'r');
while ~feof(fid)
    index = index+1;
    %if mod(index,100)==0, fprintf('%d\n',index); end
    tline = fgetl(fid);
    user = struct();
    S = regexp(tline, '\t', 'split');
    user.id = S{1};
    ids{index} = S{1};
    user.name = S{2};
    user.gender = S{3};
    user.profileurl = S{4};
    purl = S{4};
    purl = purl(30:end);
    profileurls{index} = purl;
    user.location = S{5};
    user.timezone = S{6};
    user.firstdatetaken = S{7};
    user.firstdate = S{8};
    user.count = str2num(S{9});
    %{
    group = cell(0);
    for t = 10:length(S)-1
        X = regexp(S{t}, '/', 'split');
        group = [group struct('id',X{1},'name',X{2},'count',X{3})];
        groups = [groups X{1}];
    end
    user.group = group;
    %}
    user.contacts = cell(0);
    userList{index} = user;

end
fclose(fid);

userList = userList(1:index);
profileurls = profileurls(1:index);
ids = ids(1:index);


%%


userDir = ['../data/user/' groupId];

contactList = dir(fullfile(userDir,'*.txt'));
for c=1:length(contactList)
    S = regexp(contactList(c).name, '_', 'split');
    userid = S{1};
    %userid
    if mod(c,100)==0, fprintf('%d/%d\n',c, length(contactList)); end
    index = find(ismember(ids,userid));
    fd = fopen(fullfile(userDir,contactList(c).name),'r');
    while ~feof(fd)
        tline = fgetl(fd);
        if tline==-1
            break;
        end
        indf = find(ismember(profileurls,tline));
        if ~isempty(indf)
            try
            userList{index}.contacts = [userList{index}.contacts indf];
            catch
                keyboard;
            end
        end
    end
    fclose(fd);
end


%%
c=[];
y=[];
x=[];
m = zeros(length(userList),length(userList));
for i=1:length(userList)
    c = [c length(userList{i}.contacts)];
    m(i,cell2mat(userList{i}.contacts))=1;
    x=[x i*ones(1,length(userList{i}.contacts))];
    y=[y cell2mat(userList{i}.contacts)];
end
sparsity = sum(sum(m))/size(m,1)/size(m,2);
fprintf('Sparsity is :%f\n',sparsity)
hist(c)
scatter(x,y,'.')
%}

%% reorder according to struct users
numUser = length(users);
reindex = zeros(1,length(contactList));
for u = 1:length(userList)
    tmpindex = find(~cellfun(@isempty,strfind(users,userList{u}.name)));
    if isempty(tmpindex)
        %fprintf('Empty %d\n',u);
        continue
    end
    if length(tmpindex)>1
        for t = tmpindex
            if strcmp(users{t},userList{u}.name)
                tmpindex=t;
                break;
            end
        end
    end
    
    reindex(u) = tmpindex;
end

%% regenerate contactMap
contactMap = zeros(numUser);
for u = 1:length(userList)
    for i=1:length(userList{u}.contacts)
        if reindex(u)==0 || reindex(userList{u}.contacts{i})==0
            continue
        end
        contactMap(reindex(u), reindex(userList{u}.contacts{i}))=1;
    end
end

% add oneself to contactMap
contactMap = friend_coefficient*contactMap+eye(numUser);

end