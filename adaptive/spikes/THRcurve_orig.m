function S = THRcurve(EXP, Freq, BurstDur, NonBurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, SpikeDiffCrit, MaxNpres, GUI);
% THRcurve - adaptive measurement of tonal threshold for a range of
% frequencies
% Usage:
%   THRcurve(EXP, ToneFreq, BurstDur, NonBurstDur, MinSPL, MaxSPL, StartSPL,
%   StepSPL, DAchan, SpikeDiffCrit, MaxNpres, GUI);


% Load circuit
dev = EXP.Audio.Device;
Fsam = sys3loadCircuit('THR_Liberman', dev, 110);
sys3run(dev); % in fact still halted until setting 'Run' to 1
% set channel number
ChanNb = 2;
if strcmpi(DAchan(1),'L')
    ChanNb = 1;
end
sys3setpar(ChanNb, 'ChanNb', dev);
% testThr = nan;
% while isnan(testThr),
%     s = THRrec(dev, EXP, Freq(1), BurstDur, NonBurstDur, ...
%         MinSPL, MaxSPL, StartSPL, 3, DAchan, SpikeDiffCrit, 2*MaxNpres);
%     testThr = s.Thr;
% end
%s
dynStartSPL = StartSPL; %testThr;
% Create plot
Thr = nan(size(Freq));
h = semilogx(Freq,Thr,'YDataSource','Thr');
timestr = datestr(clock,30);

for ifreq=1:numel(Freq),
    sys3trig(1, dev); % reset buffers, etc
    S(ifreq) = THRrec(dev, EXP, Freq(ifreq), BurstDur, NonBurstDur, ...
        MinSPL, MaxSPL, dynStartSPL, StepSPL, DAchan, SpikeDiffCrit, MaxNpres, GUI);
    if ~isnan(S(ifreq).Thr),
        dynStartSPL = S(ifreq).Thr;
    end
    Thr(ifreq) = S(ifreq).Thr;
    % Attempt to force resetting the timing of play action
    sys3halt(dev); 
    sys3run(dev);
    % Refresh plot
    refreshdata(h,'caller') % Evaluate y in the function workspace
    drawnow
    % save data
    save([folder(current(experiment)),'\THR_',timestr,'.mat'],'S','-mat');
    %% STOP button action
    if MyFlag('THRstop'),
         break; % from loop
    end
end
sys3halt(dev);