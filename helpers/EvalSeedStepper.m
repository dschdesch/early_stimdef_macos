function NoiseSeed=EvalSeedStepper(figh, P, Prefix)
% EvalSeedstepper - compute noise seed series from SeedStepper GUI
% panel
%   Seed=EvalSeedStepper(figh, P) checks Seed-stepper specs
%   in struct P (returned by GUIval ): startSeed, stepSeed, endSeed, 
%   adjustSeed (see SeedStepper), and converts
%   them to the individual Seeds of the Seed-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value Seed, while an error message is displayed by GUImessage.
%
%   See StimGUI, SeedStepper.

if nargin<3, Prefix=''; end

EXP = getGUIdata(figh,'Experiment');

% query names for param retrieval & error highlighting
Qnames = {[Prefix 'startSeed'], [Prefix 'stepSeed'], [Prefix 'endSeed'], [Prefix 'adjustSeed']};
[StartSeed, Stepsize, EndSeed, Adjuster] = deal(P.(Qnames{1}), P.(Qnames{2}), P.(Qnames{3}), P.(Qnames{4}));

% delegate the computation to generic EvalStepper
StepMode = 'Linear';

[NoiseSeed, Mess]=EvalStepper(StartSeed, Stepsize, EndSeed, StepMode, ...
    Adjuster, [-inf inf], EXP.maxNcond); % +/- inf: no a priori limits imposed to speed values;

if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit noise seed bounds.', ...
        'Adjust noise seed stepping parameters or toggle "adjust" button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds noise seed range';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') noise seed steps.'] 'Increase stepsize or decrease range.'};
elseif any(NoiseSeed<0)
    Mess = {'Noise seed should be a positive range.'};
end

GUImessage(figh,Mess,'error',Qnames);