function [ predictValue predictLabel ] = ensemble_boosting_test(sample, strongClassifier);
%%function [ predictValue predictLabel ] = ensemble_boosting_test(sample, strongClassifier);
%%
%%���룺
%%      sample              ��   ����������
%%      strongClassifier    ��   ǿ������
%%
%%�����
%%      predictValue        :    ����ֵ--����Margin
%%      predictLabel        :    ������lable

sampleNum  = size(sample,2);                    %%��������
sample = [ sample ; ones(1,sampleNum) ];        %%��1
weakLearnerNum = size(strongClassifier,2);      %%������������

%%����ֵ(������������)�����е������������������Է�����Ȩ�ؼӺ�
predictValue = zeros(1,sampleNum);
for i = 1:weakLearnerNum
    sgnTemp = 2*(strongClassifier(i).beta'*sample>0) - 1;
    predictValue = predictValue + strongClassifier(i).alpha*sgnTemp;
end

%%������lable
predictLabel = ones(1,sampleNum);
predictLabel(find(predictValue<0)) = -1;