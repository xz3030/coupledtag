function analysis_image_similarity(id1, id2, imageList, Ia, Idf, Ie, ...
    CAVS, COS, COS_Final, tags, vector_Tag, vector_User)

coupled_config;

t1=imageList{id1}.tag;
t2=imageList{id2}.tag;
u1=imageList{id1}.username;
u2=imageList{id2}.username;
fprintf('\nImage 1: user->%s. Tags:\n',u1);
for i=1:length(t1)
    fprintf('%s\t',t1{i}.tag);
end
fprintf('\nImage 2: user->%s. Tags:\n',u2);
for i=1:length(t2)
    fprintf('%s\t',t2{i}.tag);
end
fprintf('\n');

subplot(1,2,1),imshow(imread(fullfile(cp.img_main_dir, cp.classname{cp.classInd}, [imageList{id1}.id '.jpg'])));
subplot(1,2,2),imshow(imread(fullfile(cp.img_main_dir, cp.classname{cp.classInd}, [imageList{id2}.id '.jpg'])));


similarity = COS_Final(id1,id2);

feature_names = {'tag','user','cms','colorhist','LBP','SIFT_BOW'};

% tag
disp('Tag similarity');
fprintf('Tag: %.4f\n', COS{1}(id1,id2));
ti = vector_Tag{id1};
tj = vector_Tag{id2};
simsub = CAVS{1}(ti,tj);
lti = length(ti);
ltj = length(tj);
tempsim = 0;

while lti~=0 && ltj~=0 && sum(simsub(:))~=0
    [sim,ind]=max(simsub(:));
    [x,y]=ind2sub(size(simsub),ind);
    fprintf('Match: %s to %s, Sim: %f, abst: %.4f\n',tags{ti(x)},...
        tags{tj(y)},sim,min(Idf{1}(ti(x)),Idf{1}(tj(y))));
    fprintf('\tIa: %.4f\n', Ia{1}(ti(x), tj(y)));
    for j=2:length(COS)
        fprintf('\tIe_%s: %.4f\n', feature_names{j}, Ie{1,j}(ti(x), tj(y)));
    end
    
    tempsim = tempsim+sim*min(Idf{1}(ti(x)),Idf{1}(tj(y)));
    simsub(x,:)=0;
    simsub(:,y)=0;
    lti=lti-1;
    ltj=ltj-1;
end
simr = 2/(1+exp(-tempsim))-1;

for i=2:2%length(COS)
    fprintf('\n%s:%.4f\n', feature_names{i},COS{i}(id1,id2));
    for j=1:length(COS)
        if (j==i)
            fprintf('\tIa: %.4f\n', Ia{j}(vector_User(id1), vector_User(id2)));
        else
            fprintf('\tIe_%s: %.4f\n', feature_names{j}, Ie{i,j}(vector_User(id1), vector_User(id2)));
        end
    end
end

fprintf('\nImage similarity\n');
for dd = 3:length(COS)
    fprintf('%s: %.4f\n',cp.feature_names{dd-2},COS{dd}(id1,id2));
    %fprintf('          Should be %.4f in histogram intersection kernel\n', dhisect{dd-2}(id1,id2));
end

fprintf('\nTotal similarity: %.4f\n', COS_Final(id1,id2));

end