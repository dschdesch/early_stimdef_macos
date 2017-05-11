function P = clickStim(P, varargin);
% clickStim - compute click stimulus
%   P = clickStim(P) computes the waveforms of click stimulus
%   The carrier frequencies are given by P.Fcar [Hz], which is a column
%   vector (mono) or Nx2 vector (stereo). The remaining parameters are
%   taken from the parameter struct P returned by GUIval. The Experiment
%   field of P specifies the calibration, available sample rates etc
%   In addition to Experiment, the following fields of P are used to
%   compute the waveforms
%           Fcar: carrier frequency in Hz
%      WavePhase: starting phase (cycles) of carrier (0 means cos phase)
%    FreqTolMode: tolerance mode for freq rounding; equals exact|economic.
%            ISI: onset-to-onset inter-stimulus interval in ms
%     OnsetDelay: silent interval (ms) preceding onset (common to both DACs)
%       BurstDur: burst duration in ms including ramps
%        RiseDur: duration of onset ramp
%        FallDur: duration of offset ramp
%        FineITD: ITD imposed on fine structure in ms
%        GateITD: ITD imposed on gating in ms
%         ModITD: ITD imposed on modulation in ms
%            DAC: left|right|both active DAC channel(s)
%            SPL: carrier sound pressure level [dB SPL]
%
%   Most of these parameters may be a scalar or a [1 2] array, or
%   a [Ncond x 1] or [Ncond x 2] or array, where Ncond is the number of
%   stimulus conditions. The allowed number of columns (1 or 2) depends on
%   the character of the paremeter, i.e., whether it may have separate
%   values for the left and right DA channel. The exceptions are
%   FineITD, GateITD, ModITD, and ISI, which which are allowed to have
%   only one column, and SPLtype and FreqTolMode, which are a single char
%   strings that apply to all of the conditions.
%
%   The output of clickStim is realized by updating/creating the following
%   fields of P
%         Fsam: sample rate [Hz] of all waveforms.
%         Fcar: adjusted to slightly rounded values to save memory using cyclic
%               storage (see CyclicStorage).
%         Fmod: modulation frequencies [Hz] in Ncond x Nchan matrix or column
%               array. Might deviate slightly from user-specified values to
%               facilitate storage (see CyclicStorage).
%   CyclicStorage: the Ncond x Nchan struct with outputs of CyclicStorage
%     Duration: stimulus duration [ms] in Ncond x Nchan array.
%    FineDelay: fine-structure-ITD realizing delays (columns denote Left,Right)
%    GateDelay: gating-ITD realizing delays (columns denote Left,Right)
%     ModDelay: modulation-ITD realizing delays (columns denote Left,Right)
%     Waveform: Ncond x Nchan Waveform object containing the samples and
%               additional info for D/A conversion.
%     GenericParamsCall: cell array for getting generic stimulus
%               parameters. Its value is
%                   {@noiseStim struct([]) 'GenericStimParams'}
%               After substituting the updated stimulus struct for
%               struct([]), feval-ing this cell array will yield the
%               generic stimulus parameters for noiseStim stimuli.
%
%   For the realization of ITDs in terms of channelwise delays, see
%   ITD2delay.
%
%   clickStim(P, 'GenericStimParams') returns the generic stimulus
%   parameters for this class of tonal stimuli. This call is done via
%   GenericStimParams, based on the GenericParamsCall field described above.
%
%   See also makestimFS, SAMpanel, DurPanel, dePrefix, Waveform,
%   noiseStim, ITD2delay.

if nargin>1
    if isequal('GenericStimParams', varargin{1}),
        P = local_genericstimparams(P);
        return;
    else,
        error('Invalid second input argument.');
    end
end
S = [];
% test the channel restrictions described in the help text
error(local_test_singlechan(P,{'FineITD', 'GateITD', 'ISI'}));
% There are Ncond=size(Fcar,1) conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.
[Fcar, ...
    OnsetDelay, BurstDur, RiseDur, FallDur, ISI, WavePhase, ...
    FineITD, GateITD, SPL, PulseWidth, PulseType] ...
    = SameSize(P.Fcar, ...
    P.OnsetDelay, P.BurstDur, P.RiseDur, P.FallDur, P.ISI, P.WavePhase, ...
    P.FineITD, P.GateITD, P.SPL, P.PulseWidth, P.PulseType);
