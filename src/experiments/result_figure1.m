function [Overall, Total_account, Inclass_account] = result_figure1(W,result,users,tags,times,result_all_path)
close all
items={users,tags,times};
itemNames={'user','tag'};
tag_result_file = fullfile(result_all_path,'tag');
tag_result_file2 = fullfile(result_all_path,'tag_with_count');
user_result_file = fullfile(result_all_path,'user_with_count');
fd = fopen(tag_result_file,'wt');
fdt = fopen(tag_result_file2,'wt');
fdu = fopen(user_result_file,'wt');
fds = [fdu,fdt];
for i=1:2%length(Z)
    %{=
    %% stats
    fd2=fds(i);
    temp_item = items{i};
    tempW = W{i};
    accumulator = zeros(max(result),size(tempW,2));
    for c = 1:max(result)
        ind = find(result==c);
        for j=ind
            t = find(tempW(j,:));
            for tt=t
                accumulator(c,tt)=accumulator(c,tt)+1;
            end
        end
    end
    %{
    tempInd = sum(accumulator)>10;
    accumulator = accumulator(:,tempInd);
    temp_item = temp_item(tempInd);
    %}
    [numC, maxC] = max(accumulator);
    
    Noverall=50;
    Overall = cell(1,Noverall);
    fprintf('\nOverall:\n');
    fprintf(fd,'\nOverall:\n');
    a=sum(accumulator);
    [xx,yy]=sort(a,'descend');
    for y=1:Noverall
        Overall{y}.name = temp_item{yy(y)};
        Overall{y}.count = xx(y);
        fprintf('%s\n',temp_item{yy(y)});
        fprintf(fd,'%s\n',temp_item{yy(y)});
    end
    
    Total_account = cell(max(result), 10);
    fprintf('\nTotal account of %ss\n',itemNames{i});
    fprintf(fd,'\nTotal account of %ss\n',itemNames{i});
    
    for c=1:max(result)
        fprintf(fd2,'\nClass %d:\n',c);
        [xx,ord] = sort(accumulator(c,:),'descend');
        fprintf('Class:%d\n',c)
        for o=1:10
            Total_account{c,o}.name = temp_item{ord(o)};
            Total_account{c,o}.count = xx(o);
            fprintf('%s\n',temp_item{ord(o)});
            fprintf(fd,'%s\n',temp_item{ord(o)});
        end
        for o=1:length(ord)
            if xx(o)<20
                continue
            end
            Total_account{c,o} = temp_item{ord(o)};
            fprintf(fd2,'%s\t%d\n',temp_item{ord(o)},xx(o));
        end
    end
        
    %}
    %% reorder
    Inclass_account = cell(max(result), 10);
    reorder = zeros(1,size(tempW,2));
    index=1;
    for c=1:max(result)
        fprintf('\nClass %d:\n',c);
        fprintf(fd,'\nClass %d:\n',c);
        %fprintf(fd2,'\nClass %d:\n',c);
        ind = find(maxC==c);
        numt = numC(ind);
        [xx,ord] = sort(numt,'descend');
        reorder(index:index+length(ind)-1)=ind(ord);
        tmp = ind(ord);
        for jj=1:min(10,length(ord))
            Inclass_account{c,jj}.name = temp_item{tmp(jj)};
            Inclass_account{c,jj}.count = xx(jj);
            fprintf('%s\t%d\n',temp_item{tmp(jj)},xx(jj));
            fprintf(fd,'%s\n',temp_item{tmp(jj)});
        end
        %{
        for jj=1:length(ord)
            Inclass_account{c,jj} = temp_item{tmp(jj)};
            fprintf(fd2,'%s\t%d\n',temp_item{tmp(jj)},xx(jj));
        end
        %}
        index = index+length(ind);
    end
    %order back
    order = zeros(size(reorder));
    for r=1:length(reorder)
        order(reorder(r))=r;
    end
    fprintf(fd,'\n\n\n');
        
    %% project
    x=[];
    y=[];
    tempInd=1;
    for c = 1:max(result)
        ind = find(result==c);
        for j=ind
            t = find(tempW(j,:));
            x = [x tempInd*ones(size(t))];
            y = [y order(t)];
            tempInd = tempInd+1;
        end
        tempInd
    end
    figure,
    scatter(x,y,'b.');
    outFName = sprintf('%s/%s.jpg',result_all_path,itemNames{i});
    print(gcf,'-djpeg',outFName)
    %pause;
end
fclose(fd);
fclose(fdt);
fclose(fdu);

end