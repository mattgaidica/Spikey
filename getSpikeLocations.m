function locs = getSpikeLocations(data,validMask,Fs,nStd,onlyGoing)
% pre-process data: high pass -> artifact removal
% data = nCh x nSamples
% [ ] save figures? Configs?

showme = true;

disp('Calculating SNLE data...')
y_snle = spikeSnle(data,validMask,Fs);
disp('Extracting peaks of summed SNLE data...')
minpeakdist = Fs/1000;
minpeakh = nStd * mean(std(y_snle,[],2)); %3 is good!
locs = peakseek(sum(y_snle),minpeakdist,minpeakh);

% this forces all lines to be negative for extracts, not sure that's a good
% way to think about this feature
if(onlyGoing)
    if(onlyGoing == 1) 
        locsGoing = min(data(:,locs)) > 0; %positive spikes
    else 
        locsGoing = max(data(:,locs)) < 0; %negative spikes
    end
    locs = locs(locsGoing);
    disp([num2str(round(length(locs)/length(locsGoing)*100)),'% spikes going your way...']);
end

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