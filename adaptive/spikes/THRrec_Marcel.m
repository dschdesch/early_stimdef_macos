function S = THRrec_Marcel(dev, EXP, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, SPL, Attenuations, LinAmp, GUI)
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
% New: attenuation
SetAttenuators(EXP, Attenuations);

% Construct amplitude history
iAmpHist = [];
SpikeDiffHist = [];
Thr = NaN;
dAmp = 2;
for i=1:MaxNpres
    % STOP button action
    disp(i);
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
    % Record Spikes
    NbSpikes = local_getNbSpikes(dev, iAmp, DAchan, LinAmpL, LinAmpR, BurstDur);
    % save log
    iAmpHist(end+1) = iAmp;
    SpikeDiffHist(end+1) = sign(SpikeCrit-NbSpikes);
    % Update SPL
    if (i > 1) && (SpikeDiffHist(i) ~= SpikeDiffHist(i-1)) % isrev
        NbCrossings = NbCrossings + 1;
        if (NbCrossings == 2)
            dAmp = 1;
        elseif (NbCrossings == 4)
            Thr = SPL(iAmp); % through!
            break;
        end
    end
    iAmp = iAmp + SpikeDiffHist(i)*dAmp;
end
sys3setpar(0, 'Run', dev); % stop playing

% return arg
AmpHist = SPL(iAmpHist);
ExpName = name(EXP);
S = CollectInStruct(ExpName, ToneFreq, MinSPL, MaxSPL, StartSPL, StepSPL, SPL, DAchan, SpikeCrit, '-', iAmpHist, AmpHist, Thr);

%=============================================================
function NbSpikes = local_getNbSpikes(dev, iAmp, DAchan, LinAmpL, LinAmpR, BurstDur)
if strcmpi(DAchan(1),'L')
    sys3setpar(LinAmpL(iAmp), 'ToneAmpL', dev);
    sys3setpar(0, 'ToneAmpR', dev);
elseif strcmpi(DAchan(1),'R')
    sys3setpar(LinAmpR(iAmp), 'ToneAmpR', dev);
    sys3setpar(0, 'ToneAmpL', dev);
elseif strcmpi(DAchan(1),'B')
    sys3setpar(LinAmpL(iAmp), 'ToneAmpL', dev);
    sys3setpar(LinAmpR(iAmp), 'ToneAmpR', dev);
end
sys3setpar(1, 'Run', dev);
pause((BurstDur+10)/1e3); % 10 is a safety margin
sys3setpar(0, 'Run', dev);
% Get spikes
NbSpikes = round(sys3getpar('NbSpikes', dev)); % make sure it's an integer
