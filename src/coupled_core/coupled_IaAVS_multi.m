function [simmat, abs_idf] = coupled_IaAVS_multi( vector, N )
% IaAVS modified to fit multiple set
%% coupled stats
Nitem = length(vector);
freq = zeros(1,N);
coocc_mat = zeros(N);
for ind=1:Nitem
    tt = vector{ind};
    freq(tt) = freq(tt)+1;
    for i=1:length(tt)
        for j=1:length(tt)
            coocc_mat(tt(i),tt(j))=coocc_mat(tt(i),tt(j))+1;
        end
    end
end


% each row is out degree, each column is in degree
for i=1:N
	coocc_mat_1(i,:) = coocc_mat(i,:)/(freq(i)+eps);
end

% out degree
in_degree = sum(coocc_mat_1,1);
out_degree = sum(coocc_mat_1,2);
abstract_measure = in_degree./out_degree';
%[abs_sort,abs_ind]=sort(freq,'descend');
abs_idf = 1./log(abstract_measure+1);
%abs_idf = 1./abstract_measure;
%abs_idf = log(abstract_measure+1);
abs_idf = abs_idf/mean(abs_idf);

simmat = zeros(N);
% most frequently tags
for i=1:N
    for j=i+1:N
        simmat(i,j) = 2*coocc_mat(i,j)/(coocc_mat(i,i)+coocc_mat(j,j));
    end
end
simmat = simmat+simmat'+eye(N);

end