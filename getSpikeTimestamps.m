function [locs,dataWarped] = getSpikeTimestamps(data,Fs,sensitivity,onlyDowngoing)
% pre-process data: common mode average -> high pass -> artifact removal
% sensitivity: 0-100 (100 is REALLY sensitive)
% [ ]flag for only negative spikes?

% usage:
% sev=sev-cma;
% fdata=wavefilter(sev,6);
% fdataNA = artifactThresh(fdata,500);

showme = true;

% reduce sharpness (used for diff)
disp('Smoothing data...')
dataSmooth = smooth(data,Fs/5e3); 
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

% threshold knob
sensitivityLevels = linspace(std(dataWarped),max(dataWarped),100);

% get peaks of warped data
disp('Extracting peaks of warped data...')
[~,locs] = findpeaks(dataWarped,'MinPeakDistance',Fs/1000,...
    'MinPeakHeight',sensitivityLevels(sensitivity));

if(onlyDowngoing)
    locsDown = data(locs) < 0;
    locs = locs(locsDown);
    disp([num2str(round(length(locs)/length(locsDown)*100)),'% downgoing...']);
end
% save figure here?

if(showme)
    disp('Showing you...')
    nSamples = min([500 length(locs)]);
    locWindow = 20;
    someLocs = datasample(locs,nSamples);
    figure;
    for i=1:length(someLocs)
        plot(data(someLocs(i)-locWindow:someLocs(i)+locWindow));
        hold on;
    end
    title([num2str(nSamples),' samples']);
    xlabel('samples')
    ylabel('amplitude')
end