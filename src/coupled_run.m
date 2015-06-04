function coupled_run(MODE)
% run coupled object interaction
% classInd: class index 
% MODE: "cluster": clustering
%       "annotation": tag predicting
% main entrance of the algorithm

if nargin<1
    MODE = 'cluster';
end

warning off

init;
coupled_config;

%cp.classInd=6;

cp.classname{cp.classInd}
if ~strcmp(cp.mode,'')
    return;
end


%% load features
disp('*********************************************************')
disp('Start Loading features')
tic
outFName = sprintf(cp.feature_path, cp.classname{cp.classInd});
if exist(outFName,'file')% && canSkip && 0
    load(outFName);
    coupled_config;
else
    [feature_all, index, valid_imgs] = load_features_v2(cp.classInd);

    [W,N,Np,userIdList,users,tags,times,valid_index,imageList] = loadInfos(cp.classInd, valid_imgs);
    valid_imgs1 = valid_imgs(valid_index);
    
    [userList, contactMap] = loadUsers(cp.classInd, users, cp.friend_coefficient);

    for i=1:length(feature_all)
        feature_all{i} = feature_all{i}(valid_index,:);
    end
    
    tic
    feature_bow = cell(1,length(feature_all));
    for i=1:length(feature_all)
        coupled_build_dictionary(feature_all{i}, cp.feature_names{i}, cp.classname{cp.classInd});
        feature_bow{i} = coupled_build_bow(feature_all{i}, cp.feature_names{i}, cp.classname{cp.classInd});
    end
    fprintf('Running bag-of-words using %.4f s\n',toc);

    save(outFName);
end

fprintf('Loading features using %.4f s\n',toc);

%{
tic
feature_bow = cell(1,length(feature_all));
for i=1:length(feature_all)
    coupled_build_dictionary(feature_all{i}, cp.feature_names{i}, cp.classname{cp.classInd});
    feature_bow{i} = coupled_build_bow(feature_all{i}, cp.feature_names{i}, cp.classname{cp.classInd});
end
fprintf('Running bag-of-words using %.4f s\n',toc);

%****************************************%
%****************************************%
%****************************************%
[userList, contactMap] = loadUsers(cp.classInd, users, cp.friend_coefficient);
save(outFName);
keyboard;
%****************************************%
%****************************************%
%****************************************%
%}


%% coupled stats
coupled_config;
Wtag = W{2};
Otags = tags;
Nim = length(imageList);


%****************************%
%****************************%
%****************************%
%****************************%
    
    
%% start main work
% Niter: number of cold start, 1-5: cold start number (remaining tags) 0-4
% if only want to do clustering,
% set cp.Ntimes = 6 in coupled_config.m
% and let Niter = 6:cp.Ntimes
disp('*********************************************************')
disp('Start running main function')

if strcmp(MODE, 'cluster')
    st = 6;
    ed = 6;
elseif strcmp(MODE, 'annotation')
    st = 1;
    ed = 5;
end

