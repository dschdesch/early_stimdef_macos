function P2=makestimARMIN(P);
% MakestimARMIN - stimulus generator for ARMIN stimGUI
%    P=MakestimARMIN(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimARMIN is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimARMIN does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimARMIN renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by carrier & modulation freqs, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%            Fcar: carrier frequencies [Hz] of all the presentations in an
%                  Nx2 matrix or column array
%        Waveform: Waveform object array containing the samples in SeqPlay
%                  format.
%     Attenuation: scaling factors and analog attuater settings for D/A
%    Presentation: struct containing detailed info on stimulus order,
%                  broadcasting of D/A progress, etc.
% 
%   See also noiseStim, Waveform/maxSPL, Waveform/play, sortConditions

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalfrequencyStepper
% report any problems to the GUI and return [] or false in case of problems.

% Flip frequency: add it to stimparam struct P
P.FlipFreq=EvalFrequencyStepperARMIN(figh, '', P); 
P.FlipFreq=[P.LowFreq; P.HighFreq; P.FlipFreq]; % Add the Endpoints to the flip frequencies
if isempty(P.FlipFreq), return; end
Ncond = size(P.FlipFreq,1); % # conditions

% split ITD in different types
[P.FineITD, P.GateITD, P.ModITD] = ITDparse(P.ITD, P.ITDtype);

% no heterodyning for this protocol
[P.IFD, P.IPD] = deal(0); % zero interaural frequency difference

% ARMIN parameter
P.Corr = -1;

% Noise parameters (SPL cannot be checked yet)
[okay, ~,P] = EvalNoisePanel(figh, P);
if ~okay, return; end

% SAM (pass noise cutoffs to enable checking of out-of-freq-range sidebands)
% okay=EvalSAMpanel(figh, P, [P.LowFreq P.HighFreq], {'LowFreqEdit' 'HighFreqEdit'});
% if ~okay, return; end

% mix Freq & SPL sweeps; # conditions = # Freqs times # SPLs. By
% convention, freq is updated faster. 
[P.FlipFreq, P.SPL, P.Ncond_XY] = MixSweeps(P.FlipFreq, P.SPL);
P.SPLUnit = 'dB SPL';
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartFreq' 'StepFreq' 'EndFreq' 'StartSPL' 'StepSPL' 'EndSPL' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Durations & PlayTime messenger
okay=EvalDurPanel(figh, P, P.Ncond_XY);
if ~okay, return; end

% Determine sample rate and actually generate the calibrated waveforms
P = noiseStimARMIN(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Reduce storage of waveforms by setting some fields for play out
P.ReducedStorage = {'',''};
Chan = 'LR';
CorrChan = ipsicontra2LR(P.CorrChan, P.Experiment);
P.ReducedStorage{Chan~=CorrChan} = 'nonzero';
P.RX6_circuit = ['RX6seqplay-trig-2ADC'];

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'FlipFreq','SPL'}, {'Flip frequency','Intensity'}, {'Hz','dB SPL'}, {P.StepFreqUnit, 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end


% 'TESTING MAKEDTIMFS'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% Summary
ReportSummary(figh, P);

% everything okay: return P
P2=P;

% % Check if ARMIN produces the correct results by adding signals and
% % taking FFT
% sam = samples(P.Waveform(1,:));
% y = sam(:,1) + sam(:,2);
% Fs = P.Fsam;                    % Sampling frequency
% T = 1/Fs;                     % Sample time
% L = size(y,1);                     % Length of signal
% t = (0:L-1)*T;                % Time vector
% 
% NFFT = 2^nextpow2(L); % Next power of 2 from length of y
% Y = fft(y,NFFT)/L;
% f = Fs/2*linspace(0,1,NFFT/2+1);
% 
% % Plot single-sided amplitude spectrum.
% plot(f,2*abs(Y(1:NFFT/2+1))) 
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency (Hz)')
% ylabel('|Y(f)|')
