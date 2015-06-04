function [COS, COS_Final, Ia, Idf, types, Ie, CAVS] = coupled_main(vectors, Ns, types, iscontext, isshow, feature_weight)
% main function of coupled item interaction similarity measure
% vectors: cell of feature vectors, each dimension of 1*Nitem
%          in each vector: 1*N cell or list
% Ns: total number of each feature.
% types: type of each feature.
%        tag: multiple, cell
%        user: single, intra
%        cms, colorhist, ...: single, bow

Nvector = length(vectors);
if nargin<6
    feature_weight = ones(1,Nvector)/Nvector;
end

Nitem = length(vectors{1});
Ndim = length(Ns);

% IaAVS
if isshow, disp('Start IaAVS'); end
Ia = cell(1,Ndim);
Idf = cell(1,Ndim);
for i=1:Ndim
    tic
    vectori = vectors{i};
    Ni = Ns{i};
    typei = types{i};
    
    if iscontext
        [Ia{i}, Idf{i}] = coupled_IaAVS_context( vectori, Ni, typei );
    else
        if strcmp(typei, 'tag')
            %[Ia{i}, Idf{i}] = coupled_IaAVS_multi_v0( vectori, Ni );
            [Ia{i}, Idf{i}] = coupled_IaAVS_multi( vectori, Ni );
        elseif strcmp(typei, 'user') || ~isempty(strfind(typei,'tag'))
            Ia{i} = coupled_IaAVS( vectori, Ni );
        else
            Ia{i} = coupled_IaAVS_imageF( typei, classInd );
        end
    end
    if isshow, fprintf('End IaAVS %d/%d in %.5f seconds\n',i,Ndim,toc); end
end

% IeAVS
if isshow, disp('Start IeAVS'); end

Ie = cell(Ndim);
for i=1:Ndim
    vectori = vectors{i};
    Ni = Ns{i};
    for j=1:Ndim
        tic;
        if i==j
            continue
        end
        vectorj = vectors{j};
        Nj = Ns{j};
        Ie{i,j} = coupled_IeAVS_IRSI( vectori, vectorj, Ni, Nj );
        if isshow, fprintf('End IeAVS (%d,%d)/(%d,%d) in %.5f seconds\n',i,j,Ndim,Ndim,toc); end;
    end
end


% Ia
if isshow, disp('Start Ia'); end

CAVS = cell(1,Ndim);
for i=1:Ndim
    tic;
    CAVS{i} = Ia{i};
    Ietemp = zeros(Ns{i});
    for j=1:Ndim
        tic;
        if j~=i
            Ietemp=Ietemp+Ie{i,j}*feature_weight(j);
        end
    end
    Ietemp = Ietemp/sum(feature_weight);
    
    CAVS{i} = (CAVS{i}+Ietemp)/2;
    %CAVS{i} = CAVS{i}.*Ietemp;
    if isshow, fprintf('End Ia %d/%d in %.5f seconds\n',i,Ndim,toc); end
end


% COS
if isshow, disp('Start COS'); end
COS = cell(0);
for i=1:Ndim
    tic;
    vectori = vectors{i};
    if iscell(vectori)
        Idfi = Idf{i};
        COS{i} = coupled_COS_multi(CAVS{i}, vectori, Nitem, Idfi);
    else
        COS{i} = coupled_COS(CAVS{i}, vectori, Nitem);
    end
    if isshow, fprintf('End COS %d/%d in %.5f seconds\n',i,Ndim,toc); end
end

%final cos
if isshow, disp('Final COS'); end
COS_Final = zeros(Nitem);
%weight = ones(1,Ndim)/Ndim;
weight = feature_weight;
for i=1:Ndim
    COS_Final = COS_Final+COS{i}*weight(i);
end

end



function COS = coupled_COS(CAVS, vector, Nitem)
%% cos user
COS = zeros(Nitem);
for i=1:Nitem
    for j=i:Nitem
        COS(i,j)=CAVS(vector(i),vector(j));
    end
end
COS = COS+COS'-COS.*eye(Nitem);



end


function COS = coupled_COS_multi(CAVS, vector, Nitem, idf)

COS = zeros(Nitem);
for i=1:Nitem
    for j=i:Nitem
        ti = vector{i};
        tj = vector{j};
        simsub = CAVS(ti,tj);
        lti = length(ti);
        ltj = length(tj);
        tempsim = 0;
        
        while lti~=0 && ltj~=0 && sum(simsub(:))~=0
            [sim,ind]=max(simsub(:));
            [x,y]=ind2sub(size(simsub),ind);
            %fprintf('Match: %s to %s, Sim: %f\n',tags{ti(x)},tags{tj(y)},sim)
            tempsim = tempsim+sim*min(idf(ti(x)),idf(tj(y)));
            simsub(x,:)=0;
            simsub(:,y)=0;
            lti=lti-1;
            ltj=ltj-1;
        end
        COS(i,j)=tempsim;
    end
end
COS = COS+COS'-COS.*eye(Nitem);
COS = 2./(1+exp(-COS))-1;

end