function P = harmonicStim(P, varargin); 
% harmonicStim - compute tone stimulus
%   P = harmonicStim(P) computes the waveforms of tonal stimulus
%   The carrier frequencies are given by P.Fcar [Hz], which is a column 
%   vector (mono) or Nx2 vector (stereo). The remaining parameters are
%   taken from the parameter struct P returned by GUIval. The Experiment
%   field of P specifies the calibration, available sample rates etc
%   In addition to Experiment, the following fields of P are used to
%   compute the waveforms
%           Fcar: carrier frequency in Hz
%    FreqTolMode: tolerance mode for freq rounding; equals exact|economic.
%        ModFreq: modulation frequency in Hz
%       ModDepth: modulation depth in %
%       ModStartPhase: modulation starting phase in cycles (0=cosine)
%       ModTheta: modulation angle in Cycle (0=AM, 0.25=QFM, other=mixed)
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
%   The output of toneStim is realized by updating/creating the following 
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
%   toneStim(P, 'GenericStimParams') returns the generic stimulus
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
error(local_test_singlechan(P,{'FineITD', 'GateITD', 'ModITD', 'ISI'}));
% There are Ncond=size(Fcar,1) conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.
[Fcar, OnsetDelay, BurstDur, RiseDur, FallDur, ISI, ...
    FineITD, GateITD, ModITD, SPL, F02F01] ...
    = SameSize(P.Fcar, P.OnsetDelay, P.BurstDur, P.RiseDur, P.FallDur, P.ISI, ...
    P.FineITD, P.GateITD, P.ModITD, P.SPL, P.F02F01);

% sign convention of ITD is specified by Experiment. Convert ITD to a nonnegative per-channel delay spec 
FineDelay = ITD2delay(FineITD(:,1), P.Experiment); % fine-structure binaural delay
GateDelay = ITD2delay(GateITD(:,1), P.Experiment); % gating binaural delay
ModDelay = ITD2delay(ModITD(:,1), P.Experiment); % modulation binaural delay
% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
if strcmpi(P.F01DAC,'both') || strcmpi(P.F02DAC,'both') || ~isequal(P.F02DAC, P.F01DAC)
    P.DAC = 'Both';
else
    P.DAC = P.F01DAC(1);
end
[DAchanStr,Fcar, ...
    OnsetDelay, BurstDur, RiseDur, FallDur, ISI, ... 
    FineDelay, GateDelay, ModDelay, SPL, F02F01] ...
    = channelSelect(P.DAC,'LR', Fcar, ...
    OnsetDelay, BurstDur, RiseDur, FallDur, ISI, ...
    FineDelay, GateDelay, ModDelay, SPL, F02F01);
% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(Fcar*max(max([P.F01Harmonics, P.F02F01.*P.F02Harmonics]),1), P.Experiment); % accounting for recording requirements minADCrate
% now compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(Fcar);
DAchanStr='LR';
for ichan=1:Nchan,
    if Nchan == 1
       if strcmpi(P.F01DAC(1),'l')
           chanStr = 'L';
       else
           chanStr = 'R';
       end
    else
        chanStr = DAchanStr(ichan); % L|R
    end
    
    for icond=1:Ncond,
        % select the current element from the param matrices. All params ...
        % are stored in a (iNcond x Nchan) matrix. Use a single index idx 
        % to avoid the cumbersome A(icond,ichan).
        idx = icond + (ichan-1)*Ncond;
        % evaluate cyclic storage to save samples
        
        % TODO: use CyclicStorage to have compact representation

        % compute the waveform
        w = local_Waveform(chanStr, P.Experiment, Fsam, ISI(idx), ...
            FineDelay(idx), GateDelay(idx), OnsetDelay(idx), BurstDur(idx), RiseDur(idx), FallDur(idx), ...
            Fcar(idx), P.Fundamentals, P.F01Harmonics, F02F01(idx), P.F02Harmonics, SPL(idx), ...
            P.F01DAC, P.F02DAC);
        P.Waveform(icond,ichan) = w;
    end
end
P.Duration = SameSize(P.BurstDur, zeros(Ncond,Nchan)); 
P = structJoin(P, CollectInStruct(FineDelay, GateDelay, ModDelay, Fsam));
P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================
function  [W, Fcar] = local_Waveform(DAchan, EXP, Fsam, ISI, ...
    FineDelay, GateDelay, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    Fcar, Fundamentals, F01Harmonics, F02F01, F02Harmonics, SPL,F01DAC, F02DAC);
% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
% get sample counts of subsequent segments
SteadyDur = BurstDur-RiseDur-FallDur; % steady (non-windowd) part of tone
[NonsetDelay, NgateDelay, Nrise, Nsteady, Nfall] = ...
    NsamplesofChain([OnsetDelay, GateDelay, RiseDur, SteadyDur, FallDur], Fsam/1e3);
% literal storage: phrase as single rep of cyclic buffer + empty tail buffer
NsamCyc = Nsteady;  % total # samples in steady-state portion
NrepCyc = 1; % # reps of cyclic buffer
NsamTail = 0; % No tail buffer

%=======FREQUENCIES, PHASES, AMPLITUDES and CALIBRATION=======
F01 = 0;
F02 = 0;
if strcmpi(DAchan,'l')
    if strcmpi(F01DAC,'both') || strcmpi(F01DAC(1),'l')
        F01 = 1;
    end;
    if strcmpi(F02DAC,'both') || strcmpi(F02DAC(1),'l')
        F02 = 1;
    end
