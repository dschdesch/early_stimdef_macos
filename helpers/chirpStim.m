function P = chirpStim(P, Prefix); 
% chirpStim - compute chirp stimulus
%   P = chirpStim(P) computes the waveforms of tonal stimulus
%   The carrier frequencies are given by P.Fcar [Hz], which is a column 
%   vector (mono) or Nx2 vector (stereo). The remaining parameters are
%   taken from the parameter struct P returned by GUIval. The Experiment
%   field of P specifies the calibration, available sample rates etc
%   In addition to Fcar and Experiment, the following fields of P are 
%   used to compute the waveforms:
%      StartFreq: starting frequency of sweep
%        EndFreq: holding frequency of sweep
%          upDur: duration of upward part of sweep
%        downDur: duration of downward part of sweep
%        holdDur: duration of holding part of sweep
%      sweepMode: either 'Linear' or 'Logarithmic'
%        ModFreq: modulation frequency in Hz
%       ModDepth: modulation depth in %
%  ModStartPhase: modulation starting phase in cycles (0=cosine)
%         ModITD: ITD for modulation
%            DAC: left|right|both active DAC channel(s)
%       BurstDur: burst duration in ms including ramps
%        RiseDur: duration of onset ramp
%        FallDur: duration of offset ramp
%            ITD: interaural time delay in ms
%        ITDtype: how ITD is imposed (waveform|gating|ongoing)
%            ISI: inter-stimulus interval in ms
%          Order: order of presentation
%            SPL: Sound Pressure Level
%      WavePhase: waveform starting phase
%
%   The output of chirpStim is realized by updating/creating the following 
%   fields of P
%      Fsam: sample rate [Hz] of all waveforms.
%      Fcar: adjusted to slightly rounded values to save memory using cyclic
%            storage (see CyclicStorage).
%      Fmod: modulation frequencies [Hz] in Ncond x Nchan matrix or column 
%            array. Might deviate slightly from user-specified values to
%            facilitate storage (see CyclicStorage).
%      Dur: stimulus duration [ms] in Ncond column array. By convention, this
%           the maximum value of the duration in the two channels.
%    Waveform: Ncond x Nchan Waveform object containing the samples and 
%           additional info for D/A conversion.
%
%   S = chirpStim(P, 'Foo') uses the FooModFreq field of P instead of
%   ModFreq, FooModDepth instead of ModDepth, etc. 
%   This is the same type of prefix as is optionally passed to SAMpanel,
%   DurPanel, etc. The use of a prefix allows the multiple use of a
%   single type of GUIpanel for different components within one stimulus.
%
%   See also makestimFM, ChirpPanel, DurPanel, dePrefix, Waveform.

if nargin<3, Prefix=''; end;
S = [];

P = dePrefix(P, Prefix); % now all params in P have standard names (see dePrefix help text)

% There are Ncond=size(Fcar,1) conditions and Nch DA channels.
% Cast all numerical params in Ncond x Nch size, so we don't have to check
% sizes all the time.
[StartFreq, EndFreq, upDur, downDur, holdDur, ModFreq, ModDepth, ModStartPhase, BurstDur, RiseDur, FallDur, WavePhase, ITD, ModITD, SPL] ...
    = SameSize(P.StartFreq, P.EndFreq, P.upDur, P.downDur, P.holdDur, P.ModFreq, P.ModDepth, P.ModStartPhase, P.BurstDur, ...
    P.RiseDur, P.FallDur, P.WavePhase, P.ITD, P.ModITD, P.SPL);
ModFreq = ModFreq.*(ModDepth~=0); % set ModFreq to zero if ModDepth vanishes ...
ModDepth = ModDepth.*(ModFreq~=0); % ... and vice versa
% sign convention of ITD is specified by Experiment. Convert ITD to a nonnegative per-channel delay spec 
Delay = ITD2delay(ITD(:,1), P.Experiment); 
ModDelay = ITD2delay(ModITD(:,1), P.Experiment);
ModDelay = ModDelay-SameSize(mean(ModDelay,2),ModDelay); % modulation delay is implemented symmetrically
% Restrict the parameters to the active channels. If only one DA channel is
% active, DAchanStr indicates which one.
[DAchanStr, StartFreq, EndFreq, upDur, downDur, holdDur, ModFreq, ModDepth, ModStartPhase, BurstDur, RiseDur, FallDur, WavePhase, Delay, ModDelay, SPL] ...
    = channelSelect(P, 'LR', StartFreq, EndFreq, upDur, downDur, holdDur, ModFreq, ModDepth, ModStartPhase, BurstDur, RiseDur, FallDur, WavePhase, Delay, ModDelay, SPL);

