%function coupled_tag_cooccurance( Niter, tags )
% tag distance on flickr group using coupled behavior analysis

coupled_config;
%%
classname = cp.classname{cp.classInd};
class_simpath = sprintf('%s/%s', cp.sim_file_path, classname);


%%
CAVS_fileName = sprintf('%s/Run%d/%sCAVS.mat', class_simpath, Niter, '');
load(CAVS_fileName);

Ia_Tag = CAVS{1};
Ntag = size(Ia_Tag,1);
%Ia_Tag = Ia_Tag.*(tril(ones(Ntag),0)-eye(Ntag));
Ia_Tag = Ia_Tag-eye(Ntag);

%%
tag_co = (W{2})'*W{2};
tag_freq = diag(tag_co);
tag_co_norm = tag_co./repmat(tag_freq,1,Ntag);
tag_co_norm = tag_co_norm-eye(Ntag);

Re_Ia = Ia_Tag./(tag_co_norm+eps);

[nt,ft]=sort(tag_freq, 'descend');
for i=1:20
    t1 = ft(i);
    fprintf('\n%s:\n',tags{t1});
    tmp = Ia_Tag(t1,:);
    tmp3= tag_co_norm(t1,:);
    [n2,f2]=sort(tmp, 'descend');
    [n3,f3]=sort(tmp3,'descend');
    for j=1:10
        t2 = f2(j);
        t3 = f3(j);
        fprintf('%s: %f\t\t %f: %s \n',...
        tags{t2}, n2(j), n3(j), tags{t3});
    end
    pause;
end

%{
%%
%[x,y]=sort(Ia_Tag(:), 'descend');
%y=y(x>0.4 & x<1);
%x=x(x>0.4 & x<1);
[x,y]=sort(Re_Ia(:), 'descend');
y=y(x>0.2);
x=x(x>0.2);
for i=1:length(x)
    [t1,t2] = ind2sub([Ntag,Ntag], y(i));
    fprintf('%f/ %f: %s / %s\n',...
        x(i),tag_co_norm(t1,t2),tags{t1},tags{t2});
end
%}
%end