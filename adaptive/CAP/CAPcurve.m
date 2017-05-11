function S = CAPcurve(P, Freq, BurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, MaxNpres);
% CAPcurve - adaptive measurement of tonal CAP threshold for a range of
% frequencies
% Usage:
%   CAPcurve(P, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL,
%   StepSPL, DAchan, MaxNpres);

% Create dataset
DS = dataset(P.Experiment, P, [], P.GUIhandle, 'Dataset');

% Load circuit
dev = P.Experiment.Audio.Device;
Fsam = sys3loadCircuit('CAP', dev, 110); % Hard-coded 110 kHz, cf. THR_Geisler
sys3run(dev); % In fact still halted  until setting 'Run' to 1

% Set non-changing parameters
RampDur = 1; % Hard-coded 1 ms cos2 ramp
Nrep = 20; % N reps / decision
sys3setpar(Nrep, 'Npls', dev);
sys3setpar(BurstDur-RampDur, 'BurstDur', dev); % Falling edge starts when 'BurtsDur' is over
NonBurstDur = 3*BurstDur; % Save some margin for noise window
sys3setpar(NonBurstDur+RampDur, 'NonBurstDur', dev); % Falling edge starts when 'BurtsDur' is over and 'NonBurstDur' begins
sys3setpar(2*NonBurstDur, 'Timeout', dev); % Always stop recording when Timeout occurs (this is after playing Nrep tones)
TotalDur = BurstDur + NonBurstDur;

% Set starting SPL
dynStartSPL = StartSPL;

% Create plot
Thr = nan(size(Freq));
figure;
h = semilogx(Freq,Thr,'YDataSource','Thr');
xlabel('Freq [Hz]');
ylabel('SPL [dB]');
timestr = datestr(clock,30);

% Determine order
ifreqs = 1:numel(Freq);
if strcmpi(P.Order(1),'R')
    ifreqs = fliplr(ifreqs);    
end

% Calculate # SPLs per Freq
NbSPL = size(P.LinAmp,1)/size(P.Freq,1);

for ifreq=ifreqs,
    GUImessage(gcg, ['Measuring threshold at frequency ', num2str(Freq(ifreq))]);
    % STOP button action
    if MyFlag('CAPstop'),
        save(DS);
        break; % from loop
    end
    ic = (1+(ifreq-1)*NbSPL:ifreq*NbSPL)';
    % Get correct LinAmp and Attenuations
    SPL = P.SPLs;
    LinAmp = P.LinAmp(ic,:);
    Attenuation = P.Attenuations(ifreq,:);
    S(ifreq) = CAPrec(dev, P.Experiment, Freq(ifreq), Nrep, ...
        BurstDur, TotalDur, MinSPL, MaxSPL, dynStartSPL, StepSPL, DAchan, MaxNpres, ...
        SPL, Attenuation, LinAmp, P.ZScore, P.GUIhandle);
    if ~isnan(S(ifreq).Thr),
        dynStartSPL = S(ifreq).Thr - 2*StepSPL;
    end
    Thr(ifreq) = S(ifreq).Thr;
    % Attempt to force resetting the timing of play action
    sys3halt(dev); 
    sys3run(dev);
    % Refresh plot
    refreshdata(h,'caller') % Evaluate y in the function workspace
    drawnow
    % save data
    DS = addThr(DS,Thr);
    % keep old save format as backup
    save([folder(current(experiment)),'\CAP_',timestr,'.mat'],'S','-mat');
end

sys3halt(dev);
save(DS);

end
