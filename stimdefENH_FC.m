function Params = stimdefENH_FC(EXP);
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
list_params={{'dBdiff','C level relative to T',' 100 ','dB','rreal','tooltip',1},...
    {'notchW','notch width',' 1 ','oct','rreal/positive','tooltip',1},...
{'delta_T','time btw C and T',' 1000 ','ms','rreal','tooltip',1},...
{'sband','side band',' B ','','string','tooltip',1},...
{'stim_type','stim type',' B ','','string','tooltip',1}
};
Miscl=Misclpanel('Basic params', EXP, list_params);

list_params={{'sideT','test side',' L ','','string','tooltip',1},...
{'polarity','polarity',' 0 ','','rreal','tooltip',1},...
{'minf','min. frequency',' 10000 ','Hz','rreal/positive','tooltip',1},...
{'maxf','max. frequency',' 10000 ','Hz','rreal/positive','tooltip',1},...
{'probe_alone','probe alone',' 0 ','','rreal','tooltip',1}
};
Miscl2=Misclpanel('Miscl', EXP, list_params);

% ---Levels of test
Levels = SPLpanel('Test level', EXP);

durC = DurPanel('duration conditioner', EXP, 'cond', 'basicsonly_mono');
durT = DurPanel('duration test', EXP, 'test', 'basicsonly_mono');

% Levels = SPLpanel('-', EXP);

FCsweep = FrequencyStepper('notch center frequency', EXP)

% ---Pres
Pres = PresentationPanel_XY('W', 'dBdiff');

summ = Summary(19);
%====================
Params=GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, summ);
Params = add(Params, FCsweep, nextto(summ), [10 0]);
Params = add(Params, Miscl, nextto(FCsweep) ,[10 0]);
Params = add(Params, Levels, below(Miscl) ,[ 0 0]);
Params = add(Params, Miscl2, nextto(Miscl) ,[0 0]);
Params = add(Params, durC, below(FCsweep) ,[10 0]);
Params = add(Params, Pres, nextto(durC) ,[0 170]);
Params = add(Params, durT, below(durC) ,[0 0]);