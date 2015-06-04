function [pres, recs] = coupled_compare_popular_tag_user_bayesian(Nim, cooccur_user, vector_Tag, vector_Tag_all, vector_User, tags, train_or_test, show, nnnum)
% for comparation, give every image the most popular N tags as result
coupled_config;

if nargin<8
    show = 1;
end
if nargin<9
    nnnum = cp.nnnum;
end

%% predict tags
pres = [];
recs = [];
for i=1:Nim
    if train_or_test(i)==1 % train
        continue;
    end
    tig = vector_Tag{i};
    ti = vector_Tag_all{i};
    if length(ti)<cp.minTagperImg   % too few tags
        continue;
    end
    ui = vector_User(i);
    
    Ntag = length(tags);
    tag_coc = cooccur_user{ui}; 
    tag_freq = diag(tag_coc);
    tag_freq = tag_freq/sum(tag_freq);
    if isempty(tig)
        tag_bayesian = tag_freq;
    else
        tag_bayesian = zeros(Ntag,1);
        for tt = 1:length(tig)
            tag_bayesian = tag_bayesian + tag_freq.*tag_coc(:,tig(tt));
        end
    end
    
    % include cold start or not?
    vt = 1:length(tag_bayesian);
    if cp.evaluate_include_cs==0
        vt = setdiff(vt,vector_Tag{i});
    end
    tag_bayesian = tag_bayesian(vt);
    
    [~,popTags] = sort(tag_bayesian,'descend');
    popTags = popTags(1:cp.nRecTag);
    
    
    acc = length(intersect(ti,vt(popTags)));
    pres = [pres  acc/cp.nRecTag];
    recs = [recs  acc/(length(ti)+eps)];
end

if (show), fprintf('Tag + User: precision: %f, recall: %f\n', mean(pres), mean(recs)); end

end