function NP=NoisePanelARMIN(T, EXP, Prefix);
% NoisePanelARMIN - generic noise panel for stimulus GUIs.
%   NP=NoisePanelARMIN(Title, EXP) returns a GUIpanel NP allowing the 
%   user to specify a white noise band. Guipanel NP has title Title. EXP is the 
%   experiment definition, from which the number of DAC channels used 
%   (1 or 2) is determined.
%
%   The paramQuery objects contained in F are named: 
%            LowFreq: lower cutoff frequency in Hz
%           HighFreq: higher cutoff frequency in Hz
%         NoiseSeed: random seed used for realization of noise waveform
%               SPL: sound intensity, with toggle (dB SPL | dB/Hz)
%               DAC: toggle L|R|B
%  
%   A messenger fo reporting the maximum SPL is also created.
%
%   NoisePanelARMIN is a helper function for stimulus definitions like
%   stimdefARMIN.
% 
%   M=NoisePanelARMIN(Title, EXP, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. LowFreq -> NoiseLowFreq, etc.
%
%   Use EvalNoisePanelARMIN to read the values from the queries.
%
%   See StimGUI, GUIpanel, EvalNoisePanelARMIN, stimdefARMIN.

if nargin<3, Prefix=''; end

%===========Bookkeeping=========
% ---levels and active DACs
if isequal('-',T), T = 'SPLs & active channels'; end
% # DAC channels fixes the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else, % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end
Levels = GUIpanel('Levels', T);
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

%===========Queries========
% ---freq & seed
LowFreq = ParamQuery([Prefix 'LowFreq'], ...
    'low:', '1100.1 1100.1', 'Hz', 'rreal/nonnegative', ...
    ['Low cutoff frequency.' PairStr], Nchan);
HighFreq = ParamQuery([Prefix 'HighFreq'], ...
   'high:', '1100.1 1100.1', 'Hz', 'rreal/nonnegative', ...
    ['High cutoff frequency.' PairStr], Nchan);
NoiseSeed = ParamQuery([Prefix 'NoiseSeed'], 'seed:', '844596300', '', ...
    'rseed', 'Random seed used for realization of noise waveform. Specify NaN to refresh seed upon each realization.',1);
% ---SPL
% SPL = ParamQuery([Prefix 'Start SPL'], 'start level:', '120.5 120.5', {'dB SPL' 'dB/Hz'}, ...
%     'rreal', ['Intensity. Click button to switch between overall level (dB SPL) and spectrum level (dB/Hz).' PairStr],Nchan);

SPL_start = ParamQuery([Prefix 'StartSPL'], 'start level:', '120.5 120.5', 'dB SPL', ...
    'rreal', ['Intensity. Click button to switch between overall level (dB SPL) and spectrum level (dB/Hz).' PairStr],Nchan);
SPL_step = ParamQuery([Prefix 'StepSPL'], 'level step:', '120.5 120.5', 'dB SPL', ...
    'rreal', ['Intensity. Click button to switch between overall level (dB SPL) and spectrum level (dB/Hz).' PairStr],Nchan);
SPL_end = ParamQuery([Prefix 'EndSPL'], 'final level:', '120.5 120.5', 'dB SPL', ...
    'rreal', ['Intensity. Click button to switch between overall level (dB SPL) and spectrum level (dB/Hz).' PairStr],Nchan);
DAC = ParamQuery('DAC', 'DAC:', '', DACstr, ...
    '', ['Active D/A channels.' ClickStr 'channel(s).']);
MaxSPL=messenger([Prefix 'MaxSPL'], 'max [**** ****] dB SPL @ [***** *****] Hz    ',1);


% ========Add queries to panel=======
NP = GUIpanel('Noise', T);
NP = add(NP,LowFreq, 'below', [10 0]);
NP = add(NP,HighFreq, 'aligned', [0 -7]);
NP = add(NP,DAC,nextto(LowFreq),[0 0]);
NP = add(NP,NoiseSeed,  below(DAC), [0 0]);
NP = add(NP,SPL_start, nextto(DAC), [20 0]);
NP = add(NP,SPL_step, below(SPL_start), [0 0]);
NP = add(NP,SPL_end, below(SPL_step), [0 0]);
NP = add(NP,MaxSPL,below(HighFreq),[17 20]);
NP = marginalize(NP, [0 3]);




