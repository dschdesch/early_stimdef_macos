function freqPanel=BeatFreqPanel(T, EXP, Prefix, CmpName, TooltipFreq);
% Panel for simple frequency selection 

[Prefix, CmpName, TooltipFreq] = arginDefaults('Prefix/CmpName/TooltipFreq', '', 'Beat', ...
    'carrier');

if isequal('-',T), T = 'Beats'; end

freqParam = ParamQuery('BeatFreq', 'frequency:', '15000.5', 'Hz', ...
    'rreal', ['Beat frequency, added to the ', TooltipFreq, ' frequency of the CONTRA side'], 1);

freqPanel = GUIpanel('BeatFreq', T);
freqPanel = add(freqPanel,freqParam,'below');

freqPanel = marginalize(freqPanel, [0 3]);