% sign convention of ITD is specified by Experiment. Convert ITD to a nonnegative per-channel delay spec
FineDelay = ITD2delay(FineITD(:,1), P.Experiment); % fine-structure binaural delay
GateDelay = ITD2delay(GateITD(:,1), P.Experiment); % gating binaural delay
% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr, Fcar, ...
    OnsetDelay, BurstDur, RiseDur, FallDur, ISI, WavePhase, ...
    FineDelay, GateDelay, SPL, PulseWidth, PulseType] ...
    = channelSelect(P.DAC, 'LR', Fcar, ...
    OnsetDelay, BurstDur, RiseDur, FallDur, ISI, WavePhase, ...
    FineDelay, GateDelay, SPL, PulseWidth, PulseType);
% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(Fcar, P.Experiment); % accounting for recording requirements minADCrate
% tolerances for memory-saving frequency roundings.
[CarTol, ModTol] = FreqTolerance(Fcar, 0, P.FreqTolMode);
% compute # samples needed to store the waveforms w/o cyclic storage tricks
NsamTotLiteral = round(1e-3*sum(BurstDur)*Fsam);
[dum, NsamTotLiteral] = SameSize(Fcar, NsamTotLiteral);
% now compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(Fcar);
[P.Fcar, P.Fmod] = deal(zeros(Ncond, Nchan));
for ichan=1:Nchan,
    chanStr = DAchanStr(ichan); % L|R
    for icond=1:Ncond,
        % select the current element from the param matrices. All params ...
        % are stored in a (iNcond x Nchan) matrix. Use a single index idx
        % to avoid the cumbersome A(icond,ichan).
        idx = icond + (ichan-1)*Ncond;
        % evaluate cyclic storage to save samples
        C = CyclicStorage(Fcar(idx), 0, Fsam, BurstDur(idx), [CarTol(idx), ModTol(idx)], NsamTotLiteral(ichan));
        % compute the waveform
        [w, fcar, fmod] = local_Waveform(chanStr, P.Experiment, Fsam, ISI(idx), ...
            FineDelay(idx), GateDelay(idx), OnsetDelay(idx), RiseDur(idx), FallDur(idx), ...
            C, WavePhase(idx), PulseWidth(idx), PulseType(idx), SPL(idx));
        P.Waveform(icond,ichan) = w;
        % derived stim params
        P.Fcar(icond,ichan) = fcar;
        P.Fmod(icond,ichan) = fmod;
        P.CyclicStorage(icond,ichan) = C;
    end
end
P.Duration = SameSize(P.BurstDur, zeros(Ncond,Nchan));
P = structJoin(P, CollectInStruct(FineDelay, GateDelay, Fsam));
P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================
function  [W, Fcar, Fmod] = local_Waveform(DAchan, EXP, Fsam, ISI, ...
    FineDelay, GateDelay, OnsetDelay, RiseDur, FallDur, ...
    C, WavePhase, PulseWidth, PulseType, SPL);
% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
BurstDur = C.Dur;
% get sample counts of subsequent segments
SteadyDur = BurstDur-RiseDur-FallDur; % steady (non-windowd) part of click
[NonsetDelay, NgateDelay, Nrise, Nsteady, Nfall] = ...
    NsamplesofChain([OnsetDelay, GateDelay, RiseDur, SteadyDur, FallDur], Fsam/1e3);
% For uniformity, cast literal storage in the form of a fake cyclic storage
useCyclicStorage = C.CyclesDoHelp && (Nsteady>=C.Nsam);
if useCyclicStorage, % cyclic storage
    NsamCyc = C.Nsam;  % # samples in cyclic buffer
    NrepCyc = floor(Nsteady/NsamCyc); % # reps of cyclic buffer
    NsamTail = rem(Nsteady,NsamCyc); % Tail containing remainder of cycles
    Fcar = C.FcarProx; Fmod = C.FmodProx; % actual frequencies used in waveforms
