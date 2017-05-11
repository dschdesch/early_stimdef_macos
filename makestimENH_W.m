function P2=makestimENH_W(P);


P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;


% notch width
notchW=EvalnotchW_stepper(figh, '', P); 
notchW(find(notchW==0))=100; %because zero doesnt have a sign
% notchW= [-1;notchW];
notchW= [-notchW(:)';notchW']; %negative is without conditioner
notchW= notchW(:);
if isempty(notchW), return; end

% SPL
SPL=EvalSPLstepper(figh, '', P); 

if isempty(SPL), return; end

% mix width & SPL sweeps; # conditions = # Freqs times # SPLs. By
% convention, freq is updated faster. 
[P.notchW, P.SPL, P.Ncond_XY] = MixSweeps(notchW, SPL);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartW' 'StepW' 'EndW' 'StartSPL' 'StepSPL' 'EndSPL' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Determine sample rate and actually generate the calibrated waveforms
P = enhancement_harmonicStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'notchW' 'SPL'}, {'Notch width' 'Components Intensity'}, ...
    {'Hz' 'dB SPL'}, {P.StepWUnit 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end



% Summary
ReportSummary(figh, P);
P2=P;
