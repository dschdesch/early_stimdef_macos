function Params = stimdefITD(EXP);
% stimdefITD - definition of stimulus and GUI for ITD stimulus paradigm
%    P=stimdefITD(EXP) returns the definition for the ITD (interaural time
%    difference) stimulus paradigm. The definition P is a GUIpiece that 
%    can be rendered by GUIpiece/draw. Stimulus definition like stimdefITD 
%    are usually called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimITD.

% ---ITD sweep
ITD = ITDstepper('ITD', EXP, '', 1); % last arg: specify different ITD types or not
% ---SAM
Sam = SAMpanel('SAM', EXP, '', 1); % '': no prefix; 1: do include Theta query.
ITD = sameextent(ITD,Sam,'X'); % adjust width of Mod to match PhiSweep
% ---Durations
Dur = DurPanel('Durations', EXP, '', 'basicsonly');
% ---Presentation
Pres = PresentationPanel;
% ---Level
Level = SPLpanel('-', EXP);
% ---Carrier frequency
Frequency = FreqPanel('-', EXP);
Frequency = sameextent(Frequency,Level,'X'); % adjust width of Mod to match PhiSweep
% ---Summary
summ = Summary(20);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, ITD, nextto(summ), [10 0]);
Params = add(Params, Sam, below(ITD), [0 4]);
Params = add(Params, Frequency, nextto(ITD), [10 0]);
Params = add(Params, Level, below(Frequency), [0 10]);
Params = add(Params, Dur, below(Level) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[5 -10]);
Params = add(Params, PlayTime(), below(Sam) , [0 10]);




