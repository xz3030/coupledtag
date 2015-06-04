function [cos_new, sim_new] = coupled_add_new(vector, vectors, CAVS, Idf, Nitem)
% add new item 
% vectors: feature of the new item

coupled_config;
Ndim = length(vector);

% COS
disp('Start COS');
cos_new = zeros(Ndim, Nitem);
for i=1:Ndim
    vectori = vector{i};
    if length(vectori)>1
        Idfi = Idf{i};
        cos_new(i,:) = coupled_COS_multi(CAVS{i}, vectori, vectors{i}, Nitem, Idfi);
    else
        cos_new(i,:) = coupled_COS(CAVS{i}, vectori, vectors{i}, Nitem);
    end
    
end
sim_new = cp.feature_weight*cos_new;
end



function COS = coupled_COS(CAVS, vector, vectors, Nitem)
%% cos user
COS = zeros(1, Nitem);
if isempty(vector)
    return;
end
for j=1:Nitem
    COS(j)=CAVS(vector,vectors(j));
end

end


function COS = coupled_COS_multi(CAVS, vector, vectors, Nitem, idf)

COS = zeros(1,Nitem);
for j=1:Nitem
    ti = vector;
    tj = vectors{j};
    simsub = CAVS(ti,tj);
    lti = length(ti);
    ltj = length(tj);
    tempsim = 0;
    
    while lti~=0 && ltj~=0 && sum(simsub(:))~=0
        [sim,ind]=max(simsub(:));
        [x,y]=ind2sub(size(simsub),ind);
        abst = min(idf(ti(x)),idf(tj(y)));
        %fprintf('Match: %s to %s, Sim: %f, abst %.4f\n',tags{ti(x)},tags{tj(y)},sim, abst)
        tempsim = tempsim+sim*abst;
        simsub(x,:)=0;
        simsub(:,y)=0;
        lti=lti-1;
        ltj=ltj-1;
    end
    COS(j)=tempsim;
end
COS = 2./(1+exp(-COS))-1;

end