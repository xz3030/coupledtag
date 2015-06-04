function [simmat, abs_idf] = coupled_IaAVS_multi_v0( vector, N )
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
	coocc_mat(i,:) = coocc_mat(i,:)/(freq(i)+eps);
end

% out degree
out_degree = sum(coocc_mat,1);
in_degree = sum(coocc_mat,2);
abstract_measure = out_degree./in_degree';
[abs_sort,abs_ind]=sort(freq,'descend');
%abs_idf = 1./log10(abstract_measure+1);
abs_idf = 1./abstract_measure;
abs_idf = abs_idf/max(abs_idf);

% most frequently tags
[freq_sort,ind_sort]=sort(freq,'descend');

% similarity matrix
simmat = coocc_mat+coocc_mat';
simmat = simmat-.5*ones(N)-.5*eye(N);

% deleted when consider negative impact
simmat = simmat.*(simmat>0);
%simmat = simmat.*simIRSI;

simmat1 = simmat.*(triu(ones(N),0));
%simmat = simmat-eye(N);

end