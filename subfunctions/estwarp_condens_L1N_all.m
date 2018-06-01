function param = estwarp_condens_L1N_all(frm, tmpl, param, opt,weight)

%%************************1.Candidate Sampling************************%%
n = opt.numsample;
sz = size(tmpl.mean);
N = sz(1)*sz(2);
param.param = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix = randn(6,n);
param.param = param.param + randMatrix.*repmat(opt.affsig(:),[1,n]);
wimgs = warpimg(frm, affparam2mat(param.param), sz);
wimgs(wimgs<0) = 0;
%%************************1.Candidate Sampling************************%%

%%*******************2.Calucate Likelihood Probablity*******************%%
wimgsMatrix = reshape(wimgs,[N,n]);
meanVector  = reshape(tmpl.mean, [N,1]);
candidates  = [];
template    = [];
tempNormImg=zeros(N,1);
indextemp=1;
opt.l1_param.L = n;
for ii = 1:opt.blockNum(1)
    for jj = 1:opt.blockNum(2)
        meanVectorTemp  = meanVector(opt.blockIndex{ii,jj});
        meanVectorTemp  =meanVectorTemp./norm(meanVectorTemp);
        tempNormImg((opt.blockIndex{ii,jj}))=meanVectorTemp;
        wimgsMatrixTemp = wimgsMatrix(opt.blockIndex{ii,jj},:);
        wimgsMatrixTemp = wimgsMatrixTemp./...
                          (repmat(sqrt(sum(wimgsMatrixTemp.^2)),[length(opt.blockIndex{ii,jj}) 1])+eps);
        candidates = [candidates; wimgsMatrixTemp*sqrt(weight(indextemp))];
        template   = [template; meanVectorTemp*sqrt(weight(indextemp))];
        indextemp=indextemp+1;
    end
end
%
opt.l1_param.L = n;
fullalpha = mexLasso(template,candidates,opt.l1_param);
fullalpha = full(fullalpha);
tempalpha = fullalpha(1:n);
tempalpha(tempalpha<0.02)=0;
alpha= tempalpha./sum(tempalpha);
%% 显示和保存挑选的候选
index = (alpha~=0);
param.sparam=param.param(:,index);
swimgs = warpimg(frm, affparam2mat(param.sparam), sz);
swimgs(swimgs<0) = 0;
salpha=alpha(find(alpha~=0));

%%*****************3.Obtain the optimal candidate state*****************%%
if size(param.sparam,2)==1
    param.est = sum(repmat(alpha,1,6).*(affparam2mat(param.param))');
else
    param.est = sum(repmat(salpha,1,6).*(affparam2mat(param.sparam))');
end
%%*****************3.Obtain the optimal candidate state*****************%%

%%******************4.Collect samples for model update******************%%
param.wimg = warpimg(frm, param.est, sz);
reVector=param.wimg(:);
re=[];
indextemp=1;
for ii = 1:opt.blockNum(1)
    for jj = 1:opt.blockNum(2)
            reVectorTemp    = reVector(opt.blockIndex{ii,jj});
            reVectorTemp    = reVectorTemp./norm(reVectorTemp);
            re=[re;reVectorTemp*sqrt(weight(indextemp))];
            indextemp=indextemp+1;
    end
end
Rdis=norm(re-template);
if Rdis < 0.2
    param.classiferUp = 1;
else
    param.classiferUp = 0;
end
%%******************4.Collect samples for model update******************%%
