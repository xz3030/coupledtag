function [COS, COS_Final] = coupled_main_test(classInd, vectors, Ns, types, times, version)
% main function of coupled item interaction similarity measure
% vectors: cell of feature vectors, each dimension of 1*Nitem
%          in each vector: 1*N cell or list
% Ns: total number of each feature.
% types: type of each feature.
%        tag: multiple, cell
%        user: single, intra
%        cms, colorhist, ...: single, bow
% version: '': new
%          'ori':original version
coupled_config;
Nitem = length(vectors{1});
Ndim = length(Ns);
classname = cp.classname{classInd};

class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);

% IaAVS
Ia_fileName = sprintf('%s/Run%d/%sIa.mat', class_simpath, times, version);
if exist(Ia_fileName,'file') && canSkip
    load(Ia_fileName);
else
    disp('Start IaAVS');
    Ia = cell(1,Ndim);
    Idf = cell(1,Ndim);
    for i=1:Ndim
        tic
        vectori = vectors{i};
        Ni = Ns{i};
        typei = types{i};
        if strcmp(typei, 'tag')
            [Ia{i}, Idf{i}] = coupled_IaAVS_multi( vectori, Ni );
        elseif strcmp(typei, 'user') || ~isempty(strfind(typei,'tag'))
            Ia{i} = coupled_IaAVS( vectori, Ni );
        else
            Ia{i} = coupled_IaAVS_imageF( typei, classInd );
        end
        fprintf('End IaAVS %d/%d in %.5f seconds\n',i,Ndim,toc);
    end
    %save(Ia_fileName,'Ia','Idf','types');
end

% IeAVS
disp('Start IeAVS');
Ie_fileName = sprintf('%s/Run%d/%sIe.mat', class_simpath, times, version);
if exist(Ie_fileName,'file') && canSkip
    load(Ie_fileName);
else
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
            fprintf('End IeAVS (%d,%d)/(%d,%d) in %.5f seconds\n',i,j,Ndim,Ndim,toc);
        end
    end

    %save(Ie_fileName,'Ie');
end


% Ia
disp('Start Ia');
CAVS_fileName = sprintf('%s/Run%d/%sCAVS.mat', class_simpath, times, version);
if exist(CAVS_fileName,'file') && canSkip
    load(CAVS_fileName);
else
    CAVS = cell(1,Ndim);
    for i=1:Ndim
        tic;
        tempweight = cp.feature_weight;
        tempweight(i)=0;
        CAVS{i} = Ia{i};
        Ietemp = zeros(Ns{i});
        for j=1:Ndim
            tic;
            if j~=i
                Ietemp=Ietemp+Ie{i,j}*tempweight(j);
            end
        end
        Ietemp = Ietemp/sum(tempweight);
        
        CAVS{i} = CAVS{i}.*Ietemp;
        fprintf('End Ia %d/%d in %.5f seconds\n',i,Ndim,toc);
    end

    %save(CAVS_fileName,'CAVS');
end

% COS
disp('Start COS');
COS_fileName = sprintf('%s/Run%d/%sCOS.mat', class_simpath, times, version);
if exist(COS_fileName,'file') && canSkip
    load(COS_fileName);
else
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
        fprintf('End COS %d/%d in %.5f seconds\n',i,Ndim,toc);
    end

    %final cos
    disp('Final COS');
    COS_Final = zeros(Nitem);
    %weight = ones(1,Ndim)/Ndim;
    weight = cp.feature_weight;
    for i=1:Ndim
        COS_Final = COS_Final+COS{i}*weight(i);
    end
    %save(COS_fileName,'COS','COS_Final');
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