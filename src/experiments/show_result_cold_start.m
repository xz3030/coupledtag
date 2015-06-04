function show_result_cold_start()
%
coupled_config;
expand=1;

index = [1 2 3 4 8 12 13];
%index = [1];
for cc = index
    close all;
    if expand
        p = zeros(6,5);
        r = zeros(6,5);
    else
        p = zeros(4, 5);
        r = zeros(4, 5);
    end
    class_simpath = sprintf('%s/%s', cp.sim_file_path, cp.classname{cc});
    result_all_path = sprintf('%s/%d_CP',cp.result_path,cc);
    
    
    for Niter=1:5
        result_file_path = [class_simpath sprintf('/Run%d/result_%d.mat',Niter,cp.nnnum) ];
        load(result_file_path);
        pres_cp = pres;
        recs_cp = recs;
        mat_result_path = sprintf('%s/%d_mat_tag/%d/result.mat',cp.result_path,cc,Niter-1);
        load(mat_result_path);
        
        if expand
            p(:,Niter) = [mean(pres_cp), mean(img_user_pres), ...
                mean(tag_user_pres), mean(img_pres), mean(pop_pres), mean(pres)];
            r(:,Niter) = [mean(recs_cp), mean(img_user_recs), ...
                mean(tag_user_recs), mean(img_recs), mean(pop_recs), mean(recs)];
        else
            p(:,Niter) = [mean(pres_cp), mean(img_pres), mean(pop_pres), mean(pres)];
            r(:,Niter) = [mean(recs_cp), mean(img_recs), mean(pop_recs), mean(recs)];
        end
    end
    
    if expand
        figure,
        pp=plot(1:5, p(1,:),'^-', 1:5, p(2,:),'o-', 1:5, p(3,:),'-s', 1:5, p(4,:),'*-', 1:5, p(5,:),'.-', 1:5, p(6,:),'--');
        set(pp,'LineWidth',3,'MarkerSize',15);
        h = legend('CP','IU','TU','I','T','M');
        set(h,'Interpreter','none')
        set(gca,'FontSize',14)
        print(gcf,'-djpeg',fullfile(result_all_path,'precision'))
        figure,pp=plot(1:5, r(1,:),'^-', 1:5, r(2,:),'o-', 1:5, r(3,:),'-s', 1:5, r(4,:),'*-', 1:5, r(5,:),'.-', 1:5, r(6,:),'--');
        set(pp,'LineWidth',3,'MarkerSize',15);
        h = legend('CP','IU','TU','I','T','M');
        set(h,'Interpreter','none')
        set(gca,'FontSize',14)
        print(gcf,'-djpeg',fullfile(result_all_path,'recall'))
    else
        pp = plot(1:5, p(1,:),'^-', 1:5, p(2,:),'o-', 1:5, p(3,:),'-s', 1:5, p(4,:),'*-');
        set(pp,'LineWidth',3,'MarkerSize',15)
        h = legend('CP','I','T','M');
        set(h,'Interpreter','none','FontSize',14)
        set(gca,'FontSize',14)
        print(gcf,'-depsc',fullfile(result_all_path,'precision'))
        figure
        pp = plot(1:5, r(1,:),'^-', 1:5, r(2,:),'o-', 1:5, r(3,:),'-s', 1:5, r(4,:),'*-');
        set(pp,'LineWidth',3,'MarkerSize',15)
        h = legend('CP','I','T','M');
        set(h,'Interpreter','none','FontSize',14)
        set(gca,'FontSize',14)
        print(gcf,'-depsc',fullfile(result_all_path,'recall'))
    end
    pause
end
end