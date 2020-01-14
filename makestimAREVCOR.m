function P2=makestimAREVCOR(P)
% MakestimARevcor - stimulus generator for ARevcor stimGUI
%    P=MakestimARevcor(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimARevcor is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimARevcor does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimARevcor renders P ready for D/A conversion by adding the following 
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
%   See also stimdefARevcor.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

%
% 
PrecursorFlag = EvalPrecursorFlagStepper(figh, P); 
if isempty(PrecursorFlag), return; end

% Noise seed
NoiseSeed = EvalSeedStepper(figh,P);
if isempty(NoiseSeed), return; end

% mix Noise seed & ITD speed sweeps; # conditions = # seeds times # speeds. By
% convention, Noise seed is updated faster. 
[P.NoiseSeed, P.PrecursorFlag, P.Ncond_XY] = MixSweeps(NoiseSeed, PrecursorFlag);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'startSeed' 'stepSeed' 'endSeed' 'startPrecursorFlag' 'stepPrecursorFlag' 'endPrecursorFlag' });
    return;
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% no heterodyning for this protocol
P.IFD = 0; % zero interaural frequency difference

% Check noise parameters (SPL cannot be checked yet)
[okay] = EvalNoisePanel(figh, P);
if ~okay, return; end

% no modulation for this protocol
[P.ModFreq,P.FineITD,P.GateITD,P.ModITD, P.ModDepth, P.ModStartPhase, P.ModTheta, P.IPD,P.ITD,...
    P.ITDtype] = deal(0);

% Use moving noise generator to generate waveforms
P = ARevcorStim(P); 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'NoiseSeed' 'PrecursorFlag'}, {'Noise seed' 'PrecursorFlag'}, ...
    {'' ''}, {'Linear' 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;
