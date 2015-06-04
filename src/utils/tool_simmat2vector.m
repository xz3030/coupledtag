function D = tool_simmat2vector(sim)
% turn similarity/distant matrix sim m*m to vector 
% The output D is arranged in the order of ((2,1),(3,1),...,
% (m,1),(3,2),...(m,2),.....(m,m–1)),

m = size(sim,1);
D = zeros(1,m*(m-1)/2);
index = 1;
for i=1:m
    for j=i+1:m
        D(index) = sim(i,j);
        index = index+1;
    end
end


end