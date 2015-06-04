function simIRSI = coupled_IeAVS_IRSI(vec1, vec2, N1, N2)
% For example, vec1 is tag and vec2 is user.
% item is images.
%%
% for every user u, uk{u} is the index of images upload by this user
%disp('Step 1: find items linked to each entrices');
gk = cell(0);
for i=1:N2
    gk{i} = gstarFun(vec2, i);
end

%%
%disp('Step 2: find transport probability of entry 1 and entry 2');
% for every tag, g is the index of images contain this tag
gi = cell(0);
% for every tag, phi is the index of users who upload images contain this tag
phi = cell(0);
% p is the transprot probability from tag i to user j
p = zeros(N1,N2);

%
for i=1:N1
    if mod(i,100)==0
        fprintf('%d/%d\n',i,N1);
    end
    g = gFun(vec1, i);
    gi{i} = g;
    phi{i} = phiFuncwithG(vec2, g);
    for j=1:N2
        p(i,j) = pFunwithG(vec2, g, gk{j});
    end
end

%%
%disp('Step 3: find pairwise similarity');

simIRSI = zeros(N1);
for i=1:N1
    if mod(i,100)==0
        fprintf('%d/%d\n',i,N1);
    end
    for j=i+1:N1
        simIRSI(i,j) = IRSI(phi, i, j, p);
    end
end
simIRSI = simIRSI+simIRSI'+eye(N1);

end

function delta = IRSI(phi, i, j, p)
% inter-coupled interaction IRSI
phix = phi{i};
phiy = phi{j};
if ~iscell(phix)
    W = intersect( phix, phiy );
else
    W1 = [];
    for pp=phix
        W1 = [W1 pp{1}];
    end
    W2 = [];
    for pp=phiy
        W2 = [W2 pp{1}];
    end
    W = intersect(W1,W2);
end

delta = 0;

if isempty(W)
    return;
end
%fprintf('%d\n',length(W));

for t = 1:length(W)
    w=W(t);
    x1 = p(i,w);
    x2 = p(j,w);
    delta = delta + min( x1 , x2 );
end
        

end



function f = fstarFun( vec, U )
%f^star_j({u_k1,...u_kt})={f_j(u_k1),...,f_j(u_kn)}
if iscell(vec)
    f = cell(0);
else
    f=[];
end
for u=U
    f = [f vec(u)];
end
end

function u = gFun( vec, x )
% find g_j(x) = {u_i| x \in f_j(u_i)}
% vec can be a cell list
if iscell(vec)
    u=[];
    for v = 1:length(vec)
        if ~isempty(find(vec{v}==x, 1))
            u=[u v];
        end
    end
else
    u = find(vec==x);
end
end

function u = gstarFun( vec, W )
% find g^star_j(W) = {u_i|f_j(u_i)\in W}
u=[];
for w = W
    u=[u gFun( vec, w )];
end
u=unique(u);
end


function P = pFun( veck, vecj, W, x )
% P_{k|j}(W|x)
uj = gFun(vecj, x);
uk = gstarFun(veck, W);
uintersect = intersect(uj,uk);
if isempty(uintersect)
    P=0;
    return;
end
P = length(uintersect)/length(uj);
end

function P = pFunwithG(vecj, gj, gk)
uintersect = intersect(gj,gk);
if isempty(uintersect)
    P=0;
    return;
end

if ~iscell(vecj)
    P = length(uintersect)/length(gj);
else
    % tags linked to image uploaded by j
    jEntries = [];
    for t = gj
        jEntries = [jEntries vecj{t}];
    end
    % # of tag k divided by total # of tags by user j.
    P = length(uintersect)/length(jEntries);
end
end


function phi = phiFunc(veck, vecj, x)
% phi_{j->k}(x) = f^star_k(g_j(x))
phi = fstarFun(veck, gFun(vecj, x));
end


function phi = phiFuncwithG(veck, gx)
% phi_{j->k}(x) = f^star_k(g_j(x))
phi = fstarFun(veck, gx);
end