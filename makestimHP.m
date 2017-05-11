function P2=makestimHP(P)
% MakestimHP - stimulus generator for HP stimGUI
%    P=MakestimHP(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimHP is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%
%    MakestimHP does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimHP renders P ready for D/A conversion by adding the following 
%    fields to P
%            Fsam: sample rate [Hz] of all waveforms. This value is
%                  determined by the stimulus spectrum, but also by
%                  the Experiment definition P.Experiment, which may 
%                  prescribe a minimum sample rate needed for ADC.
%        Waveform: Waveform object array containing the samples in SeqPlay
%                  format.
%     Attenuation: scaling factors and analog attenuator settings for D/A
%    Presentation: struct containing detailed info on stimulus order,
%                  broadcasting of D/A progress, etc.
% 
%   See also stimdefHP.
%   Created by Jeroen
%   Using implementation details from Implementation of Huggins binaural pitch (Molin, 2003)

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% First of all, check if both channels are activated.
if ~isequal('Both', P.Experiment.AudioChannelsUsed) || ~isequal(P.DAC,'Both')
    Mess = {'Both channels are required for this stimulus.'};
    GUImessage(figh,Mess,'error');
end

% Check noise parameters (SPL cannot be checked yet)
[okay, P.NoiseSeed] = EvalNoisePanel(figh, P);
if ~okay, return; end

% Signal band center frequency: add it to stimparam struct P
P.Fc = EvalFrequencyStepper(figh, '', P); 
if isempty(P.Fc), return; end
Ncond = size(P.Fc,1); % # conditions
if P.StartFreq < P.LowFreq
    Mess = {['Fstart must be larger then the lowest Noise frequency!']};
    GUImessage(figh, Mess, 'error', {'StartFreq'});
    return;
end
% no heterodyning and ...
P.IFD = 0; % zero interaural frequency difference
% no modulation for this protocol
[P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModTheta, P.IPD] = deal(0);

% % # chan is 2, see check above
% if (size(P.LowFreq,2) == 1)
%     P.LowFreq = repmat(P.LowFreq,1,2);
% end
% % repeat for later use in noiseStimH
% P.LowFreq = repmat(P.LowFreq,Ncond,1);

% Evaluate the SPL stepper
P.SPL=EvalSPLstepper(figh, '', P); 
if isempty(P.SPL), return; end
P.SPLUnit = 'dB SPL';


% mix Phase & SPL sweeps; # conditions = # Phases times # SPLs. By
% convention, phase is updated faster. 
[P.Fc, P.SPL, P.Ncond_XY] = MixSweeps(P.Fc, P.SPL);
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

% Determine sample rate and actually generate the calibrated Huggin's
% pitches
P = noiseStimH(P);


% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'Fc','SPL'}, {'Band Frequency','Intensity'}, {'Hz','dB SPL'}, {P.StepFreqUnit, 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;