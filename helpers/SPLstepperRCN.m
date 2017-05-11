function Levels=SPLstepperRCN(T, EXP, Prefix, CmpName);
% SPLstepperRCN - generic panel for stepped SPL and DAchannel in stimulus GUIs.
%   S=SPLstepperRCN(Title, EXP) returns a GUIpanel M named 'Levels' allowing the 
%   user to specify a stepped SPL to be applied to the stimuli of a series.
%   Guipanel S has title Title. EXP is the experiment definition, from 
%   which the number of DAC channels used 
%   (1 or 2) is determined. Title='-' results in standard title 'SPLs & 
%   active channels'
%
%   The paramQuery objects contained in S are
%         StartSPL: starting level of stimuli in dB SPL
%         StepSPL: step of SPL dB
%         EndSPL: end level of stimuli in dB SPL
%         AdjustSPL: how to adjust misfitting step requests.
%         DAC: active DA channel
%   The messenger contained in S is
%       MaxSPL: report of max attainable SPL (filled by MakeStimXXX)
%
%   SPLstepperRCN is a helper function for stimulus definitions like stimdefRF.
% 
%   M=SPLstepperRCN(Title, ChanSpec, Prefix, 'Foo') prepends the string Prefix
%   to the paramQuery names, e.g. StartSPL -> NoiseStartSPL, etc, and calls the
%   components whose SPL is set by the name Foo in any error messages.
%
%   Use EvalSPLstepper to check the feasibility of SPLs and to update the 
%   MaxSPL messenger display.
%
%   See StimGUI, GUIpanel, ReportMaxSPL, stimdefFS, SPLstepperRCN.


[Prefix, CmpName] = arginDefaults('Prefix/CmpName', '', 'Carrier');
if isequal('-',T), T = 'SPLs & active channels'; end

% # DAC channels determines the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else, % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end
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
StartSPL = ParamQuery([Prefix 'StartSPL'], 'start:', '-10.5 -10.5', {'dB SPL' 'dB/Hz'}, ...
    'rreal', ['Intensity. Click button to switch between overall level (dB SPL) and spectrum level (dB/Hz).' PairStr],Nchan);
StepSPL = ParamQuery([Prefix 'StepSPL'], 'step:', '1.25 1.25', 'dB', ...
    'rreal/positive', 'SPL step of series.', Nchan);
EndSPL = ParamQuery('EndSPL', 'end:', '120.9 120.9', 'dB', ...
    'rreal', ['Last SPL of series.' PairStr], Nchan);
AdjustSPL = ParamQuery([Prefix 'AdjustSPL'], 'adjust:', '', {'none' 'start' 'step' 'end'}, ...
    '', 'Choose which parameter to adjust when the stepsize does not exactly fit the start & end values.', 1,'Fontsiz', 8);
%&&&&&&&&

% ---SPL

DAC = ParamQuery([Prefix 'DAC'], 'DAC:', '', DACstr, ...
    '', ['Active D/A channels.' ClickStr 'channel(s).']);
MaxSPL=messenger([Prefix 'MaxSPL'], 'max [**** ****] dB SPL @ [***** *****] Hz    ',1);

Levels = GUIpanel('Levels', T);
Levels = add(Levels,StartSPL,'below');
Levels = add(Levels,StepSPL,alignedwith(StartSPL));
Levels = add(Levels,EndSPL, alignedwith(StepSPL));
Levels = add(Levels,DAC,nextto(EndSPL),[10 0]);
Levels = add(Levels,AdjustSPL,  nextto(StepSPL), [27 7]);
Levels = add(Levels,MaxSPL, below(EndSPL),[17 0]);
Levels = marginalize(Levels, [0 3]);




