function P2=makestimCTD(P);
% MakestimCTD - stimulus generator for CTD stimGUI
%    P=MakestimCTD(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimCTD is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimCTD does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimCTD renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by the stimulus spectrum, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%           Phase: column array of phases realizing the phase steps.
%        Waveform: Waveform object array containing the samples in SeqPlay
%                  format.
%     Attenuation: scaling factors and analog attuater settings for D/A
%    Presentation: struct containing detailed info on stimulus order,
%                  broadcasting of D/A progress, etc.
% 
%   See also stimdefCTD.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalphaseStepper
% report any problems to the GUI and return [] or false in case of
% problems.

% Phase: add it to stimparam struct P
P.ITD=EvalITDstepper(figh, P); 
if isempty(P.ITD), return; end
Ncond = numel(P.ITD);

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
P = sortConditions(P, 'ITD', 'ITD', 'ms', 'lin');

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, P.Fcar);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;








