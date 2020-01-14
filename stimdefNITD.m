function Params = stimdefNITD(EXP);
% stimdefNITD - definition of stimulus and GUI for NITD stimulus paradigm
%    P=stimdefNITD(EXP) returns the definition for the NITD (noise-ITD)
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefZW are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimNITD.

% ---Noise
Noise = NoisePanel('noise param', EXP); % include SPL etc
% ---ITD
ITD = ITDstepper('ITD', EXP, '', 0); % last arg: specify different ITD types or not
% ---Durations
Dur = DurPanel('Durations', EXP, '', 'basicsonly');
% ---Pres
Pres = PresentationPanel;
% ---Summary
summ = Summary(17);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Noise, nextto(summ), [10 0]);
Params = add(Params, ITD, below(Noise));
Params = add(Params, Dur, nextto(Noise), [20 0]);
Params = add(Params, Pres, below(Dur) ,[0 2]);
Params = add(Params, PlayTime(), below(ITD) ,[0 5]);




