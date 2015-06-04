function [pres, recs] = coupled_compare_image_similarity(Nim, vector_Tag, tags, feature_all, train_or_test, show, nnnum)
% for comparation, give every image the most popular N tags as result
coupled_config;

if nargin<6
    show = 1;
end
if nargin<7
    nnnum = cp.nnnum;
end


%%
feature = [];
for f=1:length(feature_all)
    feature = [feature feature_all{f}];
end
dist_pair = tool_dist2(feature, feature, 'ang');
ind = find(train_or_test);

%% predict tags
pres = [];
recs = [];
for i=1:Nim
    if train_or_test(i)==1 % train
        continue;
    end
    
    ind_im = find(dist_pair(i,:)<cp.maxSimImage);
    ind = intersect(ind,ind_im);
    
    
    ti = vector_Tag{i};
    if length(ti)<cp.minTagperImg   % too few tags
        continue;
    end
    
    tag_voting = zeros(1,length(tags));
    similarity = dist_pair(i,ind);
    
    [xx,yy]=sort(similarity,'descend');
    for j=1:nnnum
        tj=vector_Tag{ind(yy(j))};
        for pp=tj
            tag_voting(pp) = tag_voting(pp)+xx(j);
        end
    end
    
    [xx,yy]=sort(tag_voting,'descend');
    acc = 0;    
    yy = yy(xx>0);
    for j=1:min(cp.nRecTag,length(yy))
        isin = length(find(ti==yy(j)));
        acc = acc+isin;
    end
    
    
    pres = [pres  acc/cp.nRecTag];
    recs = [recs  acc/(length(ti)+eps)];
end

if (show), fprintf('Image Similarity: precision: %f, recall: %f\n', mean(pres), mean(recs)); end


end