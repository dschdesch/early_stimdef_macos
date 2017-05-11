function ITDSpeed=EvalITDSpeedStepper(figh, P, Prefix)
% EvalITDSpeedstepper - compute ITDSpeed series from ITDSpeedStepper GUI
% panel
%   ITDSpeed=EvalITDSpeedstepper(figh, P) checks ITDSpeed-stepper specs
%   in struct P (returned by GUIval ): startITDSpeed, stepITDSpeed, endITDSpeed, 
%   adjustITDSpeed (see ITDSpeedStepper), and converts
%   them to the individual ITDSpeeds of the ITDSpeed-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value ITDSpeed, while an error message is displayed by GUImessage.
%
%   See StimGUI, ITDSpeedStepper.

if nargin<3, Prefix=''; end

EXP = getGUIdata(figh,'Experiment');

% query names for param retrieval & error highlighting
Qnames = {[Prefix 'startSpeed'], [Prefix 'stepSpeed'], [Prefix 'endSpeed'], [Prefix 'adjustSpeed']};
[StartITDSpeed, Stepsize, EndITDSpeed, Adjuster] = deal(P.(Qnames{1}), P.(Qnames{2}), P.(Qnames{3}), P.(Qnames{4}));

% delegate the computation to generic EvalStepper
StepMode = 'Linear';

[ITDSpeed, Mess]=EvalStepper(StartITDSpeed, Stepsize, EndITDSpeed, StepMode, ...
    Adjuster, [-inf inf], EXP.maxNcond); % +/- inf: no a priori limits imposed to speed values;

if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit interaural speed bounds.', ...
        'Adjust interaural speed parameters or toggle "adjust" button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds interaural speed range';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') interaural speed steps.'] 'Increase stepsize or decrease range.'};
elseif any(ITDSpeed<0)
    Mess = {'ITD speed should be a positive range.'};
end

GUImessage(figh,Mess,'error',Qnames);




