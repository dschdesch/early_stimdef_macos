function P = noiseStimH(P, varargin); 
% noiseStimH - compute noise stimulus
%   P = noiseStimH(P) computes the waveforms of noise stimuli.
%   The stimulus parameters are supplied as a struct P. Its values may have
%   multiple values, their rows coresponding to subsequent stimulus
%   conditions, and the columns to the DA channels. The Experiment field of
%   P specifies the calibration, available sample rates, etc.
%   In addition to Experiment, the following fields of P are used to
%   compute the waveforms
%        LowFreq: low cutoff frequency in Hz
%       HighFreq: high cutoff frequency in Hz
%      NoiseSeed: random seed for noise generation
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
%            IPD: interaural phase difference in cycles
%            IFD: interaural frequency difference in Hz
%           Corr: statistical inteaural noise correlation {-1 .. 1}
%       CorrChan: channel in which to realize Corr (I|C|L|R)
%            DAC: left|right|both active DAC channel(s)
%            SPL: sound pressure level [dB SPL]
%        SPLtype: meaning of SPL. total level | spectrum level 
%
%   Most of these parameters may be a scalar or a [1 2] array, or 
%   a [Ncond x 1] or [Ncond x 2] or array, where Ncond is the number of 
%   stimulus conditions. The allowed number of columns (1 or 2) depends on
%   the character of the paremeter, i.e., whether it may have separate
%   values for the left and right DA channel. The exceptions are NoiseSeed,
%   FineITD, GateITD, ModITD, IPD, IFD, Corr and ISI, which are allowed to 
%   have only a single column, and SPLtype, which is a single char string 
%   that applies to all of the conditions.
%   
%   In addition, noiseStimH filters the waveforms of the obtained noise stimuli.
%   The following fields of P are used to filter the waveforms
%        NHarmonics: number of harmonics of Freq
%     StartHarmonic: lowest harmonic rank
%                BW: transition bandwidth (in % of fundamental frequency)
%              Sign: positive or negative stimulus (i.e. HP+ or HP-)
%           IPDChan: chan (Left/Right) to apply interaural phase difference
%           to
%
%   The output of noiseStim is realized by updating/creating the following 
%   fields of P
%          Fsam: sample rate [Hz] of all waveforms.
%      Duration: stimulus duration [ms] in Ncond x Nchan array. 
%     FineDelay: fine-structure-ITD realizing delays (columns denote Left,Right) 
%     GateDelay: gating-ITD realizing delays (columns denote Left,Right) 
%      ModDelay: modulation-ITD realizing delays (columns denote Left,Right) 
%    PhaseShift: IPD-realizing phase shift (columns denote Left, Right))
%     FreqShift: IFD-realizing freq shift (columns denote Left, Right))
%       RefCorr: per-channel correlation with "reference" noise
%      Waveform: Ncond x Nchan Waveform object containing the samples and 
%                additional info for D/A conversion.
%      GenericParamsCall: cell array for getting generic stimulus
%                parameters. Its value is 
%                    {@noiseStim struct([]) 'GenericStimParams'}
%                After substituting the updated stimulus struct for
%                struct([]), feval-ing this cell array will yield the 
%                generic stimulus parameters for noiseStim stimuli. 
%
%   For the realization of ITDs, IPDs and IFDs in terms of channelwise 
%   delays or disparities, see ITD2delay, IPD2phaseShift, IFD2freqShift.
%
%   noiseStim(P, 'GenericStimParams') returns the generic stimulus
%   parameters for this class of noise stimuli. This call is done via
%   GenericStimParams, based on the GenericParamsCall field described above.
%
%   See also makestimFS, SAMpanel, DurPanel, dePrefix, Waveform, toneStim,
%   GenericStimParams.

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
error(local_test_singlechan(P,{'NoiseSeed', 'FineITD', 'GateITD', 'ModITD', 'IPD', 'IFD', 'Corr', 'ISI'}));
% "rename" some common fields
if ~isfield(P, 'CorrChan'), P.CorrChan = P.CorrUnit; end % channel used for varying interaural noise correlation
if ~isfield(P, 'SPLtype'), P.SPLtype = P.SPLUnit; end % total level vs spectrum level
% There are Ncond conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.
[LowFreq, HighFreq, NoiseSeed, ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineITD, GateITD, ModITD, IPD, IFD, Corr, SPL] ...
    = SameSize(P.LowFreq, P.HighFreq, P.NoiseSeed, P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModTheta, ...
    P.ISI, P.OnsetDelay, P.BurstDur, P.RiseDur, P.FallDur, ...
    P.FineITD, P.GateITD, P.ModITD, P.IPD, P.IFD, P.Corr, P.SPL);
