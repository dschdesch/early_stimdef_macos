function P2=makestimWAV(P);
% MakestimWAV - stimulus generator for WAV stimGUI
%    P=MakestimWAV(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimWAV is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimWAV does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimWAV renders P ready for D/A conversion by adding the following 
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
%   See also toneStim, Waveform/maxSPL, Waveform/play, sortConditions, 
%   evalfrequencyStepper.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

[P.WavFile, P.Nwav] = EvalWavPanel(figh, '', P);
if isempty(P.WavFile), return; end

% Create an array of numbers representing the wav files
% Needed for sortConditions and Summary
P.WavFileNb = (1:P.Nwav).';

% Determine sample rate and actually generate the calibrated waveforms
P = wavStim(P); % P contains both Experiment (calib etc) & params

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'WavFileNb', 'File number', '', 'lin');

% Levels and active channels (must be called *after* adding the baseline waveforms)
P.Attenuation = scaleWAV(P.Waveform, P.Experiment);

% the analog attenuators are accurate to 0.1 dB. Take care of rounding
% errors.
RoundingCorrection = P.Att-0.1*floor(10*P.Att);
P.Att = P.Att-RoundingCorrection;
P.Attenuation.AnaAtten = P.Att;

% 'TESTING MAKEDTIMFS'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% Summary
ReportSummary(figh, P);

% everything okay: return P
P2=P;











