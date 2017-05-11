function P = noiseStimARMIN(P, varargin); 
% noiseStimARMIN - compute noise stimulus
%   P = noiseStimARMIN(P) computes the waveforms of noise stimuli.
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
%   The output of noiseStimARMIN is realized by updating/creating the following 
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
%                generic stimulus parameters for noiseStimARMIN stimuli. 
%
%   For the realization of ITDs, IPDs and IFDs in terms of channelwise 
%   delays or disparities, see ITD2delay, IPD2phaseShift, IFD2freqShift.
%
%   noiseStimARMIN(P, 'GenericStimParams') returns the generic stimulus
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
error(local_test_singlechan(P,{'LowSeed','HighSeed','ConstNoiseSeed' ,'FineITD', 'GateITD', 'ModITD', 'IPD', 'IFD', 'Corr', 'ISI'}));
% "rename" some common fields
if ~isfield(P, 'CorrChan'), P.CorrChan = P.VariedChannel; end % channel used for varying interaural noise correlation
if ~isfield(P, 'StartSPLUnit'), P.SPLtype = P.SPLUnit; end % total level vs spectrum level
% There are Ncond conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.
[LowFreq, HighFreq, FlipFreq, ConstNoiseSeed, ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineITD, GateITD, ModITD, IPD, IFD, Corr, SPL, LowSeed, HighSeed, ...
    LowPolarity, HighPolarity, ConstPolarity] ...
    = SameSize(P.LowFreq, P.HighFreq, P.FlipFreq, P.ConstNoiseSeed, 0, 0, 0, 0, ...
    P.ISI, P.OnsetDelay, P.BurstDur, P.RiseDur, P.FallDur, ...
    P.FineITD, P.GateITD, P.ModITD, P.IPD, P.IFD, P.Corr, P.SPL, P.LowSeed, P.HighSeed, ...
    P.LowPolarity, P.HighPolarity, P.ConstPolarity);
% sign convention of ITD is specified by Experiment. Convert ITD to a nonnegative per-channel delay spec 
FineDelay = ITD2delay(FineITD(:,1), P.Experiment); % fine-structure binaural delay
GateDelay = ITD2delay(GateITD(:,1), P.Experiment); % gating binaural delay
ModDelay = ITD2delay(ModITD(:,1), P.Experiment); % modulation binaural delay
PhaseShift = IPD2phaseShift(IPD(:,1), P.Experiment); % per-channel phase shift from IPD 
FreqShift = IFD2freqShift(IFD(:,1), P.Experiment); % per-channel freq shift from IFD 
% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr, LowFreq, HighFreq, FlipFreq, ConstNoiseSeed, ...
    ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ... 
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, ...
    SPL, LowSeed, HighSeed, LowPolarity, HighPolarity, ConstPolarity] ...
    = channelSelect(P.DAC, 'LR', LowFreq, HighFreq, FlipFreq, ConstNoiseSeed, ...
    ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, ...
    SPL, LowSeed, HighSeed, LowPolarity, HighPolarity, ConstPolarity);
% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(HighFreq+ModFreq, P.Experiment); % ... accounting for recording requirements minADCrate
% compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(LowFreq);
Exp = P.Experiment;
for ichan=1:Nchan,
    chanStr = DAchanStr(ichan); % L|R
    par_LowFreq = LowFreq((ichan-1)*Ncond+1:ichan*Ncond);
    par_HighFreq = HighFreq((ichan-1)*Ncond+1:ichan*Ncond);
    par_FlipFreq = FlipFreq((ichan-1)*Ncond+1:ichan*Ncond);
    par_ConstNoiseSeed = ConstNoiseSeed((ichan-1)*Ncond+1:ichan*Ncond);
    par_ModFreq = ModFreq((ichan-1)*Ncond+1:ichan*Ncond);
    par_ModDepth = ModDepth((ichan-1)*Ncond+1:ichan*Ncond);
    par_ModStartPhase = ModStartPhase((ichan-1)*Ncond+1:ichan*Ncond);
    par_ModTheta = ModTheta((ichan-1)*Ncond+1:ichan*Ncond);
    par_ISI = ISI((ichan-1)*Ncond+1:ichan*Ncond);
    par_OnsetDelay = OnsetDelay((ichan-1)*Ncond+1:ichan*Ncond);
    par_BurstDur = BurstDur((ichan-1)*Ncond+1:ichan*Ncond);
    par_RiseDur = RiseDur((ichan-1)*Ncond+1:ichan*Ncond);
    par_FallDur = FallDur((ichan-1)*Ncond+1:ichan*Ncond);
    par_FineDelay = FineDelay((ichan-1)*Ncond+1:ichan*Ncond);
    par_GateDelay = GateDelay((ichan-1)*Ncond+1:ichan*Ncond);
    par_ModDelay = ModDelay((ichan-1)*Ncond+1:ichan*Ncond);
    par_PhaseShift = PhaseShift((ichan-1)*Ncond+1:ichan*Ncond);
    par_FreqShift = FreqShift((ichan-1)*Ncond+1:ichan*Ncond);
    par_Corr = Corr((ichan-1)*Ncond+1:ichan*Ncond);
    par_SPL = SPL((ichan-1)*Ncond+1:ichan*Ncond);
    par_LowSeed = LowSeed((ichan-1)*Ncond+1:ichan*Ncond);
    par_HighSeed = HighSeed((ichan-1)*Ncond+1:ichan*Ncond);
    par_LowPolarity = LowPolarity((ichan-1)*Ncond+1:ichan*Ncond);
    par_HighPolarity = HighPolarity((ichan-1)*Ncond+1:ichan*Ncond);
    par_ConstPolarity = ConstPolarity((ichan-1)*Ncond+1:ichan*Ncond);
    parfor icond=1:Ncond,
        % select the current element from the param matrices. All params ...
        % are stored in a (iNcond x Nchan) matrix. Use a single index idx 
        % to avoid the cumbersome A(icond,ichan).
        % compute the waveform
        Q(icond) = local_Waveform(chanStr, Exp, Fsam, ...
            par_LowFreq(icond), par_HighFreq(icond), par_FlipFreq(icond), par_ConstNoiseSeed(icond), ...
            par_ModFreq(icond), par_ModDepth(icond), par_ModStartPhase(icond), par_ModTheta(icond), ...
            par_ISI(icond), par_OnsetDelay(icond), par_BurstDur(icond), par_RiseDur(icond), par_FallDur(icond), ...
            par_FineDelay(icond), par_GateDelay(icond), par_ModDelay(icond), par_PhaseShift(icond), ...
            par_FreqShift(icond), par_Corr(icond), P.CorrChan, par_SPL(icond), P.StartSPLUnit, ...
            par_LowSeed(icond), par_HighSeed(icond), par_LowPolarity(icond), ...
            par_HighPolarity(icond), par_ConstPolarity(icond));
    end
        P.Waveform(:,ichan) = Q;

