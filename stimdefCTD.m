function Params = stimdefCTD(EXP);
% stimdefCTD - definition of stimulus and GUI for CTD stimulus paradigm
%    P=stimdefCTD(EXP) returns the definition for the CTD (interaural time
%    difference) stimulus paradigm. The definition P is a GUIpiece that 
%    can be rendered by GUIpiece/draw. Stimulus definition like stimdefCTD 
%    are usually called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimCTD.

% ---ITD sweep
ITD = ITDstepper('ITD', EXP, '', 0); % last arg: specify different ITD types or not
% ---Clicks
Clicks = ClickPanel('click parameters', EXP);
% ---Durations
Dur = DurPanelClicks('Durations', EXP, '', 'basicsonly');

% ---Presentation
Pres = PresentationPanel;
% ---Level
Level = SPLpanel('-', EXP);
% ---Carrier frequency
Frequency = FreqPanel('click frequency', EXP);
Clicks = sameextent(Clicks,Frequency,'X'); % adjust width
ITD = sameextent(ITD,Frequency,'X'); % adjust width
% ---Summary
summ = Summary(17);

%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, ITD, nextto(summ), [10 0]);
Params = add(Params, Frequency, below(ITD), [0 10]);
Params = add(Params, Clicks, below(Frequency), [0 4]);
Params = add(Params, Level, nextto(ITD), [10 0]);
Params = add(Params, Dur, below(Level) ,[0 10]);
Params = add(Params, Pres, nextto(Dur) ,[10 0]);
Params = add(Params, PlayTime(), below(Clicks) , [0 10]);