else, % literal storage: phrase as single rep of cyclic buffer + empty tail buffer
    NsamCyc = Nsteady;  % total # samples in steady-state portion
    NrepCyc = 1; % # reps of cyclic buffer
    NsamTail = 0; % No tail buffer
    Fcar = C.Fcar; Fmod = C.Fmod; % actual frequencies used in waveforms
end

%=======FREQUENCIES, PHASES, AMPLITUDES and CALIBRATION=======
PbufWidth = max(2, 1.5e-3*PulseWidth); % ms duration of single-pulse buffer

samp = 1e6/Fsam; % sample period in us
NsamT = round(PbufWidth*1e3/samp); % # samples in single-pulse buffer
NsamF = 2^nextpow2(NsamT); % # samples in fft buffer
df = Fsam/NsamF;
freq = linspace(0,Fsam-df,NsamF).'; % freq axis (column vector)
[calibDL, calibDphi] = calibrate(EXP, Fsam, DAchan, -freq); % negative for out of range freqs
calibrator = dB2A(calibDL).*exp(2*pi*1i*calibDphi); % SPL -> DAC spectral multiplier



% build single-pulse spectrum; start in time domain
pulseBuf = zeros(NsamF,1);
monophase = isequal(abs(PulseType),1);
if monophase |PulseType==3
    NsamP = round(PulseWidth/samp);
    NsamP = max(NsamP,2);
    pulseBuf(1:NsamP) = sign(PulseType);
else
    %PulseWidth correct?
    NsamP = round(PulseWidth/samp);
    NsamP = max(NsamP,1);
    pulseBuf(1:NsamP) = sign(PulseType);
    pulseBuf(NsamP+(1:NsamP)) = -sign(PulseType);
    
end
pulseSpec = fft(pulseBuf);
% SPL corresponds to RMS w/o calibration
SFreq = Fcar;
if Fcar==0,
    SFreq = 100; % convention: single clicks are calibrated re 100 Hz trains
    Fcar = 1e3/BurstDur/2;
end

SPLtheor = 6+P2dB(mean(real(ifft(pulseSpec./calibrator)).^2)); % calibration-weighted sum of all components of click
SPLtheor = SPLtheor + P2dB(NsamF/NsamT); % compensate for truncation in time domain
SPLtheor = SPLtheor + P2dB(SFreq*PbufWidth*1e-3); % compensate for the fact that true rate ~= 1/MaxWidth
pulseBuf = pulseBuf(1:NsamT);

dt = 1e3/Fsam; % sample period in ms
% compute dur of stored buffer, whether useCyclicStorage or not
BufLen = (NgateDelay + Nrise + (NsamCyc + NsamTail) + Nfall); % only a single cycled buf is used
BufDur = dt*BufLen;

Npulses = ceil(BufDur * Fcar * 1e-3);
% determine Offsets of different pulses in cyclic buffer
TotOffsets = (0:(Npulses-1))*1e3/Fcar + FineDelay; % in ms
% integer number of samples contained in offsets
IntOffsets = round(TotOffsets/dt);

% % determine Offsets of different pulses in cyclic buffer
% TotOffsets = (0:(Ncyc-1))*BufDur/Ncyc; % in ms
% % integer number of samples contained in offsets
% IntOffsets = round(TotOffsets/dt);

% now set up the periodic buffer and fill it with the various, time-shifted, pulses
CycBuf = zeros(BufLen,1);
for ii=1:Npulses,
    tRange = IntOffsets(ii)+(1:NsamT);
    tRange = tRange(tRange<=BufLen);
  
    if PulseType==3
        CycBuf(tRange) = CycBuf(tRange) + (-1)^(ii)*pulseBuf(1:length(tRange));
    else
        CycBuf(tRange) = CycBuf(tRange) + pulseBuf(1:length(tRange));
    end
end


% ?????? SPL, scaling factors?
ScaleFactor = 1/max(abs(CycBuf));

% waveform is generated @ the target SPL. Scaling is divided
% between numerical scaling and analog attenuation later on.
Amp = dB2A(SPL)*sqrt(2)/dB2A(SPLtheor); % numerical linear amplitudes of the carrier ...
CycBuf = Amp(1) * CycBuf * ScaleFactor;


