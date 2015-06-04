function Ia = coupled_IaAVS( vector, N )
% IaAVS, only depend on frequency 

Nitem = length(vector);
freq = zeros(1,N);
for i=1:Nitem
    freq(vector(i)) = freq(vector(i))+1;
end

Ia = zeros(N,N);
for i=1:N
    for j=1:N
        Ia(i,j)=freq(i)*freq(j)/( freq(i)+freq(j)+freq(i)*freq(j) );
    end
end

end