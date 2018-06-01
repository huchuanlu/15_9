function [sample label sz img_sear] = collect_sample_RGB(img, sz, p,rangetemp)

M = [p(1) p(3) p(4); p(2) p(5) p(6)];
w = sz(1);
h = sz(2);
corners = [ 1,-w/2,-h/2; 1,w/2,-h/2; 1,w/2,h/2; 1,-w/2,h/2; 1,-w/2,-h/2 ]';
corners = M * corners;
if nargin==4
   range = rangetemp;
else 
   range=1.0;
end
x_min = p(1)-range*p(3)*w/2;
x_max = p(1)+range*p(3)*w/2;
y_min = p(2)-range*p(6)*h/2;
y_max = p(2)+range*p(6)*h/2;
x_min = max(x_min, 1);
x_max = min(x_max, size(img,2));
y_min = max(y_min, 1);
y_max = min(y_max, size(img,1));

x_i = uint16(corners(1,:) - x_min)';
y_i = uint16(corners(2,:) - y_min)';

y = repmat(1:uint16(y_max)-uint16(y_min)+1, 1, uint16(x_max)-uint16(x_min)+1)';
x = repmat(1:uint16(x_max)-uint16(x_min)+1,uint16(y_max)-uint16(y_min)+1,1);
x = reshape(x,numel(x),1);
in = inpolygon(x, y, x_i, y_i);
label = ones(1, length(in));
label(~in) = -1;
% labelmap = reshape(label, uint16(y_max)-uint16(y_min)+1, []);
sample = img(uint16(y_min):uint16(y_max), uint16(x_min):uint16(x_max), :);%RGB feature;

boun = uint16([y_min y_max x_min x_max]);
img_sear = uint8(sample);
sz = size(sample);
sample = reshape(sample, size(sample,1)*size(sample,2), size(sample,3))';  %按列优先 先第一列 再第二列 再第三列 ...

% % samlabel = [sample; label];
% sam_pos = sample(:,in);
% lab_pos = find(in==1);
% sam_neg = sample(:,~in);
% lab_neg = find(in==0);
% % % samplee = [sam_pos sam_neg];
% % sam_pos(:,ia)=0;
% % sam_neg(:,ib)=0;
% % reshape(sam_pos', size(sam_pos,1), size(sam_neg,1), size(sam_pos,1));
% 
% 
% [c,ia,ib] = intersect(sam_pos',sam_neg','rows');
% sample(:,lab_pos(ia)) = 0;
% sample(:,lab_neg(ib)) = 0;
% sm = reshape(sample', size(img_sear,1), size(img_sear,2),size(img_sear,3));
% % imshow(mat2gray(sm));
% weight = 0.6*ones(1,size(sample,2));
% weight(lab_pos(ia)) = 0.4;
% weight(lab_neg(ib)) = 0.4;
% weightmap = reshape(weight, uint16(y_max)-uint16(y_min)+1, []);
% % weight_pos = 0.6*ones(1, size(sam_pos,2));
% % weight_pos(ia) = 0.4;
% % weight_neg = 0.6*ones(1, size(sam_neg,2));
% % weight_neg(ib) = 0.4;
% % weight = [weight_pos weight_neg];
% weight = weight/sum(weight);
% 
% 
% % sam_pos(:,ia)
% % 
% % lab_pos = ones(size(weight_pos));
% % lab_neg = (-1)*ones(size(weight_neg));
% % labele = [lab_pos lab_neg];
% 
% % img_in(:,:,1) = img_sear(:,:,1).*labelmap;
% % img_in(:,:,2) = img_sear(:,:,2).*labelmap;
% % img_in(:,:,3) = img_sear(:,:,3).*labelmap;
% % 
% % img_out(:,:,1) = img_sear(:,:,1).*(1-labelmap);
% % img_out(:,:,2) = img_sear(:,:,2).*(1-labelmap);
% % img_out(:,:,3) = img_sear(:,:,3).*(1-labelmap);
% 
% % [rgb_in dcount_lab mark_in dis_in] = rgbQuan (img_sear, bin, labelmap, weightmap, 1);
% % [rgb_out , ~, mark_out dis_out] = rgbQuan (img_sear, bin, labelmap, weightmap, -1);
% % [maxdis pos2neg.dis] = max(dis_in);
% % all_in = size(lab_pos,1);
% % all_out = size(lab_neg,1);
% % overarea_in = rgb_in(dcount_lab)/all_in;
% % overarea_out = rgb_out(dcount_lab)/all_out;
% % tao1 = 0.08;
% % tao2 = 0.08;
% % pos2neg.area = find(overarea_in<=tao1&overarea_out>=tao2);
% % % pos2neg.area = find(overarea_in<=overarea_out);
% % labelmap = changepos(dcount_lab, pos2neg, mark_in, labelmap);
% % % figure,imshow(mat2gray(labelmap));
% % label = reshape(labelmap, 1, []);
