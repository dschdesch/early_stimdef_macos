function P2=makestimRC(P);
% MakestimRC - stimulus generator for RC stimGUI
%    P=MakestimRC(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimRC is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimRC does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimRC renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by carrier & modulation freqs, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%            Fcar: carrier frequencies [Hz] of all the presentations in an
%                  Nx2 matrix or column array
%             SPL: Intensities [dB SPL] of all the presentations in an
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

% Phase
WavePhase=EvalPhaseStepper(figh, P, ''); 
if isempty(WavePhase), return; end

% SPL
SPL=EvalSPLstepper(figh, '', P); 
if isempty(SPL), return; end

% mix Phase & SPL sweeps; # conditions = # Phases times # SPLs. By
% convention, phase is updated faster. 
[P.SPL, P.WavePhase, P.Ncond_XY] = MixSweeps(SPL, WavePhase);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartSPL' 'StepSPL' 'EndSPL' 'StartPhase' 'StepPhase' 'EndPhase'});
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, P.Ncond_XY);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% No modulation panel
[P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModITD, P.ModTheta] = deal(0);

% Determine sample rate and actually generate the calibrated waveforms
P = toneStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'SPL' 'WavePhase'}, {'Carrier Intensity' 'Carrier phase'}, ...
    {'dB SPL' 'Cycles'}, {'Linear' 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
P.Attenuation.AnaAtten;
P.Attenuation.NumGain_dB;
P.Attenuation.NumScale;

okay = CheckSPL(figh, P.SPL, mxSPL, P.Fcar, '', {'StartSPL' 'EndSPL'});
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;











