function tmpl = update_tracker(tmpl, param, opt)
%
oldData = tmpl.mean(:);
newData = param.wimg(:);
%
updateVector = ones(size(oldData));
distt=[];
%
for ii = 1:opt.blockNum(1)
    for jj = 1:opt.blockNum(2)
        oldDataTemp = oldData(opt.blockIndex{ii,jj});
        newDataTemp = newData(opt.blockIndex{ii,jj});
        oldDataTemp = oldDataTemp./norm(oldDataTemp);
        newDataTemp = newDataTemp./norm(newDataTemp);
        temp = norm(oldDataTemp-newDataTemp);
        distt=[distt,temp];
        if  temp < opt.updateTr
            updateVector(opt.blockIndex{ii,jj}) = opt.updateRate;
        end
    end
end
%
updateMatrix = reshape(updateVector, size(tmpl.mean));
%
tmpl.mean = updateMatrix.*tmpl.mean + (1-updateMatrix).*param.wimg;
% distt