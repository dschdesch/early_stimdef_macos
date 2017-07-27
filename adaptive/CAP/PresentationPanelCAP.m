function Pres = PresentationPanelCAP
P = genpath('C:/EARLY/vs10');
addpath(P)

BeginSPL = ParamQuery('BeginSPL', 'Start Level:', '60', 'dB SPL', ...
    'rreal/positive', 'SPL to start recording with.',1);
MaxNPres = ParamQuery('MaxNPres', 'Max # pres:', '1500', '', ...
    'rreal/posint', 'Maximum number of presentations while searching SPL threshold per frequency until timeout.',1);
BurstDur = ParamQuery('BurstDur', 'Burst dur:', '20 ', 'ms', ...
    'rreal/nonnegative', 'Duration of stimulus burst.',2);
Order = ParamQuery('Order', 'Order:', '', {'Forward' 'Reverse'}, ...
    '', 'Order of frequency conditions.',1);
ZScore = ParamQuery('ZScore', 'z:', '60', '', ...
    'rreal/positive', 'z-score criterion for the RMSs.',1);

% add to panel
Pres = GUIpanel('Pres', 'Presentation');
Pres = add(Pres, BurstDur);
Pres = add(Pres, BeginSPL, 'aligned', [0 5]);
Pres = add(Pres, MaxNPres, 'aligned', [0 5]);
Pres = add(Pres, ZScore, 'aligned', [0 5]);
Pres = add(Pres, Order, 'aligned', [0 5]);












