function [COS, COS_Final] = coupled_main_context(classInd, vectors, Ns, types, times, version)
% main function of coupled item interaction similarity measure
% using contextual information to calculate intra similarity
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


%canSkip=0;


% IaAVS
Ia_fileName = sprintf('%s/Run%d/context_%sIa.mat', class_simpath, times, version);
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
        [Ia{i}, Idf{i}] = coupled_IaAVS_context( vectori, Ni, typei );
        fprintf('End IaAVS %d/%d in %.5f seconds\n',i,Ndim,toc);
    end
    save(Ia_fileName,'Ia','Idf','types');
end

%canSkip=1;

% IeAVS
disp('Start IeAVS');
Ie_fileName = sprintf('%s/Run%d/context_%sIe.mat', class_simpath, times, version);
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

    save(Ie_fileName,'Ie');
end

%canSkip=0;
% Ia
disp('Start Ia');
CAVS_fileName = sprintf('%s/Run%d/context_%sCAVS.mat', class_simpath, times, version);
if exist(CAVS_fileName,'file') && canSkip
    load(CAVS_fileName);
else
    CAVS = cell(1,Ndim);
    for i=1:Ndim
        tic;
        tempweight = cp.feature_weight;
        if strcmp(version,'ori')
            tempweight = [ones(Ndim-5,1)/(Ndim-5)/4; ones(5,1)/5/4*3];
        end
        tempweight(i)=0;
        Ietemp = zeros(Ns{i});
        for j=1:Ndim
            tic;
            if j~=i
                Ietemp=Ietemp+Ie{i,j}*tempweight(j);
            end
        end
        Ietemp = Ietemp/sum(tempweight);
        
        % contextual: different weighes
        if i==1 % tag
            CAVS{i} = Ia{i}*0.2+Ietemp*0.8;
        elseif i==2 % user
            CAVS{i} = Ia{i}*0.5+Ietemp*0.5;
        else % image
            CAVS{i} = Ia{i}*0.8+Ietemp*0.2;
        end
        %CAVS{i} = (CAVS{i}+Ietemp)/2;
        %CAVS{i} = CAVS{i}.*Ietemp;
        fprintf('End Ia %d/%d in %.5f seconds\n',i,Ndim,toc);
    end

    save(CAVS_fileName,'CAVS');
end

% COS
disp('Start COS');
COS_fileName = sprintf('%s/Run%d/context_%sCOS.mat', class_simpath, times, version);
if exist(COS_fileName,'file') && canSkip% && 0
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
    if strcmp(version,'ori')
        weight = [ones(Ndim-5,1)/(Ndim-5)/4; ones(5,1)/5/4*3];
    end
    for i=1:Ndim
        COS_Final = COS_Final+COS{i}*weight(i);
    end
    save(COS_fileName,'COS','COS_Final');
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