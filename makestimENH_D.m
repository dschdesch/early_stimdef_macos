function P2=makestimENH_D(P);


P2 = []; % a premature return will result in []
if isempty(P), return; end
figh = P.handle.GUIfig;


% notch width
% notch width
notchW=EvalnotchW_stepper(figh, '', P); 
notchW(find(notchW==0))=100; %because zero doesnt have a sign
% notchW= [-1;notchW];
notchW= [-notchW(:)';notchW']; %negative is without conditioner
notchW= notchW(:);
if isempty(notchW), return; end

% % SPL
% SPL=evalSPLstepper(figh, '', P); 

% delta_T
delta_T =Evaldelta_Tstepper(figh, '', P); 

if isempty(delta_T), return; end

% mix width & delta_T sweeps; # conditions = # Freqs times # delta_Ts. By
% convention, freq is updated faster. 
[P.notchW, P.delta_T, P.Ncond_XY] = MixSweeps(notchW, delta_T);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartW' 'StepW' 'EndW' 'Startdelta_T' 'Stepdelta_T' 'Enddelta_T' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

% Determine sample rate and actually generate the calibrated waveforms
P = enhancement_harmonicStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'notchW' 'delta_T'}, {'Notch width' 'ISI'}, ...
    {'Hz' 'ms'}, {P.StepWUnit P.Stepdelta_TUnit});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end



% Summary
ReportSummary(figh, P);
P2=P;
