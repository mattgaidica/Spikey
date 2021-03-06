function y_snle = spikeSnle(y,goodWires,Fs)
%
% usage: y_snle = snle( y, varargin )
%
% INPUTS:
%   y - input data, m x n where m is the number of wires and n is the
%       number of points
%   goodWires - which wires have good data for which it is worth
%       calculating the smoothed non-linear energy. This is a vector with a
%       true value for each good wire, and a false/zero value for each bad
%       wire
%
% OUTPUTS:
%   y_snle - the smoothed nonlinear energy of the input data
%
% From Mukhopadyay and Ray, "A New Interpretation of Nonlinear
%   Energy Operator and Its Efficacy is Spike Detection",
%   IEEE Trans Biomed Eng, 1998

windowSize = round(Fs/2400);
snle_T = round(Fs/8000);
windowFunct = 'hanning';
numSamps = size(y, 2);

% make sure the window length is odd so there is no phase shift in the
% filtered data
if round(windowSize / 2) == windowSize / 2
    windowSize = windowSize + 1;
end
phaseShift = ceil(windowSize / 2);

% can add more options for the window later; see option in the signal
% processing toolbox
switch lower(windowFunct)
    case 'hanning',
        w = hann(windowSize);
end

y_snle = y;
L = length(y)-(2*snle_T);
% T variable added to extend window, 20150201 Matt Gaidica
y_snle(:,1+snle_T:end-snle_T) = y(:,1+snle_T:end-snle_T).^2 - y(:,1:L) .* y(:,(end-L+1):end);
% old code below
%y_snle(:, 2 : end-1) = y(:, 2 : end-1).^2 - y(:, 1 : end-2) .* y(:, 3 : end);

for iRow = 1 : size(y, 1)
    if goodWires(iRow)
        temp = conv(y_snle(iRow, :), w);
        y_snle(iRow, :) = temp(phaseShift : phaseShift + numSamps - 1);
    end
end