function createPLXFiles(nasPath)
    % see exportSessionConf.m for details, loads sessionConf variable
    [f,p] = uigetfile({'*.mat'},'Select configuration file...');
    load(fullfile(p,f));
    
   spikeParameterString = sprintf('WL%02d_PL%02d_DT%02d', sessionConf.waveLength,...
       sessionConf.peakLoc, sessionConf.deadTime);


    sessionPath = fullfile(nasPath, sessionConf.ratID,...
        [sessionConf.ratID,'-rawdata'],sessionConf.sessionName,sessionConf.sessionName);
    processedSessionPath = fullfile(nasPath,sessionConf.ratID,[sessionConf.ratID,'-processed']);
    % create if doesn't exist

    validTetrodes = find(any(sessionConf.validMasks,2).*sessionConf.chMap(:,1));
    [chFileMap,fullSevFiles] = getChFileMap(sessionPath);
    
    for ii=length(validTetrodes)
        tetrodeChannels = sessionConf.chMap(validTetrodes(ii),2:end);
        tetrodeName = sessionConf.tetrodeNames{validTetrodes(ii)};
        tetrodeValidMask = sessionConf.validMasks(validTetrodes(ii),:);
        
        tetrodeFilenames = fullSevFiles(tetrodeChannels);
        data = prepSEVData(tetrodeFilenames,tetrodeValidMask,500);
        locs = getSpikeLocations(data,tetrodeValidMask,sessionConf.Fs,'negative');
        
        PLXfn = fullfile(processedSessionPath,[sessionConf.sessionName,...
            '_',tetrodeName,'_',spikeParameterString,'.plx']);
        PLXid = makePLXInfo(PLXfn,sessionConf,tetrodeChannels,length(data));
        makePLXChannelHeader(PLXid,sessionConf,tetrodeChannels,tetrodeName);
        
        disp('Extracing waveforms...');
        waveforms = extractWaveforms(data,locs,sessionConf.peakLoc,...
            sessionConf.waveLength);
        disp('Writing waveforms to PLX file...');
        writePLXdatablock(PLXid,waveforms,locs);
    end
end

function [chFileMap,fullSevFiles] = getChFileMap(sessionPath)
    sevFiles = dir(fullfile(sessionPath,'*.sev'));
    for ii=1:length(sevFiles)
        chFileMap(ii) = getSEVChFromFilename(sevFiles(ii).name);
        fullSevFiles{ii} = fullfile(sessionPath,sevFiles(ii).name);
    end
    fullSevFiles(chFileMap) = fullSevFiles; %remap so they are in order
end

function ch = getSEVChFromFilename(name)
    C = strsplit(name,'_');
    C = strsplit(C{end},'.'); %C{1} = chXX
    ch = str2num(C{1}(3:end));
end