function S = CAPrec(dev, EXP, ToneFreq, Nrep, BurstDur, TotalDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, MaxNpres, SPL, Attenuations, LinAmp, ZScore, GUI)
% CAPrec - adaptive measurement of tonal threshold for one frequency
% Usage:
%   CAPrec(dev, EXP, ToneFreq, BurstDur, MinSPL, MaxSPL, StartSPL, StepSPL, DAchan, MaxNpres);
%   Helper function of CAPcurve.
%   CAP (THR_CAP.rcx) Circuit must be loaded at call time.
 
CI = sys3circuitinfo(dev);
Fsam = CI.Fsam;

NSPL = length(SPL);

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

iAmpHist = [];
CapDiffHist = [];
Thr = NaN;
for i=1:MaxNpres
    % Check for iAmp out of bounds
    if (iAmp < 1)
        Thr = SPL(1);
        break;
    elseif (iAmp > NSPL)
        Thr = SPL(NSPL);
        break;
    end
    
    % Record CAP
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
    
    %SetAttenuators(EXP, Attenuations(iAmp));
    
    % Polarity = +1
    % sys3setpar(0,'TonePhase',dev); % This doesn't seem to work
    
    for pol = 1:2
    
        sys3trig(1,dev);
        sys3setpar(1,'Run',dev);
        while ~sys3getpar('Stop',dev)
            pause(BurstDur*1e-3); % ms --> s
        end
        sys3setpar(0, 'Run', dev);
    
        % Get recordings
        Nsam = sys3getpar('NsamStored',dev);
        R{pol} = sys3read('RecordBuf', Nsam, dev);
        
        if pol > 1
            break;
        end
    
        % Polarity = -1
	
	%{
		by Abel 4/12	
		- probleem omgekeerde polariteit in CAP thr:
			~ eigenlijk moet het een som zijn van de stim in + en - polariteit
			~ het omdraaien van de polariteit werkt nog niet (Jeroen had al geprobeerd met onderstaande lijn (%sys3setpar(180,'TonePhase',dev) --> 180° draaien) maar werkt niet. Moet opnieuw getest worden  

	%}

        %sys3setpar(180,'TonePhase',dev); % This doesn't seem to work
        sys3setpar(-sys3getpar('ToneAmpL', dev), 'ToneAmpL', dev);
        sys3setpar(-sys3getpar('ToneAmpR', dev), 'ToneAmpR', dev);

    end
    
    % Get S/N ratio
    Nrec = max(cellfun(@numel, R));
    Rec = [R{1} zeros(1,Nrec-numel(R{1})); R{2} zeros(1,Nrec-numel(R{2}))];
    [S,N] = local_get_signal_to_noise(Rec,Nrep,BurstDur,TotalDur,Fsam); % get signal and noise rms in predefined windows

    % save log
    iAmpHist(end+1) = iAmp;
    % Is this a correct criterion??? For now, it is.
    CapDiffHist(end+1) = sign(ZScore*N-S);

    if i > 1 % Compare with previous CapDiff
        if CapDiffHist(i) == 0 % Exact!
            NbCrossings = NbCrossings + 1;
            % Try this SPL again, so don't change iAmp
            % Moreover, ...
            if (NbCrossings > 2) && (CapDiffHist(i-1) == 0);
                Thr = SPL(iAmp);
                break;   
            end
        elseif CapDiffHist(i) ~= CapDiffHist(i-1); % Oscillating
            NbCrossings = NbCrossings + 1;
            if (NbCrossings > 2)
                Thr = SPL(iAmp) + CapDiffHist(i)*StepSPL/2; % Thr is located in between two SPL values
                break;
            else
                iAmp = iAmp + CapDiffHist(i); % Increase or decrease SPL 
            end
        else % Continue increasing or decreaing SPL
            NbCrossings = 0;
            iAmp = iAmp + CapDiffHist(i);
        end
    else % No comparison with previous CapDiffs possible; increase or decrease SPL
        NbCrossings = 0;
        iAmp = iAmp + CapDiffHist(i);
    end
    

    %% STOP button action
    if MyFlag('CAPstop'),
         break; % from loop
    end
end
sys3setpar(0, 'Run', dev); % stop playing

% return arg
AmpHist = SPL(iAmpHist);
ExpName = name(EXP);
S = collectInStruct(ExpName, ToneFreq, MinSPL, MaxSPL, StartSPL, StepSPL, SPL, DAchan, ZScore, '-', iAmpHist, AmpHist, Thr);


function [S,N] = local_get_signal_to_noise(Rec,Nrep,BurstDur,TotalDur,Fsam)
Nsam = round(TotalDur*Fsam); % # samples for one rep; ms*kHz
Nsig = round(BurstDur*Fsam); % Estimate for # samples for one CAP; also ms*kHz
% Get rid of DC on dev; 
% start by defining a save noise window
SigWin = 1:Nsig;
NoiseWin = 2*Nsig+1:3*Nsig;
Rec = Rec - mean(sum(Rec(:,NoiseWin))./2);
% Extract the signal and noise window data and take ensemble average
offset = reshape(repmat((0:Nrep-1)*Nsam,[Nsig 1]),1,[]);
Signal = sum(Rec(:,offset+repmat(SigWin,[1 Nrep])));
Signal = sum((reshape(Signal,[],Nrep)),2)./(2*Nrep);
Noise = sum(Rec(:,offset+repmat(NoiseWin,[1 Nrep])));
Noise = sum((reshape(Noise,[],Nrep)),2)./(2*Nrep);
% Calculate rms
S = rms(Signal);
N = rms(Noise);
