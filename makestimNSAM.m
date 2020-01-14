function P2=makestimNSAM(P);
% makestimNSAM - stimulus generator for RCN stimGUI
%    P=makestimNSAM(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimRCN is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimRCN does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    makestimNSAM renders P ready for D/A conversion by adding the following 
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
%   See also stimdefRCN.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalphaseStepper
% report any problems to the GUI and return [] or false in case of problems.

% Noise parameters (SPL cannot be checked yet)
[okay, P.NoiseSeed] = EvalNoisePanel(figh, P);
if ~okay, return; end

% no heterodyning for this protocol
[P.IFD, P.IPD] = deal(0); % zero interaural frequency difference

% SAM (pass Fcar to enable checking of out-of-freq-range sidebands)
[okay, P.ModFreq]=EvalSAMStepper(figh, '', P,[P.LowFreq P.HighFreq]); 
if ~okay, return; end
Ncond = size(P.ModFreq,1); % # conditions

% split ITD in different types
[P.FineITD, P.GateITD, P.ModITD] = ITDparse(P.ITD, P.ITDtype);

% no heterodyning for this protocol
P.IFD = 0; % zero interaural frequency difference

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, Ncond);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Use generic noise generator to generate waveforms
P = noiseStim(P); 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, 'ModFreq', 'Modulation Frequency', 'Hz', 'lin');

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay = CheckSPL(figh, P.SPL, mxSPL, [], 'MaxSPL', 'SPL');
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;
