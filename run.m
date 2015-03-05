fdataseg = wavefilter(sev(1:1e6)-sevCma(1:1e6),6);
fdataseg2 = wavefilter(sev(1:1e6)-sevCma2(1:1e6),6);
sm = 10;
fds = smooth(fdataseg2,sm);
fds2 = fds.^2;
rmsdata = sqrt(fds2);
diffdata = diff(fds);

nplot = 5;

figure;
hs(1) = subplot(nplot,1,1);
plot(wavefilter(sev(1:1e6),6));
hold on;
plot(fdataseg2,'r');
hold on;
plot(fdataseg,'m');
title('fdataseg')

hs(2) = subplot(nplot,1,2);
plot(fds);
title('fds')

hs(3) = subplot(nplot,1,3);
plot(diffdata);
title('diffdata')

diffmult = diffdata.*(fds(2:end));
hs(4) = subplot(nplot,1,4);
plot(diffmult);
title('diffdata.*(fds2(2:end))');

diffdiffmult = diff(smooth(diffmult)).^2;

hs(5) = subplot(nplot,1,5);
plot(diffdiffmult);
title('diff(smooth(diffmult)).^2');

linkaxes(hs,'x')

findpeaks(diffdiffmult,'MinPeakDistance',15,'MinPeakHeight',1e6,'Annotate','extents');
