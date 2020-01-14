function P2=makestimENH_condBurstDur(P);


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

% condBurstDur
condBurstDur =EvalcondBurstDurstepper(figh, '', P); 

if isempty(condBurstDur), return; end

% mix width & condBurstDur sweeps; # conditions = # Freqs times # delta_Ts. By
% convention, freq is updated faster. 
[P.notchW, P.condBurstDur, P.Ncond_XY] = MixSweeps(notchW, condBurstDur);
maxNcond = P.Experiment.maxNcond;
if prod(P.Ncond_XY)>maxNcond,
    Mess = {['Too many (>' num2str(maxNcond) ') stimulus conditions.'],...
        'Increase stepsize(s) or decrease range(s)'};
    GUImessage(figh, Mess, 'error', {'StartW' 'StepW' 'EndW' 'StartcondBurstDur' 'StepcondBurstDur' 'EndcondBurstDur' });
end

% Process visiting order of stimulus conditions
VisitOrder = EvalPresentationPanel_XY(figh, P, P.Ncond_XY);
if isempty(VisitOrder), return; end

P.condFallDur=P.testFallDur;
P.condRiseDur=P.testRiseDur;
P.condOnsetDelay=P.testOnsetDelay;
% Determine sample rate and actually generate the calibrated waveforms
P = enhancement_harmonicStim(P); % P contains both Experiment (calib etc) & params, including P.Fcar 

% Sort conditions, add baseline waveforms (!), provide info on varied parameter etc
P = sortConditions(P, {'notchW' 'condBurstDur'}, {'Notch width' 'condBurstDur'}, ...
    {'Hz' 'ms'}, {P.StepWUnit 'Linear'});

% Levels and active channels (must be called *after* adding the baseline waveforms)
[mxSPL P.Attenuation] = maxSPL(P.Waveform, P.Experiment);
okay=EvalSPLpanel(figh,P, mxSPL, []);
if ~okay, return; end



% Summary
ReportSummary(figh, P);
P2=P;
