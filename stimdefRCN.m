function Params = stimdefRCN(EXP);
% stimdefRCN - definition of stimulus and GUI for RCN stimulus paradigm
%    P=stimdefRCN(EXP) returns the definition for the RCN (Rate Curve with
%    noise) stimulus paradigm. The definition P is a GUIpiece that 
%    can be rendered by GUIpiece/draw. Stimulus definition like stimdefRCN 
%    are usually called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimRCN.

% ---SPL sweep
SPLsweep = SPLstepperRCN('SPL', EXP);
% ---Durations
Dur = DurPanel('-', EXP, '', 'nophase'); % exclude phase query in Dur panel
Dur = sameextent(Dur,SPLsweep,'X'); % adjust width
% ---Pres
Pres = PresentationPanel;
% Noise
Noise = NoisePanelRCN('noise param', EXP);
% ---Summary
summ = Summary(18);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters

Params = add(Params, summ);
Params = add(Params, SPLsweep, nextto(summ), [10 0]);
Params = add(Params, Noise, nextto(SPLsweep), [10 0]);
Params = add(Params, Dur, below(SPLsweep) ,[0 10]);
Params = add(Params, Pres, below(Noise) ,[0 5]);
Params = add(Params, PlayTime(), below(Dur) , [0 5]);



