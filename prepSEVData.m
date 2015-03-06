function data=prepSEVData(filenames,validMask,threshArtifacts)
for ii=1:length(filenames)
    if ~validMask(ii), continue, end
    disp(['Reading ',filenames{ii}]);
    [data(ii,:),header] = read_tdt_sev(filenames{ii});
    data(ii,:) = wavefilter(data(ii,:),6);
    data(ii,:) = artifactThresh(double(data(ii,:)),threshArtifacts);
end