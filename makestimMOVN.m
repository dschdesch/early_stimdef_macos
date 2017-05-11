function P2=makestimMOVN(P)
% MakestimMOVN - stimulus generator for MOVN stimGUI
%    P=MakestimMOVN(P), where P is returned by GUIval, generates the stimulus
%    specified in P. MakestimMOVN is typically called by StimGuiAction when
%    the user pushes the Check, Play or PlayRec button.
%    MakestimMOVN does the following:
%        * Complete check of the stimulus parameters and their mutual
%          consistency, while reporting any errors
%        * Compute the stimulus waveforms
%        * Computation and broadcasting info about # conditions, total
%          stimulus duration, Max SPL, etc.
%
%    MakestimMOVN renders P ready for D/A conversion by adding the following 
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
%   See also stimdefMOVN.

P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

% check & convert params. Note that helpers like evalITDStepper
% report any problems to the GUI and return [] or false in case of problems.

% Check if both channels are activated.
if ~isequal('Both', P.Experiment.AudioChannelsUsed) || ~isequal(P.DAC,'Both')
    Mess = {'Both channels are required for this stimulus.'};
    GUImessage(figh,Mess,'error');
end

% ITDSpeed: add it to stimparam struct P
ITDSpeed = EvalITDSpeedStepper(figh, P); 
if isempty(ITDSpeed), return; end

% Noise seed
NoiseSeed = EvalSeedStepper(figh,P);
if isempty(NoiseSeed), return; end

% mix Noise seed & ITD speed sweeps; # conditions = # seeds times # speeds. By
% convention, Noise seed is updated faster. 
[P.NoiseSeed, P.ITDSpeed, P.Ncond_XY] = MixSweeps(NoiseSeed, ITDSpeed);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'startSeed' 'stepSeed' 'endSeed' 'startSpeed' 'stepSpeed' 'endSpeed' });
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

% Durations & PlayTime; this also adds ITD, FineITD, GateITD, ModITD fields to
% P (however zero for this stimulus; ITD is handled in another way) 
[okay, P]=EvalMovNoiseDurPanel(figh, P, P.Ncond_XY);
if ~okay, return; end

% no modulation for this protocol
[P.ModFreq, P.ModDepth, P.ModStartPhase, P.ModTheta, P.IPD] = deal(0);

% Use moving noise generator to generate waveforms
P = movNoiseStim(P); 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'NoiseSeed' 'ITDSpeed'}, {'Noise seed' 'Interaural speed'}, ...
    {'' 'us/s'}, {'Linear' 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end

% Summary
ReportSummary(figh, P);

P2=P;
