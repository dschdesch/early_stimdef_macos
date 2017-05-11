function P2=makestimMASK_DB(P);


P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

dB_masker =EvaldB_maskerStepper(figh, '', P); 

% P.minT_maxT = [deltaT(0),deltaT(end)];

dB_masker = [-1000000;dB_masker];

if isempty(dB_masker), return; end

% SPL
SPL=EvalSPLstepper(figh, '', P); 

if length(SPL)>1
    SPL = [-10;SPL];
end


if isempty(SPL), return; end

% mix width & SPL sweeps; # conditions = # Freqs times # SPLs. By
% convention, freq is updated faster. 
[P.dB_masker, P.SPL, P.Ncond_XY] = MixSweeps(dB_masker, SPL);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartdB_masker' 'StepdB_masker' 'EnddB_masker' 'StartSPL' 'StepSPL' 'EndSPL' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Determine sample rate and actually generate the calibrated waveforms
P = masking_Stim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'dB_masker' 'SPL'}, {'dB_masker' 'Components Intensity'}, ...
    {'dB SPL' 'dB SPL'}, {P.StepdB_maskerUnit 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end



% Summary
ReportSummary(figh, P);
P2=P;
