function Levels=SPLstepperMBL(T, EXP, Prefix, CmpName);
% SPLstepperMBL - generic panel for stepped SPL and DAchannel in stimulus GUIs.
%   S=SPLstepperMBL(Title, EXP) returns a GUIpanel M named 'Levels' allowing the 
%   user to specify a stepped SPL to be applied to the stimuli of a series.
%   Guipanel S has title Title. EXP is the experiment definition, from 
%   which the number of DAC channels used 
%   (1 or 2) is determined. Title='-' results in standard title 'SPLs & 
%   active channels'
%
%   The paramQuery objects contained in S are
%         MBLSPL: the mean binaural level in db SPL, which is the average
%                 of the SPL of both ears at all times
%         UserMaxSPL: a user provided value to avoid unwanted SPLs when
%                     the user made a mistake
%         ParamEar: the ear for which the parameters are provided (L|R)
%         StartSPL: starting level of stimuli in dB SPL (of ParamEar)
%         StepSPL: step of SPL dB (of ParamEar)
%         EndSPL: end level of stimuli in dB SPL (of ParamEar)
%         AdjustSPL: how to adjust misfitting step requests.
%         DAC: active DA channel
%   The messenger contained in S is
%       MaxSPL: report of max attainable SPL (filled by MakeStimXXX)
%
%   SPLstepperMBL is a helper function for stimulus definitions like stimdefRF.
% 
%   M=SPLstepperMBL(Title, ChanSpec, Prefix, 'Foo') prepends the string Prefix
%   to the paramQuery names, e.g. StartSPL -> NoiseStartSPL, etc, and calls the
%   components whose SPL is set by the name Foo in any error messages.
%
%   Use EvalSPLstepperMBL to check the feasibility of SPLs and to update the 
%   MaxSPL messenger display.
%
%   See StimGUI, GUIpanel, ReportMaxSPL, stimdefFS, SPLstepperMBL.


[Prefix, CmpName] = arginDefaults('Prefix/CmpName', '', 'Carrier');
if isequal('-',T), T = 'SPLs & active channels'; end

PairStr = '';
Nchan = 1;

ClickStr = ' Click button to select ';
switch EXP.Recordingside,
    case 'Left', Lstr = 'Left=Ipsi'; Rstr = 'Right=Contra';
    case 'Right', Lstr = 'Left=Contra'; Rstr = 'Right=Ipsi';
end
switch EXP.AudioChannelsUsed,
    case 'Left', DACstr = {Lstr};
    case 'Right', DACstr = {Rstr};
    case 'Both', DACstr = {Lstr Rstr 'Both'};
end

%&&&&&&&&
MBLSPL = ParamQuery([Prefix 'MBLSPL'], 'MBL:', '-10.5 -10.5', 'dB SPL', ...
    'rreal/positive', [ 'The average of the SPLs of both channels. ' PairStr], Nchan);
UserMaxSPL = ParamQuery([Prefix 'UserMaxSPL'], 'max SPL:', '-10.5 -10.5', 'dB SPL', ...
    'rreal/positive', [ 'SPL limit the stepper may not exceed. ' PairStr], Nchan);
ParamEar = ParamQuery([Prefix 'ParamEar'], 'SPLs of', '', {Lstr Rstr}, ...
    '', ['Ear for which the SPLs are provided.' ClickStr 'channel.']);
StartSPL = ParamQuery([Prefix 'StartSPL'], 'start:', '-10.5 -10.5', 'dB SPL', ...
    'rreal', ['Starting SPL of selected ear.' PairStr], Nchan);
StepSPL = ParamQuery([Prefix 'StepSPL'], 'step:', '1.25 1.25', 'dB', ...
    'rreal/positive', 'SPL step of selected ear.', Nchan);
EndSPL = ParamQuery('EndSPL', 'end:', '120.9 120.9', 'dB SPL', ...
    'rreal', ['Last SPL of selected ear.' PairStr], Nchan);
AdjustSPL = ParamQuery([Prefix 'AdjustSPL'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);
%&&&&&&&&

% ---SPL

DAC = ParamQuery([Prefix 'DAC'], 'DAC:', '', DACstr, ...
    '', ['Active D/A channels.' ClickStr 'channel(s).']);
MaxSPL=messenger([Prefix 'MaxSPL'], 'max [**** ****] dB SPL @ [***** *****] Hz    ',1);

Levels = GUIpanel('Levels', T);
Levels = add(Levels,MBLSPL,'below',[25 0]);
Levels = add(Levels,UserMaxSPL,alignedwith(MBLSPL));
Levels = add(Levels,ParamEar, below(UserMaxSPL));
Levels = add(Levels,StartSPL, alignedwith(ParamEar));
Levels = add(Levels,StepSPL,alignedwith(StartSPL));
Levels = add(Levels,EndSPL, alignedwith(StepSPL));
Levels = add(Levels,DAC,nextto(MBLSPL),[10 0]);
Levels = add(Levels,AdjustSPL,  nextto(StepSPL), [5 7]);
Levels = add(Levels,MaxSPL, below(EndSPL));
Levels = marginalize(Levels, [0 3]);




