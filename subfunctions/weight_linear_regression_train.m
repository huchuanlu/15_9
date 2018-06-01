function [ beta predictLabel ] = weight_linear_regression_train(sample, label, weight)


featureNum = size(sample,2);

p = zeros(size(sample,1),size(sample,1));
s = zeros(size(sample,1),1);
for i = 1:featureNum
    p = p + weight(i)*sample(:,i)*sample(:,i)';
    s = s + weight(i)*label(i)*sample(:,i);
end

beta = inv(p)*s;

predictLabel = ones(size(label));
predictLabel(find(beta'*sample<0)) = -1;


