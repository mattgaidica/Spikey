function [data,Fs]=prepSEVData(filenames,goodWires,threshArtifacts)
    for ii=1:length(filenames)
        if ~goodWires(ii), continue, end
        disp(['Reading ',filenames{ii}]);
        [data(ii,:),header] = read_tdt_sev(filenames{ii});
        data(ii,:) = wavefilter(data(ii,:),6);
        data(ii,:) = artifactThresh(double(data(ii,:)),threshArtifacts);
    end
    Fs = header.Fs;
end