end
P.Duration = SameSize(P.BurstDur, zeros(Ncond,Nchan)); 
P = structJoin(P, CollectInStruct(FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Fsam));
P.GenericParamsCall = {fhandle(mfilename) struct([]) 'GenericStimParams'};


%===================================================
%===================================================
function  W = local_Waveform(chanChar, EXP, Fsam, ...
    LowFreq, HighFreq, FlipFreq, ConstNoiseSeed, ...
    ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, CorrChan, ...
    SPL, SPLtype, LowSeed, HighSeed, LowPolarity, HighPolarity, ConstPolarity);
% Generate the waveform from the elementary parameters
Corr = corr2refcorr(Corr, CorrChan, chanChar, EXP); % 1 or Corr, depending on varied chan
% complex spectrum
if Corr == -1 %varied channel
    % Noise with the low seed
    NS = NoiseSpec(Fsam, BurstDur, LowSeed, [LowFreq, HighFreq], SPL, SPLtype, 1);
    % Noise with the high seed
    NS_high = NoiseSpec(Fsam, BurstDur, HighSeed, [LowFreq, HighFreq], SPL, SPLtype, 1);
    
    % determine which part of spectrum doesn't have to be flipped
    corrOne = betwixt(NS.Freq, [-Inf FlipFreq]);

    % mix correlated and anticorrelated part of spectrum
    if strcmp(LowPolarity,'-')
        NS.Buf(NS.Freq <= FlipFreq) = NS.Buf(NS.Freq <= FlipFreq)*(-1);
    end
    if strcmp(HighPolarity,'-')
        NS_high.Buf(NS_high.Freq > FlipFreq) = NS_high.Buf(NS_high.Freq > FlipFreq)*(-1);
    end
    NS.Buf = NS.Buf.*corrOne + NS_high.Buf.*(~corrOne);
else
    NS = NoiseSpec(Fsam, BurstDur, ConstNoiseSeed, [LowFreq, HighFreq], SPL, SPLtype, Corr);
    if strcmp(ConstPolarity,'-')
        NS.Buf = NS.Buf*(-1);
    end
end

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
% gating
n = ExactGate(n, Fsam, BurstDur, GateDelay, RiseDur, FallDur);
% convert to waveform object & provide heading & trailing silence
P = CollectInStruct(LowFreq, HighFreq, ConstNoiseSeed, ModFreq, ModDepth, ModStartPhase, ModTheta, ...
    ISI, OnsetDelay, BurstDur, RiseDur, FallDur, ...
    FineDelay, GateDelay, ModDelay, PhaseShift, FreqShift, Corr, CorrChan, ...
    SPL, SPLtype, LowSeed, HighSeed, LowPolarity, HighPolarity, ConstPolarity); % store stim parameters for debugging purposes
NsamOnsetDelay = round(OnsetDelay/dt);
W = Waveform(Fsam, chanChar, NaN, SPL, P, {0 n}, [NsamOnsetDelay 1]);
W = AppendSilence(W, ISI);

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
F.Fmod = SameSize(channelSelect('B', 0), Nx2);
F.LowCutoff = SameSize(channelSelect('B', S.LowFreq), Nx2);
F.HighCutoff = SameSize(channelSelect('B', S.HighFreq), Nx2);
F.FreqWarpFactor = ones(Ncond,1);
% ======startPhases & mod Depths
Y.CarStartPhase = nan([Ncond 2 ID.Ntone]);
Y.ModStartPhase = SameSize(channelSelect('B', 0), Nx2);
Y.ModTheta = SameSize(channelSelect('B', 0), Nx2);
Y.ModDepth = SameSize(channelSelect('B', 0), Nx2);
% ======levels======
L.SPL = SameSize(channelSelect('B', S.SPL), Nx2);
S.SPLUnit = S.StartSPLUnit;
if isequal('dB/Hz', S.SPLUnit), L.SPLtype = 'spectrum level';
elseif isequal('dB SPL', S.SPLUnit), L.SPLtype = 'total level';
end
L.DAC = S.DAC;
P = structJoin(ID, '-Timing', T, '-Frequencies', F, '-Phases_Depth', Y, '-Levels', L);
P.CreatedBy = mfilename; % sign







