function P2=makestimBBFC(P)
% MakestimBBFC - stimulus generator for BBFC stimGUI
%    P=MakestimBBFC(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimBBFC is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimBBFC does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimBBFC renders P ready for D/A conversion by adding the following 
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

% Adding the beat frequency
P.StartFreq = P.StartFreq*[1 1];
P.EndFreq = P.EndFreq*[1 1];
% Convention used: beat frequency will be added to contra side
[chanStr, contraChannel] = ear2DAchan('C', P.Experiment);
P.StartFreq(:,contraChannel) = P.StartFreq(:,contraChannel) + P.BeatFreq;
P.EndFreq(:,contraChannel) = P.EndFreq(:,contraChannel) + P.BeatFreq;

% Carrier frequency: add it to stimparam struct P
P.Fcar=EvalFrequencyStepper(figh, '', P); 
if isempty(P.Fcar), return; end
Ncond = size(P.Fcar,1); % # conditions

% SAM (pass Fcar to enable checking of out-of-freq-range sidebands)
okay=EvalSAMpanel(figh,P,P.Fcar, {'StartFreq' 'EndFreq'});
if ~okay, return; end

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Determine sample rate and actually generate the calibrated waveforms
P = toneStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'Fcar', 'Carrier frequency', 'Hz', P.StepFreqUnit);

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, P.Fcar);
if ~okay, return; end


% 'TESTING MAKEDTIMBBFC'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% Summary
ReportSummary(figh, P);

% everything okay: return P
P2=P;











