function Pres = PresentationPanelTHR
% ---Queries
Proc = ParamQuery('Proc', 'Procedure:', '', {'Geisler','Liberman','Marcel'}, '',...
    'Click to toggle between automated procedures for determining the threshold tuning curve.', 100);
BeginSPL = ParamQuery('BeginSPL', 'Begin SPL:', '100', 'dB SPL', ...
    'rreal/positive', 'SPL to start recording with.',1);
MaxNPres = ParamQuery('MaxNPres', 'Max # pres:', '100', '', ...
    'rreal/posint', 'Maximum number of presentations while searching SPL threshold until timeout.',1);
SpikeCrit = ParamQuery('SpikeCrit', 'Crit:', '100', '', ...
    'rreal/nonnegative', {'Critical difference between number of spikes during and after stimulus for Liberman procedure.',...
    'Number of spikes during burst to compare with for Marcel procedure.'},1);
BurstDur = ParamQuery('BurstDur', 'Burst dur:', '100', 'ms', ...
    'rreal/nonnegative', 'Duration of stimulus burst.',2);
ISI = ParamQuery('ISI', 'ISI:', '15000', 'ms', ...
    'rreal/positive', 'Onset-to-onset interval between consecutive stimuli of a series.',1);
Order = ParamQuery('Order', 'Order:', '', {'Forward' 'Reverse'}, ...
    '', 'Order of frequency conditions.',1);
CustSR = ParamQuery('CustSR', 'Custom SR:', '100', 'Spk/sec', ...
    'rreal', 'Custom Spike rate.',1);
% add to panel
Pres = GUIpanel('Pres', 'Presentation');
Pres = add(Pres, BeginSPL);
Pres = add(Pres, MaxNPres, 'aligned', [0 5]);
Pres = add(Pres, BurstDur, 'aligned', [0 5]);
Pres = add(Pres, ISI, 'aligned', [0 5]);
Pres = add(Pres, Order, 'aligned', [0 5]);
Pres = add(Pres, Proc, nextto(BeginSPL), [10 0]);
Pres = add(Pres, SpikeCrit, 'aligned', [0 5]);
Pres = add(Pres,CustSR, below(SpikeCrit),[0 5]);













