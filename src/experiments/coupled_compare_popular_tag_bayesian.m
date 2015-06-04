function [pres, recs] = coupled_compare_popular_tag_bayesian(Nim, vector_Tag, vector_Tag_all, tag_coc, tag_freq, train_or_test, show, nnnum)
% for comparation, give every image the most popular N tags as result
coupled_config;

if nargin<7
    show = 1;
end
if nargin<8
    nnnum = cp.nnnum;
end

Ntag = length(tag_freq);
%% predict tags
pres = [];
recs = [];
for i=1:Nim
    if train_or_test(i)==1 % train
        continue;
    end
    tig = vector_Tag{i};  % ti given
    ti = vector_Tag_all{i};
    if length(ti)<cp.minTagperImg   % too few tags
        continue;
    end
    
    if isempty(tig)
        tag_bayesian = tag_freq;
    else
        tag_bayesian = zeros(Ntag,1);
        for tt = 1:length(tig)
            tag_bayesian = tag_bayesian + tag_freq.*tag_coc(:,tig(tt));
        end
    end
    
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

if (show), fprintf('Popular Tag: precision: %f, recall: %f\n\n\n', mean(pres), mean(recs)); end

end