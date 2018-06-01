% 'p = [px, py, sx, sy, theta]'; 
% the location of the target in the first frame.
%      
% px and py are the coordinates of the center of the box;
%
% sx and sy are the size of the box in the x (width) and y (height)
% dimensions, before rotation;
%
% theta is the rotation angle of the box;
% 'affsig';
% these are the standard deviations of the dynamics distribution, and it controls the scale, size and area to 
% sample the candidates.
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = x & y scaling
%    affsig(4) = rotation angle
%    affsig(5) = aspect ratio
%    affsig(6) = skew angle
%%******Change 'title ' to choose the sequence you wish to run******%%
switch (title) 
 case 'Boy'
       p=[288+35/2,143+42/2,35,42,0];
       opt = struct('numsample',600, 'condenssig',0.1, 'ff',1, ...
      'batchsize',5, 'affsig',[12,12,.008,.001,.005,.0]);  
 case 'sylvester2008b';  
        p = [329,170,82,88, 0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
              'batchsize',5, 'affsig',[14,8,.012,.00,.00,.00]);%          
case 'David_indoor';  
p = [194 108 46	60 0];
opt = struct('numsample',300, 'condenssig',0.75, 'ff',0.99, ...
             'batchsize',5, 'affsig',[4, 4,.01,.015,.0001,.0001]);
    case 'Occlusion1'; 
        p = [177,147,115,145,0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[4,4,.005,.00,.00,.000]);         
    %
    case 'Occlusion2';    
        p = [156,107,74,100,0.00];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[4, 4,.005,.015,.000,.000]);
    %             
    case 'Sail';         
        p = [149,82,54,60,0.02];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[4,4,.01,.000,.000,.000]);
    %
    case 'Caviar1'; 
        p = [145,112,30,79,0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[3, 3,.005, 0, 0, 0]);
    %  
    case 'Caviar2';   
        p = [152, 68, 18, 61, 0.00];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[3, 3,.005,.0 ,0, 0]);
    case 'Car4'; 
        p = [245 180 200 150 0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[1,1,.0005,.0005,.0005,.0005]);
    %
    case 'Singer1';  
        p = [100, 200, 100, 300, 0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[3,3,.015,.00,.000,.000]);
    %
    case 'Car11';  
        p = [89 140 30 25 0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[1,1,.005,.000,.000,.000]); 
    %
    case 'Stone'; 
        p = [115 150 43 20 0.0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[5,5,.005,.00,.000,.000]); 
    %
    case 'Girl'; 
        p = [180,109,104,127,0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[10,10,.08,.01,.000,.000]);
    %
    case 'Deer';  
        p = [350, 40, 100, 70, 0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[18,18,.00,.00,.01,.01]);
    %
    case 'DavidOutdoor'; 
        p = [102,266,36,134,0.00];
        opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
                     'batchsize',5, 'affsig',[6,3,.00,.000,.000,.000]);                
    %
    case 'Leno';       
        p = [328, 121, 112,146, 0];
        opt = struct('numsample',300, 'condenssig',0.25, 'ff',1,...
                     'batchsize',5, 'affsig',[10,10,.01,.005,.00,.00]);
    
    otherwise;  error(['unknown title ' title]);
end
%%******Change 'title' to choose the sequence you wish to run******%%

%%***************************Data Path*****************************%%
dataPath = [ 'Data\' title '\'];
if ~isdir(['Result\' ,title])
    mkdir('Result\',title);
end

%%***************************Data Path*****************************%%