function P2=makestimMTF(P);
% MakestimMTF - stimulus generator for MTF stimGUI
%    P=MakestimMTF(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimMTF is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimMTF does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimMTF renders P ready for D/A conversion by adding the following 
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

% check & convert params. Note that helpers like evalfrequencyStepper
% report any problems to the GUI and return [] or false in case of problems.

% SAM (pass Fcar to enable checking of out-of-freq-range sidebands)
[okay, P.ModFreq]=EvalSAMStepper(figh,'',P,P.Fcar);
if ~okay, return; end
Ncond = size(P.ModFreq,1); % # conditions


% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Determine sample rate and actually generate the calibrated waveforms
P = toneStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'ModFreq', 'Modulation frequency', 'Hz', P.StepModFreqUnit);

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, P.Fcar);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

% 'TESTING MAKEDTIMMTF'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% everything okay: return P
P2=P;











