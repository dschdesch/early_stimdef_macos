function PrecursorFlag=EvalPrecursorFlagStepper(figh, P, Prefix)
% EvalPrecursorFlagstepper - compute noise seed series from PrecursorFlagStepper GUI
% panel
%   PrecursorFlag=EvalPrecursorFlagStepper(figh, P) checks PrecursorFlag-stepper specs
%   in struct P (returned by GUIval ): startPrecursorFlag, stepPrecursorFlag, endPrecursorFlag, 
%   adjustPrecursorFlag (see PrecursorFlagStepper), and converts
%   them to the individual PrecursorFlags of the PrecursorFlag-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value PrecursorFlag, while an error message is displayed by GUImessage.
%
%   See StimGUI, PrecursorFlagStepper.

if nargin<3, Prefix=''; end

EXP = getGUIdata(figh,'Experiment');

% query names for param retrieval & error highlighting
Qnames = {[Prefix 'startPrecursorFlag'], [Prefix 'stepPrecursorFlag'], [Prefix 'endPrecursorFlag'], [Prefix 'adjustPrecursorFlag']};
[StartPrecursorFlag, Stepsize, EndPrecursorFlag, Adjuster] = deal(P.(Qnames{1}), P.(Qnames{2}), P.(Qnames{3}), P.(Qnames{4}));

% delegate the computation to generic EvalStepper
StepMode = 'Linear';

[PrecursorFlag, Mess]=EvalStepper(StartPrecursorFlag, Stepsize, EndPrecursorFlag, StepMode, ...
    Adjuster, [-inf inf], EXP.maxNcond); % +/- inf: no a priori limits imposed to speed values;

if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit noise seed bounds.', ...
        'Adjust noise seed stepping parameters or toggle "adjust" button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds noise seed range';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') noise seed steps.'] 'Increase stepsize or decrease range.'};
elseif any(PrecursorFlag<0)
    Mess = {'should be a positive range.'};
end

GUImessage(figh,Mess,'error',Qnames);