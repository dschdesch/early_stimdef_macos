function P2=makestimCSPL(P);
% MakestimCSPL - stimulus generator for CSPL stimGUI
%    P=MakestimCSPL(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimCSPL is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimCSPL does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max CSPL, etc.
%
%    MakestimCSPL renders P ready for D/A conversion by adding the following 
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

% SPL stepper: add it to stimparam struct P
P.SPL=EvalSPLstepper(figh, '', P); 
if isempty(P.SPL), return; end
Ncond = size(P.SPL,1); % # conditions

% No advanced duration settings
P.WavePhase = 0;
P.RiseDur = 0;
P.FallDur = 0;
P.ITDtype = 'fine';

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Convert pulse type
P.PulseTypeStr = P.PulseType;
P.PulseType = EvalClickPanel(figh, '', P);

% Determine sample rate and actually generate the calibrated waveforms
P = clickStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'SPL', 'Click intensity', 'dB SPL', {P.SPL 'Linear'}  );

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay = CheckSPL(figh, P.SPL, mxSPL, P.Fcar, '', {'StartSPL' 'EndSPL'});
if ~okay, return; end



% 'TESTING MAKEDTIMCSPL'
% P.Duration
% P.Duration = []; % 
% P.Fcar = [];

% Summary
ReportSummary(figh, P);

% everything okay: return P
P2=P;











