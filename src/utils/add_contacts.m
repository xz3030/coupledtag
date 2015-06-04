%function add_contacts(users, result, userList)

%%
numUser = length(users);
reindex = zeros(1,numUser);
for u = 1:length(userList)
    tmpindex = find(~cellfun(@isempty,strfind(users,userList{u}.name)));
    if isempty(tmpindex)
        fprintf('Empty %d\n',u);
        continue
    end
    reindex(u) = tmpindex;
end

contactMap = zeros(numUser);
for u = 1:length(userList)
    for i=1:length(userList{u}.contacts)
        if reindex(u)==0 || reindex(userList{u}.contacts{i})==0
            continue
        end
        contactMap(reindex(u), reindex(userList{u}.contacts{i}))=1;
    end
end

%% reorder
reorder = zeros(1,numUser);
index=1;
for c=1:max(result)
    fprintf('\nClass %d:\n',c)
    ind = find(maxC==c);
    numt = numC(ind);
    [waste,ord] = sort(numt,'descend');
    reorder(index:index+length(ind)-1)=ind(ord);
    index = index+length(ind);
end

%% order back
order = zeros(size(reorder));
for r=1:length(reorder)
    order(reorder(r))=r;
end

%% project
x=[];
y=[];
tempInd=0;
for j=1:size(contactMap,1)
    t = find(contactMap(j,:));
    x = [x tempInd*ones(size(t))];
    y = [y order(t)];
    tempInd = tempInd+1;
end
figure,
scatter(x,y,'b.');
pause;

%end