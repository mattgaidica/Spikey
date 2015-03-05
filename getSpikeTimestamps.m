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
dataSmooth = smooth(data,Fs/5e3);
% get rate of change
dataDiffSmooth = diff(dataSmooth);
% use diff like a gain on the smooth data
dataMultDiffSmooth = dataSmooth(1:end-1).*dataDiffSmooth;
% warp this new data so peaks align with original data, use sqrt to enhance
% low amplitudes
dataWarped = sqrt(abs(diff(dataMultDiffSmooth)));
% get peaks of warped data
sensitivityLevels = linspace(std(dataWarped),max(dataWarped),100);

[~,locs] = findpeaks(dataWarped,'MinPeakDistance',Fs/1000,...
    'MinPeakHeight',sensitivityLevels(sensitivity));

if(onlyDowngoing)
    locsDown = data(locs) < 0;
    locs = locs(locsDown);
    disp([num2str(round(length(locs)/length(locsDown)*100)),'% downgoing...']);
end
% save figure here?

if(showme)
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