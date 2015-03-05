function data=artifactThresh(data,thresh)
    % finds peaks above thresh
    [~,locs] = findpeaks(abs(data),'MinPeakHeight',thresh);
    disp([num2str(length(locs)),' artifacts found...']);
    % create indexes of quiet locations in data
    zeroIdxs = find(abs(data) < 2);
    for i=1:length(locs)
        if(mod(i,100)==0)
            disp([num2str(i),' artifacts cured...']);
        end
        % get quiet locations before/after artifact peak
        zeroBefore = zeroIdxs < locs(i);
        zeroAfter = zeroIdxs > locs(i);
        % apply zeros to the entire area that the artifact contains
        if(~isempty(zeroBefore))
            data(max(zeroIdxs(zeroBefore)):locs(i)) = 0;
        end
        if(~isempty(zeroAfter))
            data(locs(i):min(zeroIdxs(zeroAfter))) = 0;
        end
    end
end