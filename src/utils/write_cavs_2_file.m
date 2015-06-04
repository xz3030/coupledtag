%function write_cavs_2_file()
classname = cp.classname{cp.classInd};
class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);
version='';
CAVS_fileName = sprintf('%s/Run%d/%sCAVS.mat', class_simpath, Niter, version);
load(CAVS_fileName);

Ntag_filter = 200;
Ntag = size(CAVS{1},1);
[xx,ord]=sort(tag_freq,'descend');
ord1 = ord(1:Ntag_filter);
cavsTag = CAVS{1}.*(tril(ones(Ntag))-eye(Ntag));
cavsTag = cavsTag(ord1, ord1);


result_all_path = sprintf('%s/%d_CP',cp.result_path,cp.classInd);
outFName = fullfile(result_all_path, 'tag_cavs.txt');
freqFName = fullfile(result_all_path, 'tag_freq.txt');
fd = fopen(freqFName,'wt');
fprintf(fd,'tag\tfreq\n');
for t=1:Ntag_filter
    fprintf(fd, '%s\t%d\n', tags{ord(t)}, xx(t));
end
fclose(fd);


fd = fopen(outFName,'wt');
tmp = find(cavsTag>0.1);

fprintf(fd,'*Tie data\nfrom\tto\tstrength\n');
for t = 1:length(tmp)
    [t1,t2]=ind2sub([Ntag_filter,Ntag_filter], tmp(t));
    fprintf(fd,'%s\t%s\t%f\n',tags{ord1(t1)},tags{ord1(t2)},cavsTag(t1,t2));
end

fclose(fd);
%end