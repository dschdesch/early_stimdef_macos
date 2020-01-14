function NP=ConstChannelPanelARMIN(Title);
% NoisePanelARMIN - Parameters for the constant channel of ARMIN.
%   NP=ConstChannelPanelARMIN(Title) returns a GUIpanel NP allowing the 
%   user to specify a seed and polarity for the Constant Channel. 
%   Guipanel NP has title Title. 
%
%   The paramQuery objects contained in F are named: 
%            ConstNoiseSeed: seed for the constant channel
%           ConstPolarity: Polarity of the constant channel {+, -}
%
%   ConstChannelPanelARMIN is a helper function for stimulus definitions like
%   stimdefARMIN.
%
%   See StimGUI, GUIpanel, EvalNoisePanelARMIN, stimdefARMIN.


%===========Bookkeeping=========
% ---levels and active DACs
if isequal('-',Title), Title = 'Constant channel'; end

ClickStr = ' Click the button to select ';

%===========Queries========
% ---Polarity & seed
NoiseSeed = ParamQuery(['ConstNoiseSeed'], 'Seed:', '844596300', '', ...
    'rseed', 'Random seed used for realization of noise waveform for the Constant Channel. Specify NaN to refresh seed upon each realization.',1);
Polarity = ParamQuery('ConstPolarity', 'Polarity:', '', {'+','-'}, ...
    '', [ClickStr ' the Polarity of the constant channel.']);

% ========Add queries to panel=======
NP = GUIpanel('ConstChannel', Title);
NP = add(NP,NoiseSeed, 'below', [10 0]);
NP = add(NP,Polarity, nextto(NoiseSeed), [0 0]);

NP = marginalize(NP, [0 3]);




