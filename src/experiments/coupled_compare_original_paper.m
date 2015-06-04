function COS_Final = coupled_compare_original_paper(vectors, Ns, types, times)
% config
t1=cputime;
coupled_config;

%%
vector_Tag = vectors{1};
Ntag = Ns{1};
Nim = length(vector_Tag);
new_vector_Tag = cell(1,Ntag);
new_Ns = cell(1,Ntag);
new_Type = cell(1,Ntag);
for i=1:Ntag
    new_vector_Tag{i} = ones(1,Nim);
    new_Ns{i} = 2;
    new_Type{i} = sprintf('tag_%d',i);
end

% reshape vector tag
for i = 1:Nim
    tag = vector_Tag{i};
    for k=tag
        new_vector_Tag{k}(i)=2;
    end
end

%%
vectors = [new_vector_Tag vectors(2:end)];
Ns = [new_Ns Ns(2:end)];
types = [new_Type types(2:end)];

%%

[COS, COS_Final] = coupled_main(cp.classInd, vectors, Ns, types, times, 'ori');
etime=cputime-t1
save('../data/coupled_sim_/1063441@N20/Run_ori.mat','COS','COS_Final','etime');

end