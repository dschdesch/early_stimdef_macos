function Params = stimdefCAP(EXP);

%==========Carrier frequency GUIpanel=====================
Fsweep = FrequencyStepper('Frequency range', EXP,'','','nobinaural');
% ---Levels
Levels = SPLstepper('SPL range', EXP,'','','nobinaural');
% ---Presentation
%Pres = PresentationPanelTHR;
Pres = PresentationPanelCAP;
% ---REC STOP
RecStop = GUIpanel('RecStop', '');
Rec = ActionButton('Rec', 'REC', 'REC', 'Start the recording of the threshold curve', @(Src,Ev,LR)CAPstart([]), 'BackgroundColor', [0.65 0.75 0.7]);
Stop = ActionButton('Stop', 'STOP', 'STOP', 'Stop the recording of the threshold curve', @(Src,Ev,LR)CAPstop(), 'BackgroundColor', [0.65 0.75 0.7]);
RecStop = add(RecStop, Rec, 'cornering', [5 -15]);
RecStop = add(RecStop, Stop, nextto(Rec), [5 0]);
%====================
Params = GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, Fsweep);
Params = add(Params, Levels, nextto(Fsweep), [10 0]);
Params = add(Params, Pres, nextto(Levels) ,[5 0]);
Params = add(Params, RecStop, below(Fsweep) ,[50 20]);