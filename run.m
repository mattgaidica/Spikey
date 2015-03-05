sev_ch13HPNA_seg = sev_ch13HPNA(1:1e6);
nplot = 3;

figure;
hs(1) = subplot(nplot,1,1);
plot(sev_ch13HPNA_seg);
title('fdatasegNA')

hs(2) = subplot(nplot,1,2);
y_snle = snle(sev_ch13HPNA_seg,[1],header.Fs);
plot(y_snle);
title('snle');

hs(3) = subplot(nplot,1,3);
findpeaks(y_snle,'MinPeakDistance',25,'MinPeakHeight',3*std(y_snle),'Annotate','extents');

linkaxes(hs,'x')