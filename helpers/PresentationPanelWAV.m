function Pres=PresentationPanelWAV;
% PresentationPanelWAV - generic presentation panel for stimulus GUIs.
%   P=PresentationPanelWAV returns a GUIpanel M allowing the user to specify 
%   the parameters that determine the mode of presentation of the stimulus
%   conditions and their repetitions. The paramQuery objects contained in P
%   are 
%        ISI: onset-to-onset inter-stimulus interval in ms
%       Nrep: number of reps of each condition
%      Order: order of presentation. This is a toggle with alternaives
%                  Forward: from Start to End; all reps together
%                  Reverse: from End to Start; all reps together
%                   Random: random order of conditions; all reps together
%                Scrambled: one rep of each condition in random order, then
%                           second rep of each condition in new random
%                           order, etc.
%   PresentationPanelWAV is a helper function for stimulus definitions like stimdefFS.
% 
%   See StimGUI, DurPanel, stimdefFS, PresentationPanel_XY.

% ---Queries
Gap = ParamQuery('Gap', 'Gap:', '15000', 'ms', ...
    'rreal/nonnegative', 'Interval between consecutive files and repetitions.',1);
Nrep = ParamQuery('Nrep', '#Reps:', '1500', '', ...
    'rreal/posint', 'Number of repetitions of each condition.',1);
Group = ParamQuery('Grouping', 'Grouped ', '', {'by condition' 'rep by rep' }, ...
    '', ['Grouping of stimuli. "Grouped by condition" means that all reps of a condition are in one block;' char(10) ...
    '"Grouped rep by rep" means that a block contains one rep of each of the conditions.'], 1);
Order = ParamQuery('Order', 'Order:', '', {'Forward' 'Reverse' 'Random' 'Scrambled'}, ...
    '', ['Play order of stimulus conditions. Forward means from Start to End value.' char(10) ...
    'Reverse means from End to Start. Random means conditions randomized (fixed random order).' char(10), ...
    'Scrambled is the same as Random, except when grouped rep-by-rep, a new randomization is used for each rep.'],1);
RSeed = ParamQuery('RSeed', 'Rand Seed:', '844596300', '', ...
    'rseed', 'Random seed used for presentation order. Specify NaN to refresh seed upon each realization.',1);
Baseline = ParamQuery('Baseline', 'Baseline:', '12000 12000 ', 'ms', ...
    'rreal/nonnegative', 'Duration of pre- and poststimulus baseline recording. Pairs are interpreted as [pre post].',2);

% add to panel
Pres = GUIpanel('Pres', 'presentation');
Pres = add(Pres, Gap,'below',[5 0]);
Pres = add(Pres, Nrep,'nextto', [10 0]);
Pres = add(Pres,Baseline,below(Gap), [0 -10]);
Pres = add(Pres,Group, 'below', [10 -10]);
Pres = add(Pres,Order, 'aligned', [0 -10]);
Pres = add(Pres,RSeed, 'aligned', [0 -10]);