CycBuf = ExactGate(CycBuf, Fsam, BufDur-GateDelay, GateDelay, RiseDur, FallDur);

% Compute phase of numerical waveform at start of onset, i.e., first sample of rising portion of waveform.
StartPhase = WavePhase + calibDphi - 1e-3*FineDelay.*freq; % fine structure delay is realized in freq domain


% parameters stored w waveform. Mainly for debugging purposes.
NsamHead = NgateDelay + Nrise; % # samples in any gating delay + risetime portion
Nsam = CollectInStruct(NonsetDelay, NgateDelay, Nrise, Nsteady, Nfall, NsamHead);
Durs = CollectInStruct(BurstDur, RiseDur, FallDur, OnsetDelay, GateDelay, SteadyDur, FallDur);
Delays = CollectInStruct(FineDelay, GateDelay, OnsetDelay);
Param = CollectInStruct(C, Nsam, Durs, Delays, freq, Amp, StartPhase, SPL, useCyclicStorage);
% Patch together the segments of the tone, using the cycled storage format,
% or the fake version of it.
W = Waveform(Fsam, DAchan, NaN, SPL, Param, ...
    {0              CycBuf(1:NsamHead)  CycBuf(NsamHead+(1:NsamCyc))   CycBuf(NsamHead+NsamCyc+1:end)},...
    [NonsetDelay    1                  NrepCyc                       1]);
%    ^onset delay   ^gate_delay+rise   ^cyclic part                  ^remainder steady+fall
W = AppendSilence(W, ISI); % pas zeros to ensure correct ISI

function Mess = local_test_singlechan(P, FNS);
% test whether specified fields of P have single chan values
Mess = '';
for ii=1:numel(FNS),
    fn = FNS{ii};
    if size(P.(fn),2)~=1,
        Mess = ['The ''' fn ''' field of P struct must have a single column.'];
        return;
    end
end

function P = local_genericstimparams(S);
% extracting generic stimulus parameters. Note: this only works after
% SortCondition has been used to add a Presentation field to the
% stimulus-defining struct S.
Ncond = S.Presentation.Ncond;
dt = 1e3/S.Fsam; % sample period in ms
Nx1 = zeros(Ncond,1); % dummy for resizing
Nx2 = zeros(Ncond,2); % dummy for resizing
%
ID.StimType = S.StimType;
ID.Ncond = Ncond;
ID.Nrep  = S.Presentation.Nrep;
ID.Ntone = 1;
% ======timing======
T.PreBaselineDur = channelSelect('L', S.Baseline);
T.PostBaselineDur = channelSelect('R', S.Baseline);
T.ISI = SameSize(S.ISI, Nx1);
T.BurstDur = SameSize(channelSelect('B', S.Duration), Nx2);
T.OnsetDelay = SameSize(dt*floor(S.OnsetDelay/dt), Nx1); % always integer # samples
T.RiseDur = SameSize(channelSelect('B', S.RiseDur), Nx2);
T.FallDur = SameSize(channelSelect('B', S.FallDur), Nx2);
T.ITD = SameSize(S.ITD, Nx1);
T.ITDtype = S.ITDtype;
T.TimeWarpFactor = ones(Ncond,1);
% ======freqs======
F.Fsam = S.Fsam;
F.Fcar = SameSize(channelSelect('B', S.Fcar),Nx2);
F.Fmod = SameSize(nan, Nx2);
F.LowCutoff = nan(Ncond,2);
F.HighCutoff = nan(Ncond,2);
F.FreqWarpFactor = ones(Ncond,1);
% ======startPhases & mod Depths
Y.CarStartPhase = nan([Ncond 2 ID.Ntone]);
Y.ModStartPhase = SameSize(nan, Nx2);
Y.ModTheta = SameSize(nan, Nx2);
Y.ModDepth = SameSize(nan, Nx2);
% ======levels======
L.SPL = SameSize(channelSelect('B', S.SPL), Nx2);
L.SPLtype = 'per tone';
L.DAC = S.DAC;
P = structJoin(ID, '-Timing', T, '-Frequencies', F, '-Phases_Depth', Y, '-Levels', L);
P.CreatedBy = mfilename; % sign




