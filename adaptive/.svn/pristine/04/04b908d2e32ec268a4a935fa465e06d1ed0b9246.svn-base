function Params = stimdefTHR_TCKL(EXP);

list_params={{'Freq','freq probe','10000','','rreal','tooltip',1},
    {'rep_for_SR','#reps for spontaneous','10000','','rreal','tooltip',1}
};
Miscl=Misclpanel('Miscl', EXP, list_params);


% ---Levels
Levels = SPLstepper('SPL range', EXP'','','nobinaural');

Fsweep_masker = FrequencyStepper('Freq tckl', EXP,'','','nobinaural');

Levels_masker = dB_maskerstepper('SPL tckl', EXP'','','nobinaural');



% ---Presentation
Pres = PresentationPanelTHR;
% Pres = PresentationPanelTHR_Geisler;
% ---REC STOP
RecStop = GUIpanel('RecStop', '');
Rec = ActionButton('Rec', 'REC', 'REC', 'Start the recording of the threshold curve', @(Src,Ev,LR)THRstart_tckl([]), 'BackgroundColor', [0.65 0.75 0.7]);
Stop = ActionButton('Stop', 'STOP', 'STOP', 'Stop the recording of the threshold curve', @(Src,Ev,LR)THRstop_tckl(), 'BackgroundColor', [0.65 0.75 0.7]);
RecStop = add(RecStop, Rec, 'cornering', [5 -15]);
RecStop = add(RecStop, Stop, nextto(Rec), [5 0]);
%====================
Params = GUIpiece('Params'); % upper half of GUI: parameters
Params = add(Params, Miscl);
Params = add(Params, Levels, nextto(Miscl), [150 0]);
Params = add(Params, Pres, nextto(Levels) ,[5 0]);
Params = add(Params, Levels_masker, below(Levels) ,[0 0]);
Params = add(Params, Fsweep_masker, below(Miscl) ,[0 0]);
Params = add(Params, RecStop, below(Pres) ,[50 20]);