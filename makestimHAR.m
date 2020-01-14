function P2=makestimHAR(P);
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

% F01
P.Fcar=EvalFrequencyStepper(figh, '', P); 
if isempty(P.Fcar), return; end
Ncond = size(P.Fcar,1); % # conditions

P.WavePhase = 0;

% split ITD in different types
[P.FineITD, P.GateITD, P.ModITD] = ITDparse(P.ITD, P.ITDtype);

% no heterodyning for this protocol
[P.IFD, P.IPD] = deal(0); % zero interaural frequency difference

% Durations & PlayTime messenger
okay=EvalDurPanel(figh, P, Ncond);
if ~okay, return; end

% Determine sample rate and actually generate the calibrated waveforms
P = harmonicStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'Fcar', 'First fundamental frequency', 'Hz', P.StepFreqUnit);

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
if (P.F01DAC(1)=='B' || P.F02DAC(1)=='B') || (P.F01DAC(1)=='R' && P.F02DAC(1)=='L') || ...
        (P.F02DAC(1)=='R' && P.F01DAC(1)=='L')
    P.Attenuation.AnaAtten(2) = P.Attenuation.AnaAtten(1);
    P.Attenuation.NumScale(:,2) = P.Attenuation.NumScale(:,1);
    P.Attenuation.NumGain_dB(:,2) = P.Attenuation.NumGain_dB(:,1);
end
okay=EvalSPLpanel(figh,P, mxSPL, P.Fcar*min(P.F02F01,1));
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