for Niter = st:ed
    %% preparation work
    % calculate ecllipse time
    t1=cputime;
    %%

    % number of cold start
    cp.cs_start_num = Niter-1;

    if Niter==6   % all train/ cluster
        cp.trainRate=1;
        disp('')
        disp('---------------Clustering job!----------------')
        disp('')
    else
        fprintf('\n------------Tag recommendation job, cold start level %d------------\n\n', Niter-1);
    end


    %% classify training set and testing set
    class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cp.classInd});
    mkdir(class_simpath);
    class_runpath = [class_simpath  sprintf('/Run%d',Niter)];
    mkdir(class_runpath);
    train_or_test_file_path = [class_runpath '/train_or_test.mat'];
    if exist(train_or_test_file_path,'file')~=0 && canSkip
        load(train_or_test_file_path);
        disp('Load train/test indices');
    else
        R = 1:Nim;
        %R = randperm(Nim);
        Ntrain = floor(Nim*cp.trainRate);
        train_or_test = zeros(1,Nim);
        train_or_test(R(1:Ntrain))=1;
        save(train_or_test_file_path, 'train_or_test');
    end
    if Niter==6, train_or_test = ones(size(train_or_test)); end
    
    %% discard rare appeared tag and group tags
    freq_tag = sum(W{2}(find(train_or_test),:),1);
    valid_index_tag = find(freq_tag>=cp.minTagFreq/3000*max(Nim,3000));
    valid_index_tag2 = find(freq_tag<Nim*0.2);
    valid_index_tag = intersect(valid_index_tag, valid_index_tag2);
    tags = tags(valid_index_tag);
    Wtag_valid = Wtag(:,valid_index_tag);
    
    %% using wordnet to filter syns and calculate wordnet distance 
    if Niter==6 && cp.plus
        if ~exist(sprintf('%s/wordnet.txt',class_runpath)) && canSkip
            disp('Writing tags into file')
            % write tags into file for using python script
            f = fopen(sprintf('%s/tags.txt',class_runpath), 'wt');
            for tt=1:length(tags)
                fprintf(f, '%s\n', tags{tt});
            end
            fclose(f);

            % call python wordnet and waiting to exit
            tic
            disp('Call python script to run wordnet');
            cmd = sprintf('python ./utils/tag_similarity_wordnet.py %s', [class_runpath '/']);
            fprintf('executing: %s\n', cmd);

            status = unix(cmd);
            if status ~= 0
                fprintf('command `%s` failed\n', cmd);
                keyboard;
            end

            % finish python script, return to matlab and analyze results
            fprintf('Wordnet analysis finished in %.4f s\n',toc);
        end
        
        tic,
        [simTag, Wtag_valid, tags, valid_index_tag] = tool_load_wordnet_sim( Wtag_valid, tags, valid_index_tag );
        save(fullfile(class_runpath, 'Ia_wordnet.mat'), 'simTag');
        save(fullfile(class_runpath, 'Ia_usercontact.mat'), 'contactMap');
        fprintf('Finish Loading wordnet in %.4f s\n',toc);
    end
    
    % assign remaining tags to W.
    W{2} = Wtag_valid;
    N{2} = size(W{2},2);
    
    
    %% user frequency stats
    Nim = length(imageList);
    Nuser = N{1};
    Ntag = N{2};

    tag_freq_user = cell(1,Nuser);
    valid_tag_user = cell(1,Nuser);
    cooccur_user = cell(1,Nuser);
    train_ind = find(train_or_test);

    % first row: # of image, second row: # of tag
    stat_user = zeros(3,Nuser);  

    for u=1:Nuser
        ind = find(W{1}(:,u)~=0);
        tag_freq = zeros(1,Ntag);
        for i = 1:length(ind)
            if train_or_test(ind(i))==0 % test
                continue;
            end
            ti = find(W{2}(ind(i),:));
            tag_freq(ti) = tag_freq(ti)+1;
        end
        Hu = W{2}(intersect(ind,train_ind),:);
        tag_freq = sum(Hu);
        vind = find(tag_freq);
        %Hu = Hu(:,vind);
        Gu = Hu'*Hu;
        cooccur_user{u} = Gu;

        stat_user(1,u) = length(ind);  % # of images tagged by u
        [popFreq,popTags] = sort(tag_freq,'descend');
        popFreq = popFreq/length(ind);
        popTags1 = popTags(popFreq<0.3 & popFreq>0);
        valid_tag_user{u} = popTags1;
        stat_user(2,u) = length(popTags1);
        stat_user(3,u) = length(find(popFreq));
        %fprintf('%d/%d\n',length(popTags1),length(find(tag_freq>0)))
        if length(popTags1)>cp.nnnum
            popTags1 = popTags1(1:cp.nnnum);
        end
        tag_freq_user{u} = popTags1;
    end

    N_valid_user = length(find(cellfun(@(x) ~isempty(find(x, 1)), tag_freq_user)));
    
    %% convert raw data into format that can be handled by COS
    vector_Tag = cell(1,Nim);
    vector_Tag_all = cell(1,Nim);
    vector_User = zeros(1,Nim);
    for ind=1:Nim
        tagIndex = find(W{2}(ind,:));
        % random pick several tags as init
        %Rt=randperm(length(tagIndex));
        % ordered pick several tags as init
        Rt=1:length(tagIndex);
        if train_or_test(ind) == 1   % train
            tt = tagIndex;
        else
            tt = tagIndex(Rt(1:min(cp.cs_start_num,length(tagIndex))));
            if cp.evaluate_include_cs==0 % not include init
                tagIndex = tagIndex(Rt(min(cp.cs_start_num,length(tagIndex))+1:end));
            end
        end
        vector_Tag_all{ind} = tagIndex;
        vector_Tag{ind}=tt;
        vector_User(ind)=find(W{1}(ind,:));
    end
    
    %% assign testing tags to zeros
    Wtag1 = Wtag_valid;
    Wtag1(~train_or_test,:)=0;
    %% tag frequency stats
    tag_coc = Wtag1'*Wtag1;
    tag_freq = diag(tag_coc);
    tag_coc = tag_coc./repmat(tag_freq,1,length(tags));
    tag_freq = tag_freq/sum(tag_freq);
    
    
    
    %% final preparation
    vectors = {vector_Tag, vector_User};
    Ns = {Ntag, Nuser};
    types = {'tag','user'};

    for i=1:length(feature_bow)
        vectors = [vectors feature_bow{i}];
        Ns = [Ns max(feature_bow{i}(:))];
        types = [types cp.feature_names{i}];
    end

    %% start cos
    class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cp.classInd});
    
    if cp.plus
        contextflag = 'context_';
    else
        contextflag = '';
    end
    
    Ia_fileName = sprintf('%s/Run%d/%sIa.mat', class_simpath, Niter, contextflag);
    Ie_fileName = sprintf('%s/Run%d/%sIe.mat', class_simpath, Niter, contextflag);
    CAVS_fileName = sprintf('%s/Run%d/%sCAVS.mat', class_simpath, Niter, contextflag);
    COS_fileName = sprintf('%s/Run%d/%sCOS.mat', class_simpath, Niter, contextflag);
    
    if exist(COS_fileName,'file') && canSkip
        load(COS_fileName);
    else
        if cp.plus
            [COS, COS_Final, Ia, Idf, types, Ie, CAVS] = coupled_main(vectors, Ns, types, 1, 1);
        else
            [COS, COS_Final, Ia, Idf, types, Ie, CAVS] = coupled_main(vectors, Ns, types, 0, 1);
        end

        save(Ia_fileName,'Ia','Idf','types');
        save(Ie_fileName,'Ie');
        save(CAVS_fileName,'CAVS');
        save(COS_fileName,'COS','COS_Final');
    end
    
    %coupled_show(COS, COS_Final, tags, vector_Tag, Nim, cp.classname{cp.classInd}, valid_imgs1);
    
    %{
    %**************************%
    COS_Final = zeros(Nim);
    %weight = ones(1,Ndim)/Ndim;
    weight = cp.feature_weight;
    for i=1:length(COS)
        COS_Final = COS_Final+COS{i}*weight(i);
    end
    %*****************************%
    %}
    
    %% image feature similarity matrix
    ff = [];
    for f=1:length(feature_all)
        ff = [ff feature_all{f}];
    end
    dist_pair = tool_dist2(ff, ff, 'ang');
    
    if Niter < 6
        %% result calculation
        %[pres, recs] = coupled_predict_tag(COS, COS_Final, tags, vector_Tag, vector_Tag_all, Nim, cp.classname{cp.classInd}, valid_imgs1, train_or_test, dist_pair, 1);
        [pres, recs] = coupled_predict_tag(COS, COS_Final, tags, vector_Tag, vector_Tag_all, Nim, cp.classname{cp.classInd}, valid_imgs1, train_or_test, dist_pair, 0);
        [img_user_pres, img_user_recs] = coupled_compare_user_image_similarity(Nim, vector_Tag_all, vector_User, tags, feature_all, train_or_test, dist_pair);
        [tag_user_pres, tag_user_recs] = coupled_compare_popular_tag_user_bayesian(Nim, cooccur_user, vector_Tag, vector_Tag_all, vector_User, tags, train_or_test);
        [img_pres, img_recs] = coupled_compare_image_similarity(Nim, vector_Tag_all, tags, feature_all, train_or_test);
        [pop_pres, pop_recs] = coupled_compare_popular_tag_bayesian(Nim, vector_Tag, vector_Tag_all, tag_coc, tag_freq, train_or_test);
        %[tag_user_pres, tag_user_recs] = coupled_compare_popular_tag_user(Nim, vector_Tag_all, vector_User, vector_Tag, train_or_test);
        %[pop_pres, pop_recs] = coupled_compare_popular_tag(Nim, vector_Tag, vector_Tag_all, tags, train_or_test);

        %% save results
        result_file_path = [class_simpath sprintf('/Run%d/result_%d.mat',Niter,cp.nnnum) ];
        save(result_file_path, 'pres', 'recs', 'img_user_pres', 'img_user_recs', 'tag_user_pres', 'tag_user_recs','pop_pres', 'pop_recs', 'img_pres', 'img_recs');
        
    end
    
    e=cputime-t1;
    
    result_all_path = sprintf('%s/%d_CP',cp.result_path,cp.classInd);
    mkdir(result_all_path);
    if (Niter==6) 
        % Kmodes clustering
        coupled_CKModes(COS_Final,W,users,tags,Niter,valid_imgs1, cp.classname{cp.classInd}, result_all_path, e);
    else
        W{2} = Wtag;
        tags = Otags;
    end
end


end