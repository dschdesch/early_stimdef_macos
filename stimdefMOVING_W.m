function Params = stimdefMOVING_W(EXP);
% stimdefENH_w - definition of stimulus and GUI for ENH_w stimulus paradigm
%    P=stimdefENH_w(EXP) returns the definition for the ENH_w
%    stimulus paradigm. The definition P is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefENH_w are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimARMIN, stimparamsARMIN.

PairStr = ' Pairs of numbers are interpreted as [left right].';
ClickStr = ' Click button to select ';
% VF,minf,maxf,deltaT

%Name, Prompt, String, Unit, Constraint, Tooltip
list_params={{'BF','notch center freq.',' 1000 ','Hz','rreal/positive','tooltip',1},...
{'n_octaves','n octave sweept',' 5 ','','rreal/positive','tooltip',1},...
{'interval','update interval',' 50 ','ms','rreal/positive','tooltip',1},...
 {'minspeed','minimum abs seep',' 1 ','Hz/s','rreal/positive','tooltip',1},...
{'order','filter order',' 1000 ','','rreal/positive','tooltip',1},...
{'ftype','filter type','1','','rreal','tooltip',1},...
};




Miscl=Misclpanel('Miscl', EXP, list_params);

dur = DurPanel('duration', EXP, '', 'basicsonly');

speedsweep = speed_stepper('speed', EXP);

Wsweep = notch_Wstepper('notch width', EXP);

% ---Levels
% Levels = SPLpanel('-', EXP);

Noise = NoisePanel('noise param', EXP);

% ---Pres
Pres = PresentationPanel_XY('W', 'speed');

summ = Summary(19);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, speedsweep, nextto(summ), [10 0]);
Params = add(Params, Wsweep, nextto(speedsweep) ,[10 0]);
Params = add(Params, Miscl, below(speedsweep) ,[0 0]);
Params = add(Params, Pres, nextto(Wsweep) ,[0 0]);
Params = add(Params, dur, nextto(Miscl) ,[10 0]);
% Params = add(Params, Levels, below(dur) ,[0 0]);
Params = add(Params, Noise, below(Pres) ,[0 0]);