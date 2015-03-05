function data=artifactThresh(data,thresh)
    [~,locs] = findpeaks(abs(data),'MinPeakHeight',thresh,'Annotate','extents');
    zeroIdxs = find(abs(data) < 10);
    for i=1:length(locs)
        zeroBeforeIdx = find(zeroIdxs < locs(i),1,'last');
        zeroAfterIdx = find(zeroIdxs > locs(i),1,'first');
        if(~isempty(zeroBeforeIdx))
            data(zeroIdxs(zeroBeforeIdx):locs(i)) = 0;
        end
        if(~isempty(zeroAfterIdx))
            data(locs(i):zeroIdxs(zeroAfterIdx)) = 0;
        end
    end
end