Fmax = max([StartFreq EndFreq]);

% find the single sample rate to realize all the waveforms while  ....
Fsam = sampleRate(Fmax+ModFreq, P.Experiment); % accounting for recording requirements minADCrate

% now compute the stimulus waveforms condition by condition, ear by ear.
[Ncond, Nchan] = size(StartFreq);
[P.Fcar, P.Fmod] = deal(zeros(Ncond, Nchan));
for ichan=1:Nchan,
    chanStr = DAchanStr(ichan); % L|R
    % compute the waveform
    w = local_Chirp(chanStr, P.Experiment, Fsam, P.ISI, ...
        Delay(1,ichan), P.ITDtype, RiseDur(1,ichan), FallDur(1,ichan), ...
        WavePhase(1,ichan), ModDepth(1,ichan), ModStartPhase(1,ichan), ModDelay(1,ichan), SPL(1,ichan), ...
         StartFreq(1,ichan), EndFreq(1,ichan), upDur(1,ichan), downDur(1,ichan), holdDur(1,ichan), P.SweepMode, Nchan);
    P.Waveform(1,ichan) = w;
    P.Fcar = StartFreq;
    P.Fmod = ModFreq;
    
end
P.Duration = SameSize(max(P.BurstDur,[],2), (1:Ncond)'); 
P.Fsam = Fsam;
% make P.Waveform a waveform object
P.Waveform = Waveform(P.Waveform);
% plot(P.Waveform(1,:),'marker', '.');



function [W, SamCount]=local_Chirp_Tones(W, Nsam, Nrep, SamCount, ComplexValued, Sweep, Win);
if nargin<7, Win=1; end % default: no windowing
%disp('==============='); SamCount, Nsam
if isequal(0,Nsam) || isequal(0,Nrep), return; end; % nothing to add - don't do it
isam = SamCount+(1:Nsam); % isam is base-zero sample range counted from onset
P = W.Param; % elementary stimulus parameters

w = Sweep(isam);

if ~ComplexValued, w = real(w); end
W.Samples{end+1} = Win.*w; % add windowed w to waveform collection
W.Nrep(end+1) = Nrep; % # reps of the cycled buffer
SamCount = SamCount + Nsam; % Keep track of # stored samples since burst onset - needed for starting phase of subsequent segments
W.MaxMagSam = max(W.MaxMagSam, max(abs(W.Samples{end}))); % update max magnitude

function W = local_Chirp(DAchan, EXP, Fsam, ISI, ITDdelay, ITDtype, RiseTime, FallTime, ...
    WavePhase, ModDepth, ModStartPhase, ModDelay, SPL, StartFreq, EndFreq, upDur, downDur, holdDur, SweepMode, Nchan)
% Generate the waveform from the elementary parameters
%=======TIMING, DURATIONS & SAMPLE COUNTS=======
% Stimulus is cut from virtual buffer, then placed in waveform interval.
% First find out where to place the different portions in the waveform.
% disp('-------------')
% disp(collectInStruct(DAchan, CT, Fsam, ISI, ITDdelay, ITDtype, RiseTime, FallTime, C, WavePhase, ModDepth, ModStartPhase))
BurstDur = upDur + holdDur + downDur;
Dur = CollectInStruct(RiseTime, BurstDur, FallTime, ISI);
[Nsam, Timing, RiseWin, FallWin]=DelayRecipe(EXP, Fsam, DAchan, ITDdelay, ITDtype, Dur,Nchan);
%Nsam, Timing

NsamCyc = Nsam.Nsteady;  % total # samples in steady-state portion
NrepCyc = 1; % # reps of cyclic buffer
NsamTail = 0; % No tail buffer

%=======FREQUENCIES and CALIBRATION=======
if isequal(SweepMode,'Linear')
    InstFreqUp = linspace(StartFreq,EndFreq,1e-3*upDur*Fsam).'; % instantaneous freq during up sweep
    InstFreqDown = linspace(EndFreq,StartFreq,1e-3*downDur*Fsam).'; % instantaneous freq during down sweep
else
    InstFreqUp = logispace(StartFreq,EndFreq,1e-3*upDur*Fsam).'; % instantaneous freq during up sweep
    InstFreqDown = logispace(EndFreq,StartFreq,1e-3*downDur*Fsam).'; % instantaneous freq during down sweep
end
InstFreqHold = EndFreq*ones(round(1e-3*holdDur*Fsam),1); % instantaneous freq during hold

% Concatenate the 3 parts of the sweep
InstFreq = [InstFreqUp; InstFreqHold; InstFreqDown];

RadPerSam = 2*pi*InstFreq/Fsam; % convert Hz -> radians/sample
InstPhase = cumsum([0; RadPerSam]); % instantaneous phase in radians

% InstFeq now is freq between consecutive samples, not @ samples themselves. Extrapolate.
InstFreq = InstFreq([1 1:end end]);
InstFreq = 0.5*(InstFreq(1:end-1)+InstFreq(2:end));

% Calibrate
[calibDL, calibDphi] = calibrate(EXP, Fsam, DAchan, InstFreq);
% waveform is generated @ the target SPL. Scaling is divided
% between numerical scaling and analog attenuation later on.
Amp = dB2A(SPL)*sqrt(2)*dB2A(calibDL); % numerical linear amplitudes of the carrier ...
% Compute phase of numerical waveform at start of onset, i.e., first sample of rising portion of waveform.
StartPhase = 2*pi*(WavePhase + calibDphi + 1e-3*Timing.CutOffset.*StartFreq); % CutOffset is realized in freq domain

% Calculate sweep waveform
Sweep = Amp.*sqrt(2).*exp(i*(StartPhase + InstPhase)); % complex analytic waveform; RMS of real part is Amp

% start assembling the waveform W, segment by segment
MaxMagSam = 0; % maximum sample magnitude; will be updated by local_Chirp_Tones
Param = CollectInStruct(Nsam, Timing, RadPerSam, Amp, StartPhase, SPL);
W = CollectInStruct(Fsam, DAchan, MaxMagSam, SPL, Param);
W.Samples = {}; W.Nrep = []; 
Cmplx = logical(EXP.StoreComplexWaveforms); % if true, store complex analytic waveforms, real part otherwise
% ---first segment ("Pre"): heading silence. This is now stored as a ...
W.Samples{end+1} = 0; % ... repetition of single zeros, which can ...
W.Nrep(end+1) = Nsam.Npre; % ...later be converted to a more efficient data format.
SamCount = 0; % samples since start of onset (=start of rising segment)
% ---second segment ("Rise"): rising portion of the waveform
[W, SamCount]=local_Chirp_Tones(W, Nsam.Nrise, 1, SamCount, Cmplx, Sweep, RiseWin); % 1 = one rep
% ---third segment ("Cycle"): cycled portion of the steady state
[W, SamCount]=local_Chirp_Tones(W, NsamCyc, NrepCyc, SamCount, Cmplx, Sweep);
% ---fourth segment ("Tail"): remainder of steady state portion following cycled segment
[W, SamCount]=local_Chirp_Tones(W, NsamTail, 1, SamCount, Cmplx, Sweep); % 1 = one rep
% ---fifth segment ("Fall"): falling portion of the waveform
[W, SamCount]=local_Chirp_Tones(W, Nsam.Nfall, 1, SamCount, Cmplx, Sweep, FallWin); % 1 = one rep
% ---sixth segment ("Post"): tailing silence. Same story as "Pre" above
W.Samples{end+1} = 0; W.Nrep(end+1) = Nsam.Npost;



