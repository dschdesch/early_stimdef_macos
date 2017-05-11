function P2=makestimIRN(P)
% MakestimIRN - stimulus generator for IRN stimGUI
%    P=MakestimIRN(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimIRN is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimIRN does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimIRN renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by carrier & modulation freqs, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
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

% SPL
SPL=EvalSPLstepper(figh, '', P); 
if isempty(SPL), return; end

% delay of the added waveform
delta_T = Evaldelta_Tstepper(figh, '', P);
if isempty(delta_T), return; end

% mix SPL & Delay sweeps; # conditions = # SPLs times # Delays. By
% convention, delay is updated faster. 
[P.IRND, P.SPL, P.Ncond_XY] = MixSweeps(delta_T, SPL);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'Startdelta_T' 'Stepdelta_T' 'Enddelta_T' 'StartSPL' 'StepSPL' 'EndSPL' });
    return;
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Durations & PlayTime; this also parses ITD/ITDtype and adds ...
[okay, P]=EvalDurPanel(figh, P, P.Ncond_XY);% ... FineITD, GateITD, ModITD fields to P
if ~okay, return; end

% Check if requested delays are possible
if ~(P.Niter*max(P.IRND) < P.BurstDur),
    GUImessage(figh,'Total delay of last added waveform(s) exceeds burst duration.', ...
        'error', {'Niter' 'BurstDur' 'Startdelta_T' 'Enddelta_T'});
    return;
end

% Temporarily set some params
% no heterodyning for this protocol; zero interaural frequency difference
[P.IFD, P.IPD, P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModITD, P.ModTheta] = deal(0);

% Determine sample rate and actually generate the calibrated waveforms
P = iterNoiseStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'IRND' 'SPL'}, {'Delay of the added waveform(s)' 'Carrier Intensity'}, ...
    {'ms' 'dB SPL'}, {P.Stepdelta_TUnit 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay = EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;