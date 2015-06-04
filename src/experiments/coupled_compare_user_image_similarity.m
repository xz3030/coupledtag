function [pres, recs] = coupled_compare_user_image_similarity(Nim, vector_Tag, vector_User, tags, feature_all, train_or_test, dist_pair, show, nnnum)
% for comparation, give every image the most popular N tags as result
coupled_config;

if nargin<8
    show = 1;
end
if nargin<9
    nnnum = cp.nnnum;
end

ind = find(train_or_test);

%% predict tags
pres = [];
recs = [];
for i=1:Nim
    if train_or_test(i)==1 % train
        continue;
    end
    
    ti = vector_Tag{i};
    ui = vector_User(i);
    ind = vector_User==ui;
    ind = ind.*train_or_test;
    ind_find = find(ind);
    
    ind_im = find(dist_pair(i,:)<cp.maxSimImage);
    ind_find = intersect(ind_find,ind_im);
    
    if length(ti)<cp.minTagperImg   % too few tags
        continue;
    end
    
    tag_voting = zeros(1,length(tags));
    similarity = dist_pair(i,ind_find);
    
    [xx,yy]=sort(similarity,'descend');
    for j=1:min(nnnum,length(yy))
        tj=vector_Tag{ind_find(yy(j))};
        for pp=tj
            tag_voting(pp) = tag_voting(pp)+xx(j);
        end
    end
    
    [xx,yy]=sort(tag_voting,'descend');
    yy = yy(xx>0);
    acc = 0;
    for j=1:min(cp.nRecTag,length(yy))
        isin = length(find(ti==yy(j)));
        acc = acc+isin;
    end
    
    
    pres = [pres  acc/cp.nRecTag];
    recs = [recs  acc/(length(ti)+eps)];
end

if (show), fprintf('Image + User: precision: %f, recall: %f\n', mean(pres), mean(recs)); end


end