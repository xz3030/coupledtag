function show_bar_result
%
coupled_config;
times = 1;

precisions = [];
recalls = [];

expand = 0;


index = [1 2 3 4 8 12 13];
%index = [2];
for cc=index%length(cp.classname)
    cc
    class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cc});
    result_file_path = [class_simpath sprintf('/Run%d/result_%d.mat',times,cp.nnnum) ];
    load(result_file_path);
    pres_cp = pres;
    recs_cp = recs;
    
    result_mat_file = sprintf('%s/%d_mat_tag/%d/result.mat',cp.result_path,cc,times-1);
    load(result_mat_file);
    
    if expand
        y1 = [mean(pres_cp), mean(img_user_pres), mean(tag_user_pres), mean(img_pres), mean(pop_pres), mean(pres)];
        y2 = [mean(recs_cp), mean(img_user_recs), mean(tag_user_recs), mean(img_recs), mean(pop_recs), mean(recs)];
    else
        y1 = [mean(pres_cp), mean(img_pres), mean(pop_pres), mean(pres)];
        y2 = [mean(recs_cp), mean(img_recs), mean(pop_recs), mean(recs)];
    end
    
    
    precisions = [precisions; y1];
    recalls = [recalls; y2];
end

figure, bar(precisions);
if expand
    h = legend('CP','IU','TU','I','T','M');
else
	h = legend('CP','I','T','M');
end
set(h,'Interpreter','none','FontSize',18)
set(gca,'FontSize',18)

figure, bar(recalls);
if expand
    h = legend('CP','IU','TU','I','T','M');
else
	h = legend('CP','I','T','M');
end
set(h,'Interpreter','none','FontSize',18)
set(gca,'FontSize',18)

end