% sign convention of ITD is specified by Experiment. Convert ITD to a nonnegative per-channel delay spec 
FineDelay = ITD2delay(FineITD(:,1), P.Experiment); % fine-structure binaural delay
GateDelay = ITD2delay(GateITD(:,1), P.Experiment); % gating binaural delay
ModDelay = ITD2delay(ModITD(:,1), P.Experiment); % modulation binaural delay
PhaseShift = IPD2phaseShift(IPD(:,1), P.Experiment); % per-channel phase shift from IPD 
FreqShift = IFD2freqShift(IFD(:,1), P.Experiment); % per-channel freq shift from IFD 
% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr, LowFreq, HighFreq, NoiseSeed, ...
    ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ... 
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, ...
    SPL] ...
    = channelSelect(P.DAC, 'LR', LowFreq, HighFreq, NoiseSeed, ...
    ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, ...
    SPL);
% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(HighFreq+ModFreq, P.Experiment); % ... accounting for recording requirements minADCrate

% Extract harmonics
P.Harmonics = P.StartHarmonic:(P.StartHarmonic+P.NHarmonics-1);
% constant determining the transition bandwith
c = 0.01*P.BW./P.Harmonics;
% determine IPDC
if strncmpi(P.IPDChan,'Left',4)
    Chan = 1;
else
    Chan = 2;
end

% compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(LowFreq);
for ichan=1:Nchan,
    chanStr = DAchanStr(ichan); % L|R
    for icond=1:Ncond,
        % select the current element from the param matrices. All params ...
        % are stored in a (iNcond x Nchan) matrix. Use a single index idx 
        % to avoid the cumbersome A(icond,ichan).
        idx = icond + (ichan-1)*Ncond;
        % compute the waveform
        P.Waveform(icond,ichan) = local_Waveform(ichan,Chan,chanStr, P.Experiment, Fsam, ...
            LowFreq(idx), HighFreq(idx), NoiseSeed(idx), ...
            ModFreq(idx), ModDepth(idx), ModStartPhase(idx), ModTheta(idx), ...
            ISI(idx), OnsetDelay(idx), BurstDur(idx), RiseDur(idx), FallDur(idx), ...
            FineDelay(idx), GateDelay(idx), ModDelay(idx), PhaseShift(idx), FreqShift(idx), Corr(idx), P.CorrChan, ...
            SPL(idx), P.SPLtype, P.Fc(icond), c, P.Harmonics, P.Version, P.Sign);
    end
end
P.Duration = SameSize(P.BurstDur, zeros(Ncond,Nchan)); 
P = structJoin(P, CollectInStruct(FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Fsam));
P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================
function  W = local_Waveform(ichan,Chan,chanChar, EXP, Fsam, ...
    LowFreq, HighFreq, NoiseSeed, ...
    ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, CorrChan, ...
    SPL, SPLtype, Fc, c, Harmonics, Version, Sign);
% Generate the waveform from the elementary parameters
Corr = corr2refcorr(Corr, CorrChan, chanChar, EXP); % 1 or Corr, depending on varied chan
% complex spectrum
NS = NoiseSpec(Fsam, BurstDur, NoiseSeed, [LowFreq, HighFreq], SPL, SPLtype, Corr);
% apply calibration, phase shift and ongoing delay while still in freq domain
n = NS.Buf.*calibrate(EXP, Fsam, chanChar, -NS.Freq, 1); % last one: complex phase factor; neg freqs: don't bother about freqs outside calib range
n = n.*exp(2*pi*i*(PhaseShift-NS.Freq*1e-3*FineDelay)); % apply fine-structure delay
% go to time domain (complex analytical waveforms) and apply modulation, freq shift & gating.
n = ifft(n);
dt = 1e3/Fsam; % ms sample period
n = n(1:ceil((GateDelay+BurstDur)/dt)); % throw away unused buffer tail
if (ModFreq>0) && (ModDepth~=0),
    ph0 = ModStartPhase - 1e-3*ModFreq*ModDelay;
    n = SinMod(n, Fsam, ph0, ModFreq, ModDepth, ModTheta);
end
if ~isequal(0,FreqShift), % heterodyne
    n = n.*exp(2*pi*i*1e-3*FreqShift*xaxis(n,dt));
