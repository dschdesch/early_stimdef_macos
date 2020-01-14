function speed=Evalspeed_stepper(figh, Prefix, P);
% EvalFrequencyStepper - compute frequency series from Frequency stepper GUI
%   Freq=EvalFrequencyStepper(figh) reads frequency-stepper specs
%   from paramqueries StartFreq, StepFrequency, EndFrequency, AdjustFreq,
%   in the GUI figure with handle figh (see FrequencyStepper), and converts
%   them to the individual frequencies of the frequency-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value Freq, while an error message is displayed by GUImessage.
%
%   EvalFrequencyStepper(figh, 'Foo') uses prefix Foo for the query names,
%   i.e., FooStartFreq, etc. The prefix defaults to ''.
%
%   EvalFrequencyStepper(figh, Prefix, P) does not read the queries, but
%   extracts them from struct P which was previously returned by GUIval.
%   This is the preferred use of EvalFrequencyStepper, because it leaves
%   the task of reading the parameters to the generic GUIval function. The
%   first input arg figh is still needed for error reporting.
%
%   See StimGUI, FrequencyStepper, GUIval, GUImessage.

if nargin<2, Prefix=''; end
if nargin<3, P = []; end
speed = []; % allow premature return

if isempty(P), % obtain info from GUI. Non-preferred method; see help text.
    EXP = getGUIdata(figh,'Experiment');
    Q = getGUIdata(figh,'Query');
    Startspeed = read(Q([Prefix 'Startspeed']));
    [Stepspeed, StepspeedUnit] = read(Q([Prefix 'Stepspeed']));
    Endspeed = read(Q([Prefix 'Endspeed']));
    Adjustspeed = read(Q([Prefix 'Adjustspeed']));
    P = collectInstruct(Startspeed, Stepspeed, StepspeedUnit, Endspeed, Adjustspeed);
else,
    P = dePrefix(P, Prefix);
    EXP = P.Experiment;
end

%no need to check whatever

% delegate the computation to generic EvalStepper
StepMode = P.StepspeedUnit;
if isequal('Hz', StepMode), StepMode = 'Linear'; end

[speed, Mess]=EvalStepper(P.Startspeed, P.Stepspeed, P.Endspeed, StepMode, ...
    P.Adjustspeed, [-100 100], EXP.maxNcond);
if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit width bounds', ...
        'Adjust width parameters or toggle Adjust button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds width range';
elseif isequal('cripple', Mess)
    Mess = 'Different # widh steps in the two DA channels';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') width steps.'] 'Increase stepsize or decrease range'};
end
GUImessage(figh,Mess, 'error',{[Prefix 'Startspeed'] [Prefix 'Stepspeed'] [Prefix 'Endspeed'] });




