function Params = stimdefENH_w(EXP);
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
list_params={{'ftype','filter type',' LP','','rreal/positive','tooltip',1},...
{'minf','TODO',' 10000 ','Hz','rreal/positive','tooltip',1},...
};
Miscl=Misclpanel('Miscl', EXP, list_params);

% ---Durations
Dur = DurPanel('duration', EXP, '', 'basicsonly');

Fsweep = FrequencyStepper('center frequency', EXP);
Wsweep = notch_Wstepper('notch width', EXP);

Noise = NoisePanel('noise param', EXP,'','Corr');



% ---Pres
Pres = PresentationPanel_XY('W', 'SPL');

summ = Summary(19);
%====================

% Miscl,Dur,Fsweep,Wsweep,Noise,Pres

Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, Fsweep, nextto(summ), [10 0]);
Params = add(Params, Noise, nextto(Fsweep) ,[10 0]);
Params = add(Params, Wsweep, below(Fsweep) ,[0 0]);
Params = add(Params, Pres, nextto(Wsweep) ,[0 0]);
Params = add(Params, Dur, below(Wsweep) ,[0 0]);
Params = add(Params, Miscl, below(Pres) ,[40 0]);