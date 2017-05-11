function P2=makestimNITD(P);
% MakestimNITD - stimulus generator for NITD stimGUI
%    P=MakestimNITD(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimNITD is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimNITD does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimNITD renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by the stimulus spectrum, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%           Phase: column array of phases realizing the phase steps.
%        Waveform: Waveform object array containing the samples in SeqPlay
%                  format.
%     Attenuation: scaling factors and analog attenuator settings for D/A
%    Presentation: struct containing detailed info on stimulus order,
%                  broadcasting of D/A progress, etc.
% 
%   See also stimdefNITD.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalphaseStepper
% report any problems to the GUI and return [] or false in case of problems.

% ITD: add it to stimparam struct P
P.ITD=EvalITDstepper(figh, P); 
if isempty(P.ITD), return; end
Ncond = size(P.ITD,1); % # conditions

% no heterodyning for this protocol
P.IFD = 0; % zero interaural frequency difference

% Noise parameters (SPL cannot be checked yet)
[okay, P.NoiseSeed] = EvalNoisePanel(figh, P);
if ~okay, return; end

% % SAM (pass noise cutoffs to enable checking of out-of-freq-range sidebands)
% okay=evalSAMpanel(figh, P, [P.LowFreq P.HighFreq], {'LowFreqEdit' 'HighFreqEdit'});
% if ~okay, return; end

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

[P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModTheta, P.IPD] = deal(0);

% Use generic noise generator to generate waveforms
% P = noiseStim(P)
% [Note: this new noiseDelayStim implements the NITD stimulus in a slightly 
%  different way and adds a field to indicate that buffer space can be spared
%  when the stimulus is played out.]
P = noiseDelayStim(P); 

% Sort conditions, add baseline waveforms (!), provide info on varied
% parameter etc
P = sortConditions(P, 'ITD', 'ITD', 'ms', 'lin');

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;
