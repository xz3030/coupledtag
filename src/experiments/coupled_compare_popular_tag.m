function [pres, recs] = coupled_compare_popular_tag(Nim, vector_Tag, vector_Tag_all, tags, train_or_test, show, nnnum)
% for comparation, give every image the most popular N tags as result
coupled_config;

if nargin<6
    show = 1;
end
if nargin<7
    nnnum = cp.nnnum;
end

%% frequency stats
tag_freq = zeros(1,length(tags));
for i=1:Nim
    if train_or_test(i)==0 % test
        continue;
    end
    ti = vector_Tag_all{i};
    tag_freq(ti) = tag_freq(ti)+1;
end
[~,popTags] = sort(tag_freq,'descend');
popTags = popTags(1:cp.nRecTag);


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
    
    acc = length(intersect(ti,popTags));
    pres = [pres  acc/cp.nRecTag];
    recs = [recs  acc/(length(ti)+eps)];
end

if (show), fprintf('Popular Tag: precision: %f, recall: %f\n\n\n', mean(pres), mean(recs)); end

end