%function coupled_effect_of_num_nn()
NrangeNN = 50;
p = zeros(5,NrangeNN);
r = zeros(5,NrangeNN);
for nnnum = 1:NrangeNN
    [pres, recs] = coupled_predict_tag(COS, COS_Final, tags, vector_Tag, vector_Tag_all, Nim, cp.classname{cp.classInd}, valid_imgs1, train_or_test, dist_pair, 0, nnnum);
    [img_user_pres, img_user_recs] = coupled_compare_user_image_similarity(Nim, vector_Tag_all, vector_User, tags, feature_all, train_or_test, dist_pair, 0, nnnum);
    [tag_user_pres, tag_user_recs] = coupled_compare_popular_tag_user(Nim, vector_Tag_all, vector_User, vector_Tag, train_or_test, 0, nnnum);
    [pop_pres, pop_recs] = coupled_compare_popular_tag(Nim, vector_Tag, vector_Tag_all, tags, train_or_test, 0, nnnum);
    [img_pres, img_recs] = coupled_compare_image_similarity(Nim, vector_Tag_all, tags, feature_all, train_or_test, 0, nnnum);
    p(:,nnnum) = [mean(pres), mean(img_user_pres), ...
        mean(tag_user_pres), mean(pop_pres), mean(img_pres)];
    r(:,nnnum) = [mean(recs), mean(img_user_recs), ...
        mean(tag_user_recs), mean(pop_recs), mean(img_recs)];
end


figure,plot(1:NrangeNN, p);
figure,plot(1:NrangeNN, r);

%end