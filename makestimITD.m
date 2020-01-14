function P2=makestimITD(P);
% MakestimITD - stimulus generator for ITD stimGUI
%    P=MakestimITD(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimITD is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimITD does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimITD renders P ready for D/A conversion by adding the following 
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
%   See also stimdefITD.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalphaseStepper
% report any problems to the GUI and return [] or false in case of
% problems.

% SAM (pass Fcar to enable checking of out-of-freq-range sidebands)
okay=EvalSAMpanel(figh,P,P.Fcar);
if ~okay, return; end

% Phase: add it to stimparam struct P
P.ITD=EvalITDstepper(figh, P); 
if isempty(P.ITD), return; end
Ncond = numel(P.ITD);

% No advanced duration settings
P.WavePhase = 0;

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Determine sample rate and actually generate the calibrated waveforms
P = toneStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'ITD', 'ITD', 'ms', 'lin');

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, P.Fcar);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;








