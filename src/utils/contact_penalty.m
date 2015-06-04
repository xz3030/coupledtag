function contact_penalty(users, result_u, prob_all_u, userList)

%% reorder according to struct users
numUser = length(users);
reindex = zeros(1,numUser);
for u = 1:length(userList)
    tmpindex = find(~cellfun(@isempty,strfind(users,userList{u}.name)));
    if isempty(tmpindex)
        fprintf('Empty %d\n',u);
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
contactMap = contactMap+eye(numUser);

%% contactMap according to result of soft clustering
cM1 = prob_all_u'*prob_all_u;
dist = sum(sum(abs(cM1-contactMap)))
D = KDdist(contactMap,cM1)

%% compare to random
prand = rand(size(prob_all_u));
prand = prand./repmat(sum(prand,1),size(prand,1),1);
cmRand = prand'*prand;
distrand = sum(sum(abs(cmRand-contactMap)))
Drand = KDdist(contactMap,cmRand)

%% 
right=[];
wrong=[];
for i=1:numUser
    t = find(contactMap(i,:));
    classi=result_u(i);
    tempright=0;
    tempwrong=0;
    for tt = t
        if result_u(tt)==classi
            tempright=tempright+1;
        else
            tempwrong=tempwrong+1;
        end
    end
    right = [right tempright];
    wrong = [wrong tempwrong];
end
mean_right = mean(right)
mean_wrong = mean(wrong)
    
end



function D = KDdist(A,B)
A = A+eps;
B = B+eps;
D=sum(sum(A.*log(A./B)-A+B));
end