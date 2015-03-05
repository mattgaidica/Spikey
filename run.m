fdatasegNA = data(1,1:1e5);
nplot = 5;

figure;
hs(1) = subplot(nplot,1,1);
plot(fdatasegNA);
title('fdatasegNA')

sm = 5;
fds = smooth(fdatasegNA,sm);
hs(2) = subplot(nplot,1,2);
plot(fds);
title('fds')

diffdata = diff(fds);
hs(3) = subplot(nplot,1,3);
plot(diffdata);
title('diffdata')

diffmult = diffdata.*(fds(1:end-1));
hs(4) = subplot(nplot,1,4);
plot(diffmult);
title('diffmult');

% this just makes the peak align with the original data
% sqrt gives more resolution to low amplitude data
diffdiffmult = sqrt(abs(diff(diffmult)));
hs(5) = subplot(nplot,1,5);
plot(normalize(diffdiffmult));
y_snle = snle(fdatasegNA,[1]);
hold on
y_snle(y_snle<0)=0;
plot(normalize(y_snle));
title('snle');

linkaxes(hs,'x')

% findpeaks(diffdiffmult,'MinPeakDistance',25,'MinPeakHeight',4*std(diffdiffmult),'Annotate','extents');
