function strongClassifier = ensemble_boosting_train(sample, label, oldStrongClassifier, weakLearnerNum, updateNum, updateFlag)
%%function strongClassifier = ensemble_boosting_train(sample, label, oldStrongClassifier, weakLearnerNum, updateNum, updateFlag)
%%
%%输入：
%%  sample                :   [ 特征维数 样本个数 ]
%%  label                 :   [    1    样本个数 ]
%%  weakLearnerNum        :   弱分类器个数
%%  updateNum             ：  待更新分类器个数，(weakLearnerNum-updateNum)需要重新训练的分类器个数
%%  updateFlag            ：  更新还是重新训练，一般第一帧时新训练分类器，其余帧更新分类器
%%  oldStrongClassifier   :   旧的强分类器
%%
%%输出：
%%  strongClassifier      ：  强分类器

sampleNum  = size(sample,2);                    %%样本个数
sample = [ sample ; ones(1,sampleNum) ];        %%加1
featureDim = size(sample,1);                    %%特征维数

%%正负样本初始权重(保持正负样本均衡)
% positiveNum = sum(label== 1);
% negativeNum = sum(label==-1);
% weight = zeros(1,sampleNum);
% weight(find(label== 1)) = 1/(2*positiveNum);    %%正样本权重和为0.5
% weight(find(label==-1)) = 1/(2*negativeNum);    %%负样本权重和为0.5

%%正负样本
weight = ones(1,sampleNum) / sampleNum;

%%训练或更新强分类器
strongClassifier = [];
if updateFlag ~= 1  %%新训练
    for i = 1:weakLearnerNum

        %%权重线性回归：
        [ beta predictLabel ] = weight_linear_regression_train(sample, label, weight); 
        
        %%权重误差：
        weightErr = weight*(predictLabel~=label)';
        
        %%如果误差大于0.5,执行反向操作(**分类误差大于0.5的话，证明分类器恰好反了)：
        if  weightErr > 0.5 
            beta         = -beta;           
            predictLabel = -predictLabel;   
            weightErr    = 1 - weightErr;
        end
        
        %%分类器权重：    
        alpha = 0.5*log((1-weightErr)./weightErr);
        
        %%样本权重更新(abs(predictLabel-label))：
        weight = weight.*exp(alpha.*abs(predictLabel-label));
        
        %%权重归一化：
        weight = weight/sum(weight);
        
        %%存储弱分类器[参数，错误率，权重]：
        weakLearner = [];
        weakLearner.beta      = beta;
        weakLearner.weightErr = weightErr;
        weakLearner.alpha     = alpha;
        
        %%强分类器：
        strongClassifier  = [ strongClassifier weakLearner ]; 
        
    end
else    %%更新
    
    %%(1)-------------选择最好的updateNum个分类器，更新分类器权重，更新样本权重-------------
    for i = 1:updateNum 
        
        weightErrAll = [];
        for j = 1:weakLearnerNum+1-i
            
            %%测试
            predictLabel = ones(1,sampleNum);
            predictLabel(oldStrongClassifier(j).beta'*sample<0) = -1;
            
            %%权重误差：
            weightErr = weight*(predictLabel~=label)';
            
            %%如果误差大于0.5,执行反向操作(**分类误差大于0.5的话，证明分类器恰好反了)：
            if  weightErr > 0.5 
                oldStrongClassifier(j).beta = -oldStrongClassifier(j).beta;
                weightErr = 1 - weightErr;
            end
            weightErrAll = [ weightErrAll weightErr ];
        end
        
        %%挑选错误率最小的弱分类器：
        [ weightErr index ] = min(weightErrAll); 
        
        %%存储弱分类器：
        weakLearner = [];                                      
        weakLearner.beta      = oldStrongClassifier(index).beta;
        weakLearner.weightErr = weightErr;
        weakLearner.alpha     = 0.5*log((1-weightErr)./weightErr);
        strongClassifier      = [ strongClassifier weakLearner ];
        
        %%样本权重更新(abs(predictLabel-label))：
        predictLabel = ones(1,sampleNum);
        predictLabel(oldStrongClassifier(index).beta'*sample<0) = -1;
        weight = weight.*exp(oldStrongClassifier(index).alpha.*abs(predictLabel-label));
        
        %%权重归一化：
        weight = weight/sum(weight);

        %%从候选分类器集合中剔除已选择的弱分类器
        oldStrongClassifier(index) = [];   
        
    end
    %%(1)-------------选择最好的updateNum个分类器，更新分类器权重，更新样本权重-------------
    
    
    %%(2)-----------------------------重新训练剩余的分类器--------------------------------
    for i = updateNum+1:weakLearnerNum
        
        %%权重线性回归：
        [ beta predictLabel ] = weight_linear_regression_train(sample, label, weight); 
        
        %%权重误差：
        weightErr = weight*(predictLabel~=label)';
        
        %%如果误差大于0.5,执行反向操作(**分类误差大于0.5的话，证明分类器恰好反了)：
        if  weightErr > 0.5 
            beta         = -beta;
            predictLabel = -predictLabel;
            weightErr    = 1 - weightErr;
        end
        
        %%分类器权重：    
        alpha = 0.5*log((1-weightErr)./weightErr);
        
        %%样本权重更新：
        weight = weight.*exp(alpha.*abs(predictLabel-label));
        
        %%权重归一化：
        weight = weight/sum(weight);
        
        %%存储弱分类器[参数，错误率，权重]
        weakLearner = [];
        weakLearner.beta      = beta;
        weakLearner.weightErr = weightErr;
        weakLearner.alpha     = alpha;
        
        %%强分类器
        strongClassifier  = [ strongClassifier weakLearner ]; 
        
    end
    %%(2)-----------------------------重新训练剩余的分类器--------------------------------
end


