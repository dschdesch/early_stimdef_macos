function NP=VariedChannelARMIN(Title);
% VariedChannelARMIN - Parameters for the varied channel of ARMIN.
%   NP=VariedChannelARMIN(Title) returns a GUIpanel NP allowing the 
%   user to specify seeds and polarities for the varied Channel. 
%   It also allows ther user to select which channel is the varied channel.
%   Guipanel NP has title Title. 
%
%   The paramQuery objects contained in F are named: 
%          LowNoiseSeed: seed for the varied channel below flip frequency
%          HighNoiseSeed: seed for the varied channel above flip frequency
%          LowPolarity: Polarity of the varied channel {+, -} below flip frequency
%          HighPolarity: Polarity of the varied channel {+, -} above flip frequency
%          Varied Channel: Denotes which channel is varied {Ipsi, contra}
%
%   VariedChannelARMIN is a helper function for stimulus definitions like
%   stimdefARMIN.
%
%   See StimGUI, GUIpanel, EvalNoisePanelARMIN, stimdefARMIN.


%===========Bookkeeping=========
% ---levels and active DACs
if isequal('-',Title), Title = 'Constant channel'; end

ClickStr = ' Click the button to select ';

%===========Queries========
% ---Polarity & seed
LowSeed = ParamQuery(['LowSeed'], 'Low Seed:', '844596300', '', ...
    'rseed', 'Random seed used for realization of noise waveform for the Varied Channel below the flip frequency. Specify NaN to refresh seed upon each realization.',1);
HighSeed = ParamQuery(['HighSeed'], 'High Seed:', '844596300', '', ...
    'rseed', 'Random seed used for realization of noise waveform for the Varied Channel above the flip frequency. Specify NaN to refresh seed upon each realization.',1);
LowPolarity = ParamQuery('LowPolarity', 'Low Polarity:', '', {'+','-'}, ...
    '', [ClickStr ' the Polarity of the varied channel below the flip frequency.']);
HighPolarity = ParamQuery('HighPolarity', 'High Polarity:', '', {'+','-'}, ...
    '', [ClickStr ' the Polarity of the varied channel above the flip frequency.']);
% ========Add queries to panel=======
NP = GUIpanel('VariedChannel', Title);
NP = add(NP,LowSeed, 'below', [10 0]);
NP = add(NP,HighSeed, nextto(LowSeed), [10 0]);
NP = add(NP,LowPolarity, below(LowSeed), [0 0]);
NP = add(NP,HighPolarity, nextto(LowPolarity), [0 0]);
NP = marginalize(NP, [0 3]);




