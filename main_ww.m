clear all;
clc;

%%******Change 'title' to choose the sequence you wish to run******%%

title ='Boy';
% title = 'Car11';          
% title = 'Caviar1'; 
% title = 'Caviar2';
% title=  'David_indoor';           %%David1
% title = 'DavidOutdoor';           %%David2
% title = 'Deer';
% title = 'Occlusion1';             %%Face1
% title = 'Sail';                   %%Face2
% title = 'Occlusion2';             %%Face3
% title = 'Girl';
% title = 'Leno';
% title = 'Singer1';
% title = 'Stone'; 
% title = 'Sylvester2008b';         %%Sylv


%%******Change 'title' to choose the sequence you wish to run******%%


%%***********************1.Initialization****************************%%
addpath(genpath('./Evaluation/'));
addpath(genpath('./subfunctions/'));
trackparam;
%%1.1 Initialize variables:
if ~exist('opt','var')        opt = [];  end
if ~isfield(opt,'tmplsize')   opt.tmplsize = [32,32];  end                  
if ~isfield(opt,'numsample')  opt.numsample = 600;  end                     
if ~isfield(opt,'affsig')     opt.affsig = [4,4,.02,.02,.005,.001];  end                   
if ~isfield(opt,'ff')         opt.ff = 1.0;  end   
if ~isfield(opt,'l1_param')
    opt.l1_param.lambda = 0.2;
    opt.l1_param.lambda2 = 0;
    opt.l1_param.mode = 2;
    opt.l1_param.pos = 'false';
end
if ~isfield(opt,'updateRate') opt.updateRate = 0.95;    end
if ~isfield(opt,'updateTR')   opt.updateTr   = 0.1;    end
if ~isfield(opt,'blockNum')   opt.blockNum = [4 4]; end
if ~isfield(opt,'blockIndex')
    load blockIndex_44.mat;
    opt.blockIndex = blockIndex;
end
%%1.2 Load functions and parameters:
param0 = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];      
param0 = affparam2mat(param0);                  %%The affine parameter of 
                                                %%the tracked object in the first frame
rand('state',0);  randn('state',0);
temp = importdata([dataPath 'datainfo.txt']);   %%DataInfo: Width, Height, Frame Number
TotalFrameNum = temp(3);                        %%Total frame number
frame = imread([dataPath '1.jpg']);             %%Load the first frame
if  size(frame,3) == 3
    framegray = double(rgb2gray(frame))/256;    %%For color images
else
    framegray = double(frame)/256;              %%For Gray images
end
%1.3 Load functions and parameters:
tmpl.mean = warpimg(framegray, param0, opt.tmplsize);                                   
%
param = [];
param.est = param0;                                     
param.wimg = tmpl.mean;    
tmpl.st = tmpl.mean;
% draw initial track window
drawopt = drawtrackresult([], 0, frame, tmpl, param);
disp('resize the window as necessary, then press any key..'); pause;
%%***********************1.Initialization****************************%%

%%***********************2.Object Tracking***************************%%
weakLearnerNum = 5;         %%总弱分类器个数
updateNum      = 1;         %%每帧需重新训练的弱分类器个数
result = [];    %%Tracking results
duration = 0; 
opt.title=title;
tic;
for num = 1:TotalFrameNum   
    num
    opt.f=num;
    %%2.1 Load the (num)-th frame
    frame = imread([dataPath int2str(num) '.jpg']);
    if  size(frame,3) == 3
        framegray = double(rgb2gray(frame))/256;
    else
        framegray = double(frame)/256;
    end
    frameTemp=frame(:,:,1);
    %%2.2 Do tracking
    if num==1
        [sample label sz img_sear ] = collect_sample_RGB(double(frame), opt.tmplsize, param.est,2);
        strongClassifier = ensemble_boosting_train(sample, label, [], weakLearnerNum, updateNum, 0);%初始分块权重计算
        weight= ones(1,opt.blockNum(1)*opt.blockNum(2))./(opt.blockNum(1)*opt.blockNum(2));
        param = estwarp_condens_L1N_all(framegray, tmpl, param, opt, weight); 
    else 
        [sample label sz img_sear] = collect_sample_RGB(double(frame), opt.tmplsize, param.est);
        confidenceValue  = ensemble_boosting_test(sample, strongClassifier);
        confidenceMap =1./(1+exp(-confidenceValue));
        confidenceMap=reshape(confidenceMap,[sz(1),sz(2)]);
        confidenceMapV = imresize(confidenceMap, opt.tmplsize);
        confidenceMapV = reshape(confidenceMapV, [opt.tmplsize(1)*opt.tmplsize(2),1]);
        weight=[];
        for ii = 1:opt.blockNum(1)
          for jj = 1:opt.blockNum(2)
                weightTemp = sum(confidenceMapV(opt.blockIndex{ii,jj}));
                weight = [weight,weightTemp];
            end
        end
        weight = weight./sum(weight);
        param  = estwarp_condens_L1N_all(framegray, tmpl, param, opt,weight); 
        if  param.classiferUp ==1
            [sample label sz img_sear ] = collect_sample_RGB(double(frame), opt.tmplsize, param.est,2);
            strongClassifier = ensemble_boosting_train(sample, label, strongClassifier, weakLearnerNum, updateNum, 1);
        end
    end
    result = [ result; param.est ];
    %%2.3 Model Update
    tmpl = update_tracker(tmpl, param, opt);    
    %%2.4 Draw tracking results
    drawopt = drawtrackresult(drawopt, num, frame, tmpl, param);   
end
duration = duration + toc;      
fprintf('%d frames took %.3f seconds : %.3fps\n',num, duration, num/duration);
fps = num/duration;
%%***********************2.Object Tracking***************************%%

%%*************************3.STD Results*****************************%%
L1N44CenterAll  = cell(1,TotalFrameNum);      
L1N44CornersAll = cell(1,TotalFrameNum);
for num = 1:TotalFrameNum
    if  num <= size(result,1)
        est = result(num,:);
        [ center corners ] = p_to_box([32 32], est);
    end
    L1N44CenterAll{num}  = center;      
    L1N44CornersAll{num} = corners;
end
save([ title '_RS.mat'], 'L1N44CenterAll', 'L1N44CornersAll', 'fps');
%%*************************3.STD Results*****************************%%
%
load(['./Data/' title '/' title '_gt.mat']);
%
[ overlapRate ] = overlapEvaluationQuad(L1N44CornersAll, gtCornersAll, frameIndex);
mOverlapRate = mean(overlapRate)
%
%
mSuccessRate = sum(overlapRate>0.5)/length(overlapRate)
%
[ centerError ] = centerErrorEvaluation(L1N44CenterAll, gtCenterAll, frameIndex);
mCenterError = mean(centerError)