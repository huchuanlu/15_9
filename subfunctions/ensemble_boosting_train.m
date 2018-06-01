function strongClassifier = ensemble_boosting_train(sample, label, oldStrongClassifier, weakLearnerNum, updateNum, updateFlag)
%%function strongClassifier = ensemble_boosting_train(sample, label, oldStrongClassifier, weakLearnerNum, updateNum, updateFlag)
%%
%%���룺
%%  sample                :   [ ����ά�� �������� ]
%%  label                 :   [    1    �������� ]
%%  weakLearnerNum        :   ������������
%%  updateNum             ��  �����·�����������(weakLearnerNum-updateNum)��Ҫ����ѵ���ķ���������
%%  updateFlag            ��  ���»�������ѵ����һ���һ֡ʱ��ѵ��������������֡���·�����
%%  oldStrongClassifier   :   �ɵ�ǿ������
%%
%%�����
%%  strongClassifier      ��  ǿ������

sampleNum  = size(sample,2);                    %%��������
sample = [ sample ; ones(1,sampleNum) ];        %%��1
featureDim = size(sample,1);                    %%����ά��

%%����������ʼȨ��(����������������)
% positiveNum = sum(label== 1);
% negativeNum = sum(label==-1);
% weight = zeros(1,sampleNum);
% weight(find(label== 1)) = 1/(2*positiveNum);    %%������Ȩ�غ�Ϊ0.5
% weight(find(label==-1)) = 1/(2*negativeNum);    %%������Ȩ�غ�Ϊ0.5

%%��������
weight = ones(1,sampleNum) / sampleNum;

%%ѵ�������ǿ������
strongClassifier = [];
if updateFlag ~= 1  %%��ѵ��
    for i = 1:weakLearnerNum

        %%Ȩ�����Իع飺
        [ beta predictLabel ] = weight_linear_regression_train(sample, label, weight); 
        
        %%Ȩ����
        weightErr = weight*(predictLabel~=label)';
        
        %%���������0.5,ִ�з������(**����������0.5�Ļ���֤��������ǡ�÷���)��
        if  weightErr > 0.5 
            beta         = -beta;           
            predictLabel = -predictLabel;   
            weightErr    = 1 - weightErr;
        end
        
        %%������Ȩ�أ�    
        alpha = 0.5*log((1-weightErr)./weightErr);
        
        %%����Ȩ�ظ���(abs(predictLabel-label))��
        weight = weight.*exp(alpha.*abs(predictLabel-label));
        
        %%Ȩ�ع�һ����
        weight = weight/sum(weight);
        
        %%�洢��������[�����������ʣ�Ȩ��]��
        weakLearner = [];
        weakLearner.beta      = beta;
        weakLearner.weightErr = weightErr;
        weakLearner.alpha     = alpha;
        
        %%ǿ��������
        strongClassifier  = [ strongClassifier weakLearner ]; 
        
    end
else    %%����
    
    %%(1)-------------ѡ����õ�updateNum�������������·�����Ȩ�أ���������Ȩ��-------------
    for i = 1:updateNum 
        
        weightErrAll = [];
        for j = 1:weakLearnerNum+1-i
            
            %%����
            predictLabel = ones(1,sampleNum);
            predictLabel(oldStrongClassifier(j).beta'*sample<0) = -1;
            
            %%Ȩ����
            weightErr = weight*(predictLabel~=label)';
            
            %%���������0.5,ִ�з������(**����������0.5�Ļ���֤��������ǡ�÷���)��
            if  weightErr > 0.5 
                oldStrongClassifier(j).beta = -oldStrongClassifier(j).beta;
                weightErr = 1 - weightErr;
            end
            weightErrAll = [ weightErrAll weightErr ];
        end
        
        %%��ѡ��������С������������
        [ weightErr index ] = min(weightErrAll); 
        
        %%�洢����������
        weakLearner = [];                                      
        weakLearner.beta      = oldStrongClassifier(index).beta;
        weakLearner.weightErr = weightErr;
        weakLearner.alpha     = 0.5*log((1-weightErr)./weightErr);
        strongClassifier      = [ strongClassifier weakLearner ];
        
        %%����Ȩ�ظ���(abs(predictLabel-label))��
        predictLabel = ones(1,sampleNum);
        predictLabel(oldStrongClassifier(index).beta'*sample<0) = -1;
        weight = weight.*exp(oldStrongClassifier(index).alpha.*abs(predictLabel-label));
        
        %%Ȩ�ع�һ����
        weight = weight/sum(weight);

        %%�Ӻ�ѡ�������������޳���ѡ�����������
        oldStrongClassifier(index) = [];   
        
    end
    %%(1)-------------ѡ����õ�updateNum�������������·�����Ȩ�أ���������Ȩ��-------------
    
    
    %%(2)-----------------------------����ѵ��ʣ��ķ�����--------------------------------
    for i = updateNum+1:weakLearnerNum
        
        %%Ȩ�����Իع飺
        [ beta predictLabel ] = weight_linear_regression_train(sample, label, weight); 
        
        %%Ȩ����
        weightErr = weight*(predictLabel~=label)';
        
        %%���������0.5,ִ�з������(**����������0.5�Ļ���֤��������ǡ�÷���)��
        if  weightErr > 0.5 
            beta         = -beta;
            predictLabel = -predictLabel;
            weightErr    = 1 - weightErr;
        end
        
        %%������Ȩ�أ�    
        alpha = 0.5*log((1-weightErr)./weightErr);
        
        %%����Ȩ�ظ��£�
        weight = weight.*exp(alpha.*abs(predictLabel-label));
        
        %%Ȩ�ع�һ����
        weight = weight/sum(weight);
        
        %%�洢��������[�����������ʣ�Ȩ��]
        weakLearner = [];
        weakLearner.beta      = beta;
        weakLearner.weightErr = weightErr;
        weakLearner.alpha     = alpha;
        
        %%ǿ������
        strongClassifier  = [ strongClassifier weakLearner ]; 
        
    end
    %%(2)-----------------------------����ѵ��ʣ��ķ�����--------------------------------
end


