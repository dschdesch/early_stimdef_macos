function Params = stimdefSPONT( EXP )
% stimdefSPONT - definition of stimulus and GUI for SPONT stimulus paradigm
%    Params=stimdefSPONT(EXP) returns the definition for the SPONT
%    (Spontanious activity) stimulus paradigm. 
%    The definition Params is a GUIpiece that can be rendered
%    by GUIpiece/draw. Stimulus definition like stimmdefSPONT are usually
%    called by StimGUI, which combines the parameter panels with
%    a generic part of stimulus GUIs. The input argument EXP contains 
%    Experiment definition, which co-determines the realization of
%    the stimulus: availability of DAC channels, calibration, recording
%    side, etc.
%
%    See also stimGUI, stimDefDir, Experiment, makestimRC.


% Get the presentation Panel
pres_panel = local_presentation(EXP);
Params=GUIpiece('Params'); % upper half of GUI: parameters

Params = add(Params, pres_panel);

end

function pres_panel = local_presentation (EXP)

% Figure out the recording side
switch EXP.Recordingside,
    case 'Left', Lstr = 'Left=Ipsi'; Rstr = 'Right=Contra';
    case 'Right', Lstr = 'Left=Contra'; Rstr = 'Right=Ipsi';
end
switch EXP.AudioChannelsUsed,
    case 'Left', DACstr = {Lstr};
    case 'Right', DACstr = {Rstr};
    case 'Both', DACstr = {Lstr Rstr 'Both'};
end
ClickStr = ' Click button to select ';

ISI = ParamQuery('ISI', 'ISI:', '15000', 'ms', ...
    'rreal/positive', 'Onset-to-onset interval between consecutive stimuli of a series.',1);
REP = ParamQuery('REP', '#Reps:', '15000', '', ...
    'rreal/positive', 'The amount of times that the stimulus is repeated.',1);
DAC = ParamQuery('DAC', 'DAC:', '', DACstr, ...
    '', ['Active D/A channels.' ClickStr 'channel(s).']);

pres_panel = GUIpanel('pres_panel', 'presentation');
pres_panel = add(pres_panel, REP,'below',[5 0]);
pres_panel = add(pres_panel, ISI,'below',[5 0]);
pres_panel = add(pres_panel, DAC,'below',[5 0]);

pres_panel = marginalize(pres_panel, [0 3]);
end