function Pres = PresentationPanelTHR_Geisler
% ---Queries
BeginSPL = paramquery('BeginSPL', 'Begin SPL:', '100', 'dB SPL', ...
    'rreal/positive', 'SPL to start recording with.',1);
MaxNPres = paramquery('MaxNPres', 'Max # pres:', '1500', '', ...
    'rreal/posint', 'Maximum number of presentations while searching SPL threshold until timeout.',1);
BurstDur = paramquery('BurstDur', 'Burst dur:', '100 ', 'ms', ...
    'rreal/nonnegative', 'Duration of stimulus burst.',2);
Order = paramquery('Order', 'Order:', '', {'Forward' 'Reverse'}, ...
    '', 'Order of frequency conditions.',1);

% add to panel
Pres = GUIpanel('Pres', 'Presentation');
Pres = add(Pres, BeginSPL);
Pres = add(Pres, MaxNPres, 'aligned', [0 5]);
Pres = add(Pres, BurstDur, 'aligned', [0 5]);
Pres = add(Pres, Order, 'aligned', [0 0]);











