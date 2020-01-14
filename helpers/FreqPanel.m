function freqPanel=FreqPanel(T, EXP, Prefix, CmpName);
% Panel for simple frequency selection 
% 

[Prefix, CmpName] = arginDefaults('Prefix/CmpName', '', 'Carrier');

if isequal('-',T), T = 'Carrier freq'; end

% # DAC channels fixes the allowed multiplicity of user-specied numbers
% if isequal('Both', EXP.AudioChannelsUsed), 
%     Nchan = 2;
%     PairStr = ' Pairs of numbers are interpreted as [left right].';
% else, % single Audio channel
%     Nchan = 1;
%     PairStr = ''; 
% end
% ClickStr = ' Click button to select ';

% ---SPL
% switch EXP.Recordingside,
%     case 'Left', Lstr = 'Left=Ipsi'; Rstr = 'Right=Contra';
%     case 'Right', Lstr = 'Left=Contra'; Rstr = 'Right=Ipsi';
% end
% switch EXP.AudioChannelsUsed,
%     case 'Left', DACstr = {Lstr};
%     case 'Right', DACstr = {Rstr};
%     case 'Both', DACstr = {Lstr Rstr 'Both'};
% end

% StartFreq = paramquery([Prefix 'StartFreq'], 'start:', '15000.5 15000.5', 'Hz', ...
%     'rreal/positive', ['Starting frequency of series.' PairStr], Nchan);

freqParam = ParamQuery([Prefix 'Fcar'], 'Frequency:', '15000.5', 'Hz', ...
    'rreal/positive', [CmpName ' Frequency'], 1);

% DAC = paramquery([Prefix 'DAC'], 'DAC:', '', DACstr, ...
%     '', ['Active D/A channels.' ClickStr 'channel(s).']);
% MaxSPL=messenger([Prefix 'MaxSPL'], 'max [**** ****] dB SPL @ [***** *****] Hz    ',1);

Tol = ParamQuery([Prefix 'FreqTolMode'], 'acuity:', '', {'economic' 'exact'}, '', [ ...
    'Exact: no rounding applied;', char(10), 'Economic: allow slight (<1 part per 1000), memory-saving rounding of frequencies;'], ...
    1, 'Fontsiz', 8);

freqPanel = GUIpanel('CarFreq', T);
freqPanel = add(freqPanel,freqParam,'below');

freqPanel = add(freqPanel,Tol,nextto(freqParam));


% freqPanel = add(freqPanel,DAC,'nextto',[15 0]);
% freqPanel = add(freqPanel,MaxSPL,['below ' Prefix 'SPL'],[17 0]);
freqPanel = marginalize(freqPanel, [0 3]);




