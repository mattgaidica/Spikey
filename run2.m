dataDir = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0036/R0036-rawdata/R0036_20150225a/R0036_20150225a';
sevFiles = dir(fullfile(dataDir,'*.sev'));

sevCma2 = [];
for i=1:64
    disp(sevFiles(i).name);
    [sev, header] = read_tdt_sev(fullfile(dataDir,sevFiles(i).name));
    if(i==1)
        sevCma2 = sev;
    else
        sevCma2 = mean([sevCma2;sev]);
    end
end