end
% Depending on user preference, store complex analytic waveforms or take real part
if ~logical(EXP.StoreComplexWaveforms); 
    n = real(n);
end

% apply IPD if necessary
if (ichan==Chan) 
    n = local_HPitch(n, Fc, c, Harmonics, Version, Sign, Fsam);
end

% gating
% subplot(211)
% plot(n)
n = ExactGate(n, Fsam, BurstDur, GateDelay, RiseDur, FallDur);

% convert to waveform object & provide heading & trailing silence
P = CollectInStruct(LowFreq, HighFreq, NoiseSeed, ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, CorrChan, ...
    SPL, SPLtype); % store stim parameters for debugging purposes
NsamOnsetDelay = round(OnsetDelay/dt);
W = Waveform(Fsam, chanChar, NaN, SPL, P, {0 n}, [NsamOnsetDelay 1]);
W = AppendSilence(W, ISI);

function w = local_HPitch(w, Fc, c, Harmonics, Version, Sign, Fsam)
% Apply all pass filtering
harm = Fc*Harmonics;

switch Version
    
    case '1'
        
%         U = fft(w);
        
        % HP+
        % create rational transfer function of all pass filter
        r = 1-((pi*c.*harm)/Fsam); % radius of poles from the origin
        b = [(r.^2); -2*r.*cos(2*pi*harm./Fsam); ones(1,size(harm,2))]; % numerator of all pass filter
        a = flipud(b); % denominator of all pass filter

        % HP-
        % switch roles of numerator and denominator
        if (Sign == '-')
            b = -b;
        end

        % apply filtering
        for n=1:size(harm,2)
            w = filter(b(:,n),a(:,n),w);
            %figure;
            %freqz(b(:,n),a(:,n),512,Fsam)
            %figure;
            %plot(w)
        end
        
%         W = fft(w);
%         Z = W./U;
%         plot(angle(Z));
        
    case '2'
        
        % HP-
        % just take Fourier transform and shift the phase of the waveform's spectrum
        df = Fsam/length(w);
        freq = (0:length(w)-1)*df;
        W = fft(w(:));
        %Y = W;
        
        % HP+
        % apply 180 degrees phase shift
        if (Sign == '+')
            W = -W;
        end
        
        % apply filtering
        for n=1:size(harm,2)
            har = harm(n);
            % Positive frequencies
            W(abs(freq - har) < c(n)*har/2) = -W(abs(freq - har) < c(n)*har/2);
            % Negative frequencies
            W(abs(freq - Fsam + har) < c(n)*har/2) = -W(abs(freq - Fsam + har) < c(n)*har/2);
        end
        
        %figure;
        %plot(freq,mod(angle(W./Y),3.14));
        %pause

        w = ifft(W);
end
            

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

function P2 = HPitch(P,varargin)
% HPitch - create binaural Huggin's pitches using 2nd order all pass filters
%   P = HPitch(P) 
%
% 26/02/2015 - JV

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
ID.Ntone = 0;
% ===backward compatibility
if ~isfield(S,'Baseline'), S.Baseline = 0; end
if ~isfield(S,'OnsetDelay'), S.OnsetDelay = 0; end
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
F.Fcar = nan(Ncond,2,ID.Ntone);
F.Fmod = SameSize(channelSelect('B', S.ModFreq), Nx2);
F.LowCutoff = SameSize(channelSelect('B', S.LowFreq), Nx2);
F.HighCutoff = SameSize(channelSelect('B', S.HighFreq), Nx2);
F.FreqWarpFactor = ones(Ncond,1);
% ======startPhases & mod Depths
Y.CarStartPhase = nan([Ncond 2 ID.Ntone]);
Y.ModStartPhase = SameSize(channelSelect('B', S.ModStartPhase), Nx2);
Y.ModTheta = SameSize(channelSelect('B', S.ModTheta), Nx2);
Y.ModDepth = SameSize(channelSelect('B', S.ModDepth), Nx2);
% ======levels======
L.SPL = SameSize(channelSelect('B', S.SPL), Nx2);
if isequal('dB/Hz', S.SPLUnit), L.SPLtype = 'spectrum level';
elseif isequal('dB SPL', S.SPLUnit), L.SPLtype = 'total level';
end
L.DAC = S.DAC;
P = structJoin(ID, '-Timing', T, '-Frequencies', F, '-Phases_Depth', Y, '-Levels', L);
P.CreatedBy = mfilename; % sign