elseif strcmpi(DAchan,'r')
    if strcmpi(F01DAC,'both') || strcmpi(F01DAC(1),'r')
        F01 = 1;
    end;
    if strcmpi(F02DAC,'both') || strcmpi(F02DAC(1),'r')
        F02 = 1;
    end 
else
    F01 = 0;
    F02 = 0;
end
    
if strcmpi(Fundamentals,'F01+F02') && (F01 || F02),
    if F01 && F02
        freq = Fcar.*[F01Harmonics F02F01*F02Harmonics]; % [Hz] harmonics of both fundamentals
    elseif F01
        freq = Fcar.*[F01Harmonics];
    elseif F02
        freq = Fcar.*[F02F01*F02Harmonics];
    end
elseif strcmpi(Fundamentals,'F01')
    freq = Fcar.*[F01Harmonics]; % [Hz] only first fundamental and harmonics
elseif strcmpi(Fundamentals,'F02')
    freq = Fcar.*[F02F01*F02Harmonics]; % [Hz] only second fundamental and harmonics
end
[calibDL, calibDphi] = calibrate(EXP, Fsam, DAchan, freq);
% waveform is generated @ the target SPL. Scaling is divided
% between numerical scaling and analog attenuation later on.
Amp = dB2A(SPL)*sqrt(2)*dB2A(calibDL); % numerical linear amplitudes of the carrier ...
% Compute phase of numerical waveform at start of onset, i.e., first sample of rising portion of waveform.
StartPhase = calibDphi - 1e-3*FineDelay.*freq; % fine structure delay is realized in freq domain

dt = 1e3/Fsam; % sample period in ms
% compute dur of stored tone, whether useCyclicStorage or not
StoreDur = dt*(NgateDelay + Nrise + (NsamCyc + NsamTail) + Nfall); % only a single cycled buf is used
wtone = tonecomplex(Amp, freq, StartPhase, Fsam, StoreDur); % ungated waveform buffer; starting just after OnsetDelay
if logical(EXP.StoreComplexWaveforms); % if true, store complex analytic waveforms, real part otherwise
    wtone = wtone+ i*toneComplex(Amp, freq, StartPhase+0.25, Fsam, StoreDur);
end
wtone = ExactGate(wtone, Fsam, StoreDur-GateDelay, GateDelay, RiseDur, FallDur);
%set(gcf,'units', 'normalized', 'position', [0.519 0.189 0.438 0.41]); %xdplot(dt,wtone, 'color', rand(1,3)); error kjhkjh

% parameters stored w waveform. Mainly for debugging purposes.
NsamHead = NgateDelay + Nrise; % # samples in any gating delay + risetime portion
Nsam = CollectInStruct(NonsetDelay, NgateDelay, Nrise, Nsteady, Nfall, NsamHead);
Durs = CollectInStruct(BurstDur, RiseDur, FallDur, OnsetDelay, GateDelay, SteadyDur, FallDur);
Delays = CollectInStruct(FineDelay, GateDelay, OnsetDelay);
Param = CollectInStruct(Nsam, Durs, Delays, freq, Amp, StartPhase, SPL);
% Patch together the segments of the tone, using the cycled storage format,
% or the fake version of it.
if strcmpi(Fundamentals,'F01+F02') && (F01 || F02),
    W = Waveform(Fsam, DAchan, NaN, SPL, Param, ...
        {0              wtone(1:NsamHead)  wtone(NsamHead+(1:NsamCyc))   wtone(NsamHead+NsamCyc+1:end)},...
        [NonsetDelay    1                  NrepCyc                       1]);
elseif strcmpi(Fundamentals,'F01') && F01
    W = Waveform(Fsam, DAchan, NaN, SPL, Param, ...
        {0              wtone(1:NsamHead)  wtone(NsamHead+(1:NsamCyc))   wtone(NsamHead+NsamCyc+1:end)},...
        [NonsetDelay    1                  NrepCyc                       1]);
elseif strcmpi(Fundamentals,'F02') && F02
    W = Waveform(Fsam, DAchan, NaN, SPL, Param, ...
        {0              wtone(1:NsamHead)  wtone(NsamHead+(1:NsamCyc))   wtone(NsamHead+NsamCyc+1:end)},...
        [NonsetDelay    1                  NrepCyc                       1]);
else 
    W = Waveform(Fsam, DAchan, NaN, SPL, Param, ...
        {0              zeros(size(wtone(1:NsamHead)))  zeros(size(wtone(NsamHead+(1:NsamCyc))))   zeros(size(wtone(NsamHead+NsamCyc+1:end)))},...
        [NonsetDelay    1                  NrepCyc                       1]);
%    ^onset delay   ^gate_delay+rise   ^cyclic part                  ^remainder steady+fall  
end

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
F.Fmod = SameSize(channelSelect('B', NaN), Nx2);
F.LowCutoff = nan(Ncond,2);
F.HighCutoff = nan(Ncond,2);
F.FreqWarpFactor = ones(Ncond,1);
% ======startPhases & mod Depths
Y.CarStartPhase = nan([Ncond 2 ID.Ntone]);
Y.ModStartPhase = SameSize(channelSelect('B', NaN), Nx2);
Y.ModTheta = SameSize(channelSelect('B', NaN), Nx2);
Y.ModDepth = SameSize(channelSelect('B', NaN), Nx2);
% ======levels======
L.SPL = SameSize(channelSelect('B', S.SPL), Nx2);
L.SPLtype = 'per tone';
L.DAC = S.DAC;
P = structJoin(ID, '-Timing', T, '-Frequencies', F, '-Phases_Depth', Y, '-Levels', L);
P.CreatedBy = mfilename; % sign




