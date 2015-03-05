function locs = getSpikeTimestamps(data,Fs,sensitivity,onlyDowngoing)
% pre-process data: common mode average -> high pass -> artifact removal
% sensitivity: 0-100 (100 is REALLY sensitive)
% data = nCh x nSamples

% usage:
% sev=sev-cma;
% fdata=wavefilter(sev,6);
% fdataNA = artifactThresh(fdata,500);

showme = true;

% minus 2 because 2 diffs are used below
sumDataWarped = zeros(1,size(data,2)-2);
for i=1:size(data,1)
    disp(['Processing data set ',num2str(i),'...']);
    % reduce sharpness (used for diff)
    disp('Smoothing data...')
    dataSmooth = smooth(data(i,:),Fs/5e3);
    % get rate of change
    disp('Diff of data...')
    dataDiffSmooth = diff(dataSmooth);
    % use diff like a gain on the smooth data
    disp('Applying diff as gain...')
    dataMultDiffSmooth = dataSmooth(1:end-1).*dataDiffSmooth;
    % warp this new data so peaks align with original data, use sqrt to enhance
    % low amplitudes
    disp('Warping data...')
    dataWarped = sqrt(abs(diff(dataMultDiffSmooth)));
    % remove offset, zero-centered
    dataWarped = dataWarped - mean(dataWarped);
    sumDataWarped = sumDataWarped + dataWarped';
    clear('dataDiffSmooth','dataMultDiffSmooth','dataSmooth','dataWarped');
end
% threshold knob
sensitivityLevels = linspace(std(sumDataWarped),max(sumDataWarped),100);
disp(['raw sensitivity = ',num2str(sensitivityLevels(sensitivity))]);
% get peaks of warped data
disp('Extracting peaks of summed warped data...')
[~,locs] = findpeaks(sumDataWarped,'MinPeakDistance',Fs/1000,...
    'MinPeakHeight',sensitivityLevels(sensitivity));

% this forces all lines to be negative for extracts, not sure that's a good
% way to think about this feature
if(onlyDowngoing)
    locsDown = max(data(:,locs)) < 0;
    locs = locs(locsDown);
    disp([num2str(round(length(locs)/length(locsDown)*100)),'% downgoing...']);
end
% save figure here?

if(showme)
    disp('Showing you...')
    nSamples = min([400 length(locs)]);
    locWindow = 20;
    someLocs = datasample(locs,nSamples); % random samples
    for i=1:size(data,1)
        figure;
        for j=1:length(someLocs)
            plot(data(i,someLocs(j)-locWindow:someLocs(j)+locWindow));
            hold on;
        end
        title(['data row',num2str(i),' - ',num2str(nSamples),' samples']);
        xlabel('samples')
        ylabel('amplitude')
    end
end
clear('data');