function writeNex_wf_ts( fileName, waveIdx, ts )
%
% usage: writeNex_wf_ts( nexName, waveIdx, ts )
%
% INPUTS:
%   fileName - name of the .nex file
%   waveIdx - index(es) of the waveform variable(s) to write into the file
%   ts - the timestamps, in samples
%
% this function writes timestamps for waveforms into a .nex file. This is
% useful if waveforms are pulled out in blocks from a .hsd file, so that
% the .nex file can also be written in blocks, so all of the waveforms do
% not need to be stored in memory at the same time.

% make sure ts is a column vector
if length(ts) > size(ts, 1)
    ts = ts';
end

% read in the .nex header so we can figure out where in the file to write
% the timestamps

nexFile = [];

fid = fopen(fileName, 'r+');
if (fid == -1)
   error 'Unable to open file'
end

magic = fread(fid, 1, 'int32');
if magic ~= 827868494
    error 'The file is not a valid .nex file'
end
nexFile.version = fread(fid, 1, 'int32');
nexFile.comment = deblank(char(fread(fid, 256, 'char')'));
nexFile.freq = fread(fid, 1, 'double');
nexFile.tbeg = fread(fid, 1, 'int32')./nexFile.freq;
nexFile.tend = fread(fid, 1, 'int32')./nexFile.freq;
nvar = fread(fid, 1, 'int32');

% skip location of next header and padding
fseek(fid, 260, 'cof');

neuronCount = 0;
eventCount = 0;
intervalCount = 0;
waveCount = 0;
popCount = 0;
contCount = 0;
markerCount = 0;

% figure out which variables are waveforms
for i=1:nvar
    type = fread(fid, 1, 'int32');
    varVersion = fread(fid, 1, 'int32');
	name = deblank(char(fread(fid, 64, 'char')'));
    offset = fread(fid, 1, 'int32');
	n = fread(fid, 1, 'int32');
    wireNumber = fread(fid, 1, 'int32');
	unitNumber = fread(fid, 1, 'int32');
	gain = fread(fid, 1, 'int32');
	filter = fread(fid, 1, 'int32');
	xPos = fread(fid, 1, 'double');
	yPos = fread(fid, 1, 'double');
	WFrequency = fread(fid, 1, 'double'); % wf sampling fr.
	ADtoMV  = fread(fid, 1, 'double'); % coeff to convert from AD values to Millivolts.
	NPointsWave = fread(fid, 1, 'int32'); % number of points in each wave
	NMarkers = fread(fid, 1, 'int32'); % how many values are associated with each marker
	MarkerLength = fread(fid, 1, 'int32'); % how many characters are in each marker value
	MVOfffset = fread(fid, 1, 'double'); % coeff to shift AD values in Millivolts: mv = raw*ADtoMV+MVOfffset
    filePosition = ftell(fid);
    
    if type == 3    % waveform data type
        waveCount = waveCount + 1;
        waveOffset(waveCount) = offset;
    end
    
    fseek(fid, filePosition, 'bof');
    fread(fid, 60, 'char');
end

% write the vector of timestamps into the .nex file for each waveform 
% contained in waveIdx
for iWave = 1 : length(waveIdx)
    
    if fseek(fid, waveOffset(waveIdx(iWave)), 'bof') == -1
        % the file doesn't extend out far enough
        fseek(fid, 0, 'eof');
        finfo     = dir(fileName);
        padLength = waveOffset(waveIdx(iWave)) - finfo.bytes;
        zeropad   = uint8(zeros(padLength, 1));
        
        fwrite(fid, zeropad, 'uint8');
    end
    fseek(fid, waveOffset(waveIdx(iWave)), 'bof');
    fwrite(fid, ts, 'int32');
    
end

fclose(fid);