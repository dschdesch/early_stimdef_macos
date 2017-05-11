function CAPstart( P )
%CAPSTART Summary of this function goes here
%   Detailed explanation goes here

% clear GUI messenger
GUImessage(gcg, ' ');

% run makestimCAP with P as argument
if isempty(P), % obtain info from GUI
    P = GUIval(gcg);
    P.Experiment = current(experiment);
end
P = makestimCAP(P);

if ~isempty(P)
    % use these arguments to run CAPcurve
    MyFlag('CAPstop', false);
    CAPcurve(P, P.Freq, P.BurstDur, P.StartSPL, P.EndSPL, P.BeginSPL, P.StepSPL, P.DAC, P.MaxNPres);
end
end

