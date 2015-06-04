% toy example of Coupled Object Similarity with attributes of multi-entries
%% generate toy examples
vectors = cell(1,3);
Ns = {4,4,3};
vectors{1} = [1,2,2,3,4,4];
vectors{2} = {[1,2],[1,3],[2,4],[1,2,3],[2,3],[1,2,4]};
vectors{3} = [1,1,2,2,2,3];
types = {'user','tag','user'};

%% print toy examples
disp('************************************************')
disp('************************************************')
disp('!!!Toy example for Coupled Object Similarity (COS) with multi-entry attributes');
disp('Input samples:')
fprintf('We have 6 samples:\tA\tB\tC\tD\tE\tF\n');
fprintf('Vector 1 (single-entry): ');
for i=1:length(vectors{1})-1, fprintf('%d,\t', vectors{1}(i)); end
fprintf('%d\n', vectors{1}(end));

fprintf('Vector 2 (multi-entry): ');
for i=1:length(vectors{2})
    fprintf('[')
    for j=1:length(vectors{2}{i})-1
        fprintf('%d,', vectors{2}{i}(j));
    end
    fprintf('%d]', vectors{2}{i}(end));
    if i<length(vectors{2})
        fprintf(',\t');
    end
end
fprintf('\n');

fprintf('Vector 3 (single-entry): ');
for i=1:length(vectors{3})-1, fprintf('%d,\t', vectors{3}(i)); end
fprintf('%d\n', vectors{3}(end));
disp('************************************************')
disp('************************************************')


%% run coupled algorithm
[COS, COS_Final] = coupled_main(vectors, Ns, types, 0, 0);

disp('Coupled similarity results:');
fprintf('\tA\tB\tC\tD\tE\tF\n');
x='ABCDEF';
for i=1:size(COS_Final,1)
    fprintf('%s\t', x(i));
    for j =1:size(COS_Final,2)
        fprintf('%.3f\t', COS_Final(i,j));
    end
    fprintf('\n');
end

disp('************************************************')
disp('************************************************')

