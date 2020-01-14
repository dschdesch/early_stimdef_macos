function THRstart_tckl( P )
%THRSTART Summary of this function goes here
%   Detailed explanation goes here

% clear GUI messenger
GUImessage(gcg, ' ');

% run makestimTHR with P as argument
if isempty(P), % obtain info from GUI
    P = GUIval(gcg);
    P.Experiment = current(experiment);
end

P = makestimTHR_TCKL(P);

setGUIdata(gcg,'StimParam.StimType','THR_TCKL');
P.Experiment = promptID(P.Experiment, gcg);

if ~isempty(P)
    % use these arguments to run THRcurve
    MyFlag('THRstop', false);
    THRcurve_tckl(P, P.Proc, P.Freq, P.BurstDur, P.ISI, P.StartSPL, P.EndSPL, P.BeginSPL, P.StepSPL, P.DAC, P.SpikeCrit, P.MaxNPres)
end
end



