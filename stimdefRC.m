function Params = stimdefRC(EXP)
% stimdefRC - definition of stimulus and GUI for RC stimulus paradigm
%    P=stimdefRC(EXP) returns the definition for the RC (Rate Curve)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefFS are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimRC.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---Phase sweep
Phisweep = PhaseStepper('phase', EXP, '');

% ---SPL sweep
SPLsweep = SPLstepper('SPL', EXP);

% ---Carrier frequency
Frequency = FreqPanel('carrier frequency', EXP);
Phisweep = sameextent(Phisweep,Frequency,'X'); % adjust width

% ---Durations
Dur = DurPanel('-', EXP, '', 'nophase'); % exclude phase query in Dur panel
Dur = sameextent(Dur,Phisweep,'X'); % adjust width

% ---Pres
Pres = PresentationPanel_XY('Phase', 'SPL');
SPLsweep = sameextent(SPLsweep,Pres,'X'); % adjust width
% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters

Params = add(Params, summ);
Params = add(Params, SPLsweep, nextto(summ), [10 0]);
Params = add(Params, Pres, below(SPLsweep) ,[0 10]);
Params = add(Params, Phisweep, nextto(SPLsweep), [10 0]);
Params = add(Params, Frequency, below(Phisweep), [0 10]);
Params = add(Params, Dur, below(Frequency) ,[0 10]);
Params = add(Params, PlayTime, below(summ) , [0 10]);




