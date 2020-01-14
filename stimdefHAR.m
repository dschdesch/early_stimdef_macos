function Params = stimdefHAR(EXP);
% stimdefARMIN - definition of stimulus and GUI for ARMIN stimulus paradigm
%    P=stimdefARMIN(EXP) returns the definition for the ARMIN
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefARMIN are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimARMIN, stimparamsARMIN.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% ---Levels
Levels = SPLpanelHAR('-', EXP);
%==========Carrier frequency GUIpanel=====================
Fsweep = FrequencyStepperHAR('frequencies', EXP, '', '', 'nobinaural');

% ---Durations
Dur = DurPanel('-', EXP, '', 'nophase');
% ---Pres
Pres = PresentationPanel;
Pres = sameextent(Pres,Dur,'X');
% ---Summary
summ = Summary(19);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Levels, nextto(summ), [10 0]);
Params = add(Params, Fsweep, below(Levels) ,[0 5]);
Params = add(Params, Dur, nextto(Levels) ,[10 0]);
Params = add(Params, Pres, below(Dur) ,[0 5]);
Params = add(Params, PlayTime, below(Fsweep) , [0 5]);




