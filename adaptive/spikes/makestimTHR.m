function P2 = makestimTHR(P)

P2 = []; % a premature return will result in []
if isempty(P), return; end

figh = P.handle.GUIfig;
EXP = P.Experiment;

if isfield(P,'RecCustSR')
    if isempty(P.CustSR),
        Mess = {'Please fill in the Custom SR field to use this function'};
        GUImessage(figh, Mess, 'error', {'CustSR'});
        return;
    end
end 

% P.Freq is and P.SPL are used for calculating waveforms.
% P.Fcar and P.SPL are used for representation.

% Carrier frequency
P.Freq = EvalFrequencyStepper(figh, '', P); 
if isempty(P.Freq), return; end
    
% % Take care of presentation order
% if strcmpi(P.Order(1),'R')
%     P.Freq = flipud(P.Freq);
% end

% SPL
P.SPL=EvalSPLstepper(figh, '', P); 
if isempty(P.SPL), return; end

% % Check validity of BeginSPL
if mod(P.BeginSPL - P.StartSPL, P.StepSPL) ~= 0, return; end

% % Levels and active channels (must be called *after* adding the baseline waveforms)
% [mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
% okay=evalSPLpanel(figh,P, mxSPL, P.Fcar);
% if ~okay, return; end

% % amplitudes -> replace by evalStepper?
% NSPL = 1+round((P.EndSPL-P.StartSPL)/P.StepSPL);
% SPL = linspace(P.StartSPL, P.EndSPL, NSPL);

% P.BurstDur = 100;
%P.ISI = P.BurstDur;
P.FreqTolMode = 'exact';
[P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModTheta, ...
    P.OnsetDelay, P.RiseDur, P.FallDur, P.WavePhase, ...
    P.FineITD, P.GateITD, P.ModITD] = deal(0);

% mix Freq & SPL sweeps; # conditions = # Freqs times # SPLs. By
% convention, SPL is updated faster. 
[dum1, dum2, P.Ncond_XY] = MixSweeps(P.SPL, P.Freq);
NFreq = P.Ncond_XY(2);
NSPL = P.Ncond_XY(1);

% Calculate all required # Freqs times # SPLs numerical amplitudes
P.Attenuations = deal(nan+zeros(NFreq,size(P.SPL,2)));
P.LinAmp = deal(nan+zeros(prod([NFreq NSPL]),size(P.SPL,2)));
[P.Attenuations, P.LinAmp] = channelSelect(P.DAC(1),P.Attenuations, P.LinAmp);

% Get right numerical amplitudes and attenuation settings per Freq
for ifreq=1:NFreq;
    
    ic = (1+(ifreq-1)*NSPL:ifreq*NSPL)';
    
    % Calibrate for Freq(ifreq)
    Fcar = P.Freq(ifreq);
    SPL = P.SPL;
    Fsam = 111607;% Fsam = sampleRate(Fcar, EXP);
    
    if strcmpi(P.DAC(1),'L') || strcmpi(P.DAC(1),'B')
        DLL = calibrate(EXP, Fsam, 'L', Fcar);
        Amp = dB2A(SPL)*sqrt(2)*dB2A(DLL);
        % Get attenuation settings
        [dum, Atten] = local_maxSPL(SPL,Amp,EXP);
        P.Attenuations(ic,1) = Atten.AnaAtten;
        P.LinAmp(ic,1) = Amp.*Atten.NumScale;
    end
    
    if strcmpi(P.DAC(1),'R') || strcmpi(P.DAC(1),'B')
        DLR = calibrate(EXP, Fsam, 'R', Fcar);
        Amp = dB2A(SPL)*sqrt(2)*dB2A(DLR);
        % Get attenuation settings
        [dum, Atten] = local_maxSPL(SPL,Amp,EXP);
        P.Attenuations(ic,1) = Atten.AnaAtten;
        P.LinAmp(ic,1) = Amp.*Atten.NumScale;
    end
    
end

% Representation
P.SPLs = P.SPL;
SPL=P.StartSPL;%evalSPLstepper(figh, '', P); DUMMY TO AVOID EXCESSIVE TIME USE
if isempty(SPL), return; end
[P.SPL, P.Fcar, P.Ncond_XY] = MixSweeps(SPL, P.Freq);
P.Nrep = 1;
P = toneStim(P);

P.RSeed = 0;
% P.Slowest = 'Fcar';
% P.Nextslow = 'SPL';
% P.Fastest = 'Rep';
P.Xorder = P.Order;
% P.Yorder = 'Forward';
P.Xname = 'Fcar';
% P.Yname = 'SPL';
P.Grouping = 'by condition';
P.Baseline = 0;
P.ITD = 0;
P.ITDtype = 'ongoing';
P.StimType = 'THR';
% P.Presentation.X.PlotVal = P.Fcar;
% P.Presentation.X.ParUnit = P.StepFreqUnit;
% P.Presentation.Nrep = 1;
% P.Presentation.Ncond = size(P.Fcar,1);
% P.Presentation.PresDur = P.BurstDur;
% 
P = sortConditions(P, 'Fcar', 'Carrier Intensity', ...
     'Hz', P.StepFreqUnit);
% 'TESTING MAKEDTIMFS'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% everything okay: return P
P2=P;

function [mxSPL, Atten] = local_maxSPL(SPLs,Amp,EXP)
DACmax = EXP.AudioMaxAbsDA;
mxSPL = nan+zeros(size(SPLs)); % correct size, all nans
for ii=1:numel(SPLs),
    % Find out how much waveforms can be boosted w/o exceeding the
    % max magnitude DACmax tolerated by the DAC
    mxSPL(ii) = SPLs(ii) + A2dB(DACmax/Amp(ii)) - 0.1;
end

AnaAtten = 0;
% Numerical amplification toward the ceiling is often possible as 
% long as it can be compensated by analog attenuation. Be aware that 
% the analog attenuator cannot be set during stimulus delivery. So the 
% extra gain must be applied to all stimuli in a given DAC channel.
Gain = mxSPL - SPLs; % max along first dim, i.e. per channel=column
AnaAtten = Gain; % compensate the gain

% If there is enough clearance, use the preferred minimum numerical 
% attenuation at the cost of analog attenution. This may help reduce
% the amount of distortion occurring at high DAC output Voltages.
ExtraNumAtten = min(AnaAtten, EXP.PreferredNumAtten);
AnaAtten = AnaAtten - ExtraNumAtten;
Gain = Gain - SameSize(ExtraNumAtten, Gain);

% If the analog attenuation exceeds the range of the attenuator, replace
% part of it by numerical attenuation
switch EXP.Attenuators,
    case 'PA5', MaxAtten = 90; % dB max attenuation (higher range of PA5s is unreliable)
    case '-', MaxAtten = 0; % dB
    otherwise,
        error(['Unknown attenuators ''' EXP.Attenuators ''' specified.']);
end
AnaExcess = max(0,AnaAtten-MaxAtten);
AnaAtten = AnaAtten-AnaExcess;
Gain = Gain - AnaExcess;

% the analog attenuators are accurate to 0.1 dB. Take care of rounding
% errors.
RoundingCorrection = AnaAtten-0.1*floor(10*AnaAtten);
AnaAtten = AnaAtten-RoundingCorrection;
Gain = Gain - SameSize(RoundingCorrection, Gain);

Gain = SameSize(Gain,SPLs);
NumScale = dB2A(Gain);
NumGain_dB = Gain; % for the record
Atten = CollectInStruct(AnaAtten, NumScale, NumGain_dB);









