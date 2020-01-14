function NP=NoisePanelRCN(T, EXP, Prefix);
% NoisePanelRCN - generic noise panel for stimulus GUIs.
%   NP=NoisePanelRCN(Title, EXP) returns a GUIpanel NP allowing the 
%   user to specify a white noise band. Guipanel NP has title Title. EXP is the 
%   experiment definition, from which the number of DAC channels used 
%   (1 or 2) is determined.
%
%   The paramQuery objects contained in F are named: 
%            LowFreq: lower cutoff frequency in Hz
%           HighFreq: higher cutoff frequency in Hz
%         NoiseSeed: random seed used for realization of noise waveform
%              Corr: interaural correlation with toggle (C|I)  
%  
%   A messenger fo reporting the maximum SPL is also created.
%
%   NoisePanelRCN is a helper function for stimulus definitions like
%   stimdefRCN.
% 
%   M=NoisePanelRCN(Title, EXP, Prefix) prepends the string Prefix
%   to the paramQuery names, e.g. LowFreq -> NoiseLowFreq, etc.
%
%   Use EvalNoisePanelRCN to read the values from the queries.
%
%   See StimGUI, GUIpanel, EvalNoisePanel, stimdefNPHI.

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
Corr = ParamQuery([Prefix 'Corr'], 'corr:', '-0.9997 ', {'I', 'C'}, ...
    'rreal', ['Interaural noise correlation (number between -1 and 1)', char(10), ... 
    'Click button to change the "varied channel" (where mixing is done).'],1);
NoiseSeed = ParamQuery([Prefix 'ConstNoiseSeed'], 'seed:', '844596300', '', ...
    'rseed', 'Random seed used for realization of noise waveform. Specify NaN to refresh seed upon each realization.',1);

% ========Add queries to panel=======
NP = GUIpanel('Noise', T);
NP = add(NP,LowFreq, 'below', [10 0]);
NP = add(NP,HighFreq, 'aligned', [0 -7]);
NP = add(NP,Corr, 'aligned', [0 -7]);
NP = add(NP,NoiseSeed, nextto(Corr), [0 0]);
NP = marginalize(NP, [0 3]);




