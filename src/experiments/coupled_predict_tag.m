function [pres, recs] = coupled_predict_tag(COS, COS_Final, tags, vector_Tag, vector_Tag_all, Nim, classname, valid_imgs1, train_or_test, dist_pair, show, nnnum)
% config
coupled_config;

if nargin<12
    nnnum = cp.nnnum;
end
%% find nearest neighbour
R=randperm(Nim);
signi = {'Wrong','Right'};
pres = [];
recs = [];
ind = find(train_or_test);

for ii=1:Nim
    if (show), i=R(ii);  else i=ii;  end
    
    if train_or_test(i)==1 % train
        continue;
    end
    ind_im = find(dist_pair(i,:)<cp.maxSimImage);
    ind = intersect(ind,ind_im);
    
    ti = vector_Tag_all{i};
    if length(ti)<cp.minTagperImg   % too few tags
        continue;
    end
    
    if show
        fprintf('%d: Original tags:\n',i);
        for pp=ti
            fprintf('%s\t',tags{pp});
        end
        fprintf('\nGiven tags:\n');
        for pp=vector_Tag{i}
            fprintf('%s\t',tags{pp});
        end
        fprintf('\n');
        subplot(1,2,1),imshow(imread(fullfile(cp.img_main_dir, classname, valid_imgs1{i})));
    end
    
    tag_voting = zeros(1,length(tags));
    similarity = COS_Final(i,ind);
    
    [xx,yy]=sort(similarity,'descend');
    if (show), fprintf('Similar Image Tags:\n'); end
    for j=1:nnnum
        tj=vector_Tag{ind(yy(j))};
        for pp=tj
            tag_voting(pp) = tag_voting(pp)+xx(j);
        end
        if (show)
            fprintf('%d: ',ind(yy(j)));
            for dd = 1:length(COS)
                fprintf('%f  ',COS{dd}(i,ind(yy(j))));
            end
            %fprintf('%f   ',COS_Final(i,ind(yy(j))));
            for pp=tj
                fprintf('%s\t',tags{pp});
            end
            fprintf('\n');
            subplot(1,2,2),imshow(imread(fullfile(cp.img_main_dir, classname, valid_imgs1{ind(yy(j))})))
            pause;
        end
            
    end
    
    
    vt = 1:length(tag_voting);
    if cp.evaluate_include_cs==0
        vt = setdiff(vt,vector_Tag{i});
    end
    tag_voting = tag_voting(vt);
    [xx,yy]=sort(tag_voting,'descend');
    acc = 0;
    yy = yy(xx>0);
    for j=1:min(cp.nRecTag,length(yy))
        isin = length(find(ti==vt(yy(j))));
        acc = acc+isin;
        if (show), fprintf('%s\t%f\t%s\n',tags{vt(yy(j))},xx(j),signi{isin+1}); end
    end
    
    
    pres = [pres  acc/cp.nRecTag];
    recs = [recs  acc/(length(ti)+eps)];
    if (show), pause; end
end

fprintf('\n\n\nCoupled behavior: precision: %f, recall: %f\n', mean(pres), mean(recs));

end