function [ predictValue predictLabel ] = ensemble_boosting_test(sample, strongClassifier);
%%function [ predictValue predictLabel ] = ensemble_boosting_test(sample, strongClassifier);
%%
%%输入：
%%      sample              ：   待分类样本
%%      strongClassifier    ：   强分类器
%%
%%输出：
%%      predictValue        :    分类值--分类Margin
%%      predictLabel        :    分类器lable

sampleNum  = size(sample,2);                    %%样本个数
sample = [ sample ; ones(1,sampleNum) ];        %%加1
weakLearnerNum = size(strongClassifier,2);      %%弱分类器个数

%%分类值(先求符号再求和)，所有的弱分类器分类结果乘以分类器权重加和
predictValue = zeros(1,sampleNum);
for i = 1:weakLearnerNum
    sgnTemp = 2*(strongClassifier(i).beta'*sample>0) - 1;
    predictValue = predictValue + strongClassifier(i).alpha*sgnTemp;
end

%%分类器lable
predictLabel = ones(1,sampleNum);
predictLabel(find(predictValue<0)) = -1;