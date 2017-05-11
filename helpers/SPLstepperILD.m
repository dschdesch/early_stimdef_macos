function Levels=SPLstepperILD(T, EXP, Prefix, CmpName);
% SPLstepperILD - generic panel for stepped SPL and DAchannel in stimulus GUIs.
%   S=SPLstepperILD(Title, EXP) returns a GUIpanel M named 'Levels' allowing the 
%   user to specify a stepped SPL to be applied to the stimuli of a series.
%   Guipanel S has title Title. EXP is the experiment definition, from 
%   which the number of DAC channels used 
%   (1 or 2) is determined. Title='-' results in standard title 'SPLs & 
%   active channels'
%
%   The paramQuery objects contained in S are
%         ConstantSPL: SPL of ear of which the level is held constant
%         VariedEar: the ear of which the level is varied (L|R)
%         StartSPL: starting level of stimuli in dB SPL (varied ear)
%         StepSPL: step of SPL dB (varied ear)
%         EndSPL: end level of stimuli in dB SPL (varied ear)
%         AdjustSPL: how to adjust misfitting step requests. (varied ear)
%         DAC: active DA channel
%   The messenger contained in S is
%       MaxSPL: report of max attainable SPL (filled by MakeStimXXX)
%
%   SPLstepperILD is a helper function for stimulus definitions like stimdefRF.
% 
%   M=SPLstepperILD(Title, ChanSpec, Prefix, 'Foo') prepends the string Prefix
%   to the paramQuery names, e.g. StartSPL -> NoiseStartSPL, etc, and calls the
%   components whose SPL is set by the name Foo in any error messages.
%
%   Use EvalSPLstepperILD to check the feasibility of SPLs and to update the 
%   MaxSPL messenger display.
%
%   See StimGUI, GUIpanel, ReportMaxSPL, stimdefFS, SPLstepperILD.


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
ConstantSPL = ParamQuery([Prefix 'ConstantSPL'], 'constant ear:', '-10.5 -10.5', 'dB SPL', ...
    'rreal/positive', [ 'SPL of constant ear.' PairStr], Nchan);
VariedEar = ParamQuery([Prefix 'VariedEar'], 'varied ear:', '', {Lstr Rstr}, ...
    '', ['Channel varied in SPL.' ClickStr 'channel.']);
StartSPL = ParamQuery([Prefix 'StartSPL'], 'start:', '-10.5 -10.5', 'dB SPL', ...
    'rreal', ['Starting SPL of varied ear.' PairStr], Nchan);
StepSPL = ParamQuery([Prefix 'StepSPL'], 'step:', '1.25 1.25', 'dB', ...
    'rreal/positive', 'SPL step of varied ear.', Nchan);
EndSPL = ParamQuery('EndSPL', 'end:', '120.9 120.9', 'dB SPL', ...
    'rreal', ['Last SPL of varied ear.' PairStr], Nchan);
AdjustSPL = ParamQuery([Prefix 'AdjustSPL'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);
%&&&&&&&&

% ---SPL

DAC = ParamQuery([Prefix 'DAC'], 'DAC:', '', DACstr, ...
    '', ['Active D/A channels.' ClickStr 'channel(s).']);
MaxSPL=messenger([Prefix 'MaxSPL'], 'max [**** ****] dB SPL @ [***** *****] Hz    ',1);

Levels = GUIpanel('Levels', T);
Levels = add(Levels,ConstantSPL,'below');
Levels = add(Levels,VariedEar, below(ConstantSPL));
Levels = add(Levels,StartSPL, alignedwith(VariedEar));
Levels = add(Levels,StepSPL,alignedwith(StartSPL));
Levels = add(Levels,EndSPL, alignedwith(StepSPL));
Levels = add(Levels,DAC,nextto(VariedEar),[10 0]);
Levels = add(Levels,AdjustSPL,  nextto(StepSPL), [5 7]);
Levels = add(Levels,MaxSPL, below(EndSPL));
Levels = marginalize(Levels, [0 3]);




