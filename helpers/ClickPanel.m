function Click=ClickPanel(T, EXP, Prefix);
% ClickPanel - generic click parameters panel for stimulus GUIs.
%   S=ClickPanel(Title, EXP) returns a GUIpanel M allowing the 
%   user to specify the pulse width and pulse type of a click. 
%   Guipanel S has title Title. EXP is the experiment definition, 
%   from which the number of DAC channels used (1 or 2) is determined.
%
%   The paramQuery objects contained in F are named: 
%         PulseWidth: width of the pulse in microseconds
%          PulseType: either monophasic +/- or biphasic +/-
%
%   ClickPanel is a helper function for stimulus definitions like stimdefCFS.
% 
%   M=ClickPanel(Title, EXP, Prefix) prepends the string Prefix
%   to the paramQuery names.
%   Default Prefix is '', i.e., no prefix.
%
%   M=ClickPanel(Title, EXP, Prefix, IncludeTheta, IncludeITD) fixes the
%   optional inclusion of a Theta query (default: true) and a ITD query
%   (default: flase). Theta is the modulation angle.
%
%   Use EvalClickPanel to read the values from the queries.
%
%   See StimGUI, GUIpanel, EvalClickPanel, stimdefCFS, stimdefCTD.

[Prefix] = arginDefaults('Prefix', '');

% # DAC channels fixes the allowed multiplicity of user-specied numbers
if isequal('Both', EXP.AudioChannelsUsed), 
    Nchan = 2;
    PairStr = ' Pairs of numbers are interpreted as [left right].';
else, % single Audio channel
    Nchan = 1;
    PairStr = ''; 
end


% ---Modulation
Click = GUIpanel('Click', T);
PulseWidth = ParamQuery([Prefix 'PulseWidth'], ...
    'pulse width:', '1100.1 1100.1', 'us', 'rreal/nonnegative', ...
    ['Width of one pulse (this is half of click duration in biphasic clicks).' PairStr], Nchan);
Polarity = ParamQuery([Prefix 'PulseType'], ...
    'polarity:', '', {'monophasic +','monophasic -','biphasic +','biphasic -','alternate'}, '', ...
    ['Modulation depth.' PairStr], Nchan);

Click = add(Click,PulseWidth);
Click = add(Click,Polarity, 'aligned', [0 -5]);




