function S = THRrec_Liberman(dev, EXP, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, SPL, Attenuations, LinAmp, GUI,ISI)
% THRrec - adaptive measurement of tonal threshold for one frequency
% Usage:
%   THRrec(dev, EXP, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, MaxNpres);
%   Helper function of THRcurve.
%   THR Circuit must be loaded at call time.
 
CI = sys3CircuitInfo(dev);
Fsam = CI.Fsam;

NSPL = length(SPL);

[LinAmpL, LinAmpR] = deal([]);
% extract linear amplitudes
if strcmpi(DAchan(1),'L') || strcmpi(DAchan(1),'B')
    LinAmpL = LinAmp(:,1);
end
if strcmpi(DAchan(1),'R') || strcmpi(DAchan(1),'B')
    LinAmpR = LinAmp(:,end);
end
% Set StartSPL
[dum, iAmp] = min(abs(SPL-StartSPL));

% freq
sys3setpar(ToneFreq, 'ToneFreq', dev);


% Construct amplitude history
iAmpHist = [];
Thr = NaN;
for i=1:MaxNpres
    % STOP button action
    if MyFlag('THRstop'),
         break; % from loop
    end
    % Check for iAmp out of bounds
    if (iAmp < 1)
        Thr = SPL(1);
        break;
    elseif (iAmp > NSPL)
        Thr = SPL(NSPL);
        break;
    end
    % New: attenuation
    SetAttenuators(EXP, Attenuations(iAmp));
    iAmpHist(end+1) = iAmp;
    % Check if conditions have been met yet
    [isReady, Thr] = local_thr(iAmpHist, SPL);
    if isReady
        break;
    end
    % Record Spikes
    [toneEvokedSpikes postToneSpikes] = local_getNbSpikes(dev, iAmp, DAchan, LinAmpL, LinAmpR, BurstDur,ISI);
    %postToneSpikes = local_getNbSpikes(dev, 0, DAchan, LinAmpL, LinAmpR, BurstDur,ISI);
    toneEvokedSpikes,postToneSpikes,SpikeCrit
    % Compare difference and adjust accordingly
    SpikeDiff = toneEvokedSpikes - postToneSpikes;
    if SpikeDiff <= SpikeCrit
        iAmp = iAmp + 2;
    else
        iAmp = iAmp - 1;
    end
end
sys3setpar(0, 'Run', dev); % stop playing

% return arg
AmpHist = SPL(iAmpHist);
ExpName = name(EXP);
S = CollectInStruct(ExpName, ToneFreq, MinSPL, MaxSPL, StartSPL, StepSPL, SPL, DAchan, SpikeCrit, '-', iAmpHist, AmpHist, Thr);

%=============================================================
function [toneEvokedSpikes postToneSpikes] = local_getNbSpikes(dev, iAmp, DAchan, LinAmpL, LinAmpR, BurstDur,ISI)
% Set the burst duration and the non-burst duration
sys3setpar(BurstDur, 'BurstDur', dev);
sys3setpar(ISI - BurstDur, 'NonBurstDur', dev);

% Determine which channels should be used and set their amplitude 
if iAmp == 0
    sys3setpar(0, 'ToneAmpL', dev);
    sys3setpar(0, 'ToneAmpR', dev);
elseif strcmpi(DAchan(1),'L')
    sys3setpar(LinAmpL(iAmp), 'ToneAmpL', dev);
    sys3setpar(0, 'ToneAmpR', dev);
elseif strcmpi(DAchan(1),'R')
    sys3setpar(LinAmpR(iAmp), 'ToneAmpR', dev);
    sys3setpar(0, 'ToneAmpL', dev);
elseif strcmpi(DAchan(1),'B')
    sys3setpar(LinAmpL(iAmp), 'ToneAmpL', dev);
    sys3setpar(LinAmpR(iAmp), 'ToneAmpR', dev);
end

% Run the DSP Program and wait a bit longer then the ISI 
sys3setpar(1, 'Run', dev);
pause((10+ISI)/1e3); 
sys3setpar(0, 'Run', dev);



% Get spikes
toneEvokedSpikes = round(sys3getpar('NbSpikes', dev)); % make sure it's an integer
postToneSpikes = round(sys3getpar('NbPostSpikes', dev));

function [isReady, Thr] = local_thr(iAmp, SPL)
% criterion
Thr = NaN;
isReady = 0;
Namp = numel(iAmp);
for i=4:Namp
    % Check 
    % (1) that the tone level at the current trial is the same as 
    % that three trials previously; and 
    % (2) that the current level was reached by lowering the tone level 
    % by one step.
    isReady = (iAmp(i-1) > iAmp(i)) && (iAmp(i-3) == iAmp(i));
    if isReady,
        Thr = SPL(iAmp(i));
        break;
    end
end
