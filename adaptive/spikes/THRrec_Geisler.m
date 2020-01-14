function S = THRrec_Geisler(dev, EXP, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, SpikeCrit, MaxNpres, SPL, Attenuations, LinAmp, GUI,ISI)
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
SpikeDiffHist = [];
Thr = NaN;

is=[];
iamps=[];

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
    pause(0.005);
    % Record Spikes
    NbSpikes = local_getNbSpikes(dev, iAmp, DAchan, LinAmpL, LinAmpR, BurstDur,ISI);
    % save log
    iAmpHist(end+1) = iAmp;
    SpikeDiffHist(end+1) = sign(SpikeCrit - NbSpikes);
    NbSpikes,SpikeCrit,SpikeDiffHist(i)
    if i > 1
        if SpikeDiffHist(i) == 0
            NbCrossings = NbCrossings + 1;
            if (NbCrossings > 2) && (SpikeDiffHist(i-1) == 0);
                Thr = SPL(iAmp);
                break;
            else
                % try this SPL again with same amplitude
            end
        elseif SpikeDiffHist(i) ~= SpikeDiffHist(i-1);
            NbCrossings = NbCrossings + 1;
            if (NbCrossings > 2)
                Thr = SPL(iAmp) + SpikeDiffHist(i)*StepSPL/2;
                break;
            else
                iAmp = iAmp + SpikeDiffHist(i);
            end
        else
            NbCrossings = 0;
            iAmp = iAmp + SpikeDiffHist(i);
        end
    else
        NbCrossings = 0;
        iAmp = iAmp + SpikeDiffHist(i);
    end
%     iAmp
%     figure(2)
%     is = [is,i];
%     iamps = [iamps,iAmp];
%     plot(is,iamps)
%     title([SpikeCrit,NbSpikes])
    
end
sys3setpar(0, 'Run', dev); % stop playing

% return arg
AmpHist = SPL(iAmpHist);
ExpName = name(EXP);
S = CollectInStruct(ExpName, ToneFreq, MinSPL, MaxSPL, StartSPL, StepSPL, SPL, DAchan, SpikeCrit, '-', iAmpHist, AmpHist, Thr);

%=============================================================
function NbSpikes = local_getNbSpikes(dev, iAmp, DAchan, LinAmpL, LinAmpR, BurstDur,ISI)
sys3setpar(BurstDur, 'BurstDur', dev);
sys3setpar(ISI - BurstDur, 'NonBurstDur', dev);
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
pause((10+ISI)/1e3); % 10 is a safety margin
sys3setpar(0, 'Run', dev);
% Get spikes
NbSpikes = round(sys3getpar('NbSpikes', dev)); % make sure it's an integer
