function P2=makestimENH_2T(P);


P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;


BF2=EvalFrequencyStepper(figh, '', P); 
BF2= [-BF2(:)';BF2']; %negative is without conditioner
BF2= BF2(:);
if isempty(BF2), return; end

% SPL
SPL2=EvalSPLstepper(figh, '', P); 
if isempty(SPL2), return; end

% mix width & SPL sweeps; # conditions = # Freqs times # SPLs. By
% convention, freq is updated faster. 
[P.BF2, P.SPL2, P.Ncond_XY] = MixSweeps(BF2, SPL2);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartBF2' 'StepBF2' 'EndBF2' 'StartSPL2' 'StepSPL2' 'EndSPL2' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Determine sample rate and actually generate the calibrated waveforms
P = enhancement_2TonesStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'BF2' 'SPL2'}, {'BF 2nd comp' 'Intensity 2nd comp'}, ...
    {'Hz' 'dB SPL'}, {P.StepFreqUnit 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end



% Summary
ReportSummary(figh, P);
P2=P;
