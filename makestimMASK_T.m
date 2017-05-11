function P2=makestimMASK_T(P);


P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;

delta_T =Evaldelta_Tstepper(figh, '', P); 

% P.minT_maxT = [deltaT(0),deltaT(end)];

delta_T = [-1000000;delta_T];

if isempty(delta_T), return; end

% SPL
SPL=EvalSPLstepper(figh, '', P); 

if length(SPL)>1
    SPL = [-10;SPL];
end


if isempty(SPL), return; end

% mix width & SPL sweeps; # conditions = # Freqs times # SPLs. By
% convention, freq is updated faster. 
[P.delta_T, P.SPL, P.Ncond_XY] = MixSweeps(delta_T, SPL);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'Startdelta_T' 'Stepdelta_T' 'Enddelta_T' 'StartSPL' 'StepSPL' 'EndSPL' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Determine sample rate and actually generate the calibrated waveforms
P = masking_Stim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'delta_T' 'SPL'}, {'delta_T' 'Components Intensity'}, ...
    {'ms' 'dB SPL'}, {P.Stepdelta_TUnit 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end



% Summary
ReportSummary(figh, P);
P2=P;
