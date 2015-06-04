function [pres, recs] = coupled_compare_popular_tag_user(Nim, vector_Tag_all, vector_User, vector_Tag, train_or_test, show, nnnum)
% for comparation, give every image the most popular N tags as result
coupled_config;

if nargin<6
    show = 1;
end
if nargin<7
    nnnum = cp.nnnum;
end


%% frequency stats
Nuser = length(vector_User);
Ntag = length(vector_Tag);
tag_freq_user = cell(1, Nuser);
for u=1:Nuser
    ind = find(vector_User==u);
    tag_freq = zeros(1,Ntag);
    for i = 1:length(ind)
        if train_or_test(ind(i))==0 % test
            %ti = vector_Tag{ind(i)};
            ti = [];
        else
            ti = vector_Tag_all{ind(i)};
        end
        
        tag_freq(ti) = tag_freq(ti)+1;
    end
    Nvalidtag = length(find(tag_freq>0));
    [~,popTags] = sort(tag_freq,'descend');
    popTags = popTags(1:Nvalidtag);
    if length(popTags)>cp.nRecTag
        popTags = popTags(1:cp.nRecTag);
    end
    tag_freq_user{u} = popTags;
end

%% predict tags
pres = [];
recs = [];
for i=1:Nim
    if train_or_test(i)==1 % train
        continue;
    end
    ti = vector_Tag_all{i};
    if length(ti)<cp.minTagperImg   % too few tags
        continue;
    end
    ui = vector_User(i);
    popTags = tag_freq_user{ui};
    
    
    acc = length(intersect(ti,popTags));
    pres = [pres  acc/cp.nRecTag];
    recs = [recs  acc/(length(ti)+eps)];
end

if (show), fprintf('Tag + User: precision: %f, recall: %f\n', mean(pres), mean(recs)); end

end