function Params = stimdefENH_2T(EXP);
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
list_params={{'BF1','freq. 1st comp.',' 1000 ','Hz','rreal/positive','tooltip',1},...
    {'SPL1','level 1st comp',' 100 ','dB SPL','rreal/positive','tooltip',1},...
{'db_comp2','level 2st comp',' 1000 ','side','string','tooltip',1},...
{'delta_T','time btw C and T',' 1000 ','ms','rreal','tooltip',1},...
{'sideT','test side',' L ','','string','tooltip',1},...
{'polarity','polarity',' 0 ','','rreal','tooltip',1},...
{'probe_alone','probe alone',' 0 ','','rreal','tooltip',1}
};
Miscl=Misclpanel('Miscl', EXP, list_params);

durC = DurPanel('duration conditioner', EXP, 'cond', 'basicsonly_mono');
durT = DurPanel('duration test', EXP, 'test', 'basicsonly_mono');

SPL2sweep = SPLstepper('SPL2', EXP);
BF2sweep = FrequencyStepper('BF 2nd comp', EXP);

% ---Pres
Pres = PresentationPanel_XY('BF2', 'SPL2');

summ = Summary(19);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, SPL2sweep, nextto(summ), [10 0]);
Params = add(Params, BF2sweep, nextto(SPL2sweep) ,[10 0]);

Params = add(Params, Miscl, nextto(BF2sweep) ,[0 0]);
Params = add(Params, durC, below(SPL2sweep) ,[10 0]);
Params = add(Params, Pres, nextto(durC) ,[0 0]);
Params = add(Params, durT, below(durC) ,[0 0]);