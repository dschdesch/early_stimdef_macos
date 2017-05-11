function THRstart( P,custom_SR )
%THRSTART start measuring the THR curve
%   Detailed explanation goes here

if nargin<2
    custom_SR = [];
end


% clear GUI messenger
GUImessage(gcg, ' ');

% run makestimTHR with P as argument
if isempty(P), % obtain info from GUI
    P = GUIval(gcg,'THR');
    P.handle.GUIfig = gcg;
    P.Experiment = current(experiment);
end
P.StimType = 'THR';

if custom_SR == -1
   P.RecCustSR = 1; 
end
P = makestimTHR(P);
if isempty(P), return; end
if custom_SR == -1
   custom_SR = P.CustSR; 
else
   custom_SR = -1;
end

setGUIdata(gcg,'StimParam.StimType','THR');

Exp = current(experiment);
CheckFullDS = preferences(Exp);
CheckFullDS = CheckFullDS.CheckFullDsInfo;
if strcmpi(CheckFullDS,'no')
    P.Experiment = promptID(P.Experiment, gcg);
else
    StE = status(Exp);
    ds.ID.iRecOfCell = StE.iRecOfCell+1;
    ds.ID.iCell = max(1, StE.iCell);
    ds.StimType = 'THR';
    P.ds_info = PlayRecordSeqID(ds);
end

% Save the GUI parameters
GUIgrab(gcg,'>');

if ~isempty(P.Experiment)
    % use these arguments to run THRcurve
    MyFlag('THRstop', false);
    %THRcurve_Liberman(P.Experiment, P.Freq, P.BurstDur, P.NonBurstDur, P.StartSPL, P.EndSPL, P.BeginSPL, P.StepSPL, P.DAC, P.SpikeDiffCrit, P.MaxNPres, gcg);
    %THRcurve_Geisler(P, P.Freq, P.BurstDur, P.StartSPL, P.EndSPL, P.BeginSPL, P.StepSPL, P.DAC, P.MaxNPres);
    THRcurve(P, P.Proc, P.Freq, P.BurstDur, P.ISI, P.StartSPL, P.EndSPL, P.BeginSPL, P.StepSPL, P.DAC, P.SpikeCrit, P.MaxNPres, custom_SR);
end
end



