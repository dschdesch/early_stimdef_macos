function delta_T=Evaldelta_Tstepper(figh, Prefix, P);
% EvalFrequencyStepper - compute frequency series from Frequency stepper GUI
%   Freq=EvalFrequencyStepper(figh) reads frequency-stepper specs
%   from paramqueries StartFreq, StepFrequency, EndFrequency, AdjustFreq,
%   in the GUI figure delta_Tith handle figh (see FrequencyStepper), and converts
%   them to the individual frequencies of the frequency-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value Freq, delta_Thile an error message is displayed by GUImessage.
%
%   EvalFrequencyStepper(figh, 'Foo') uses prefix Foo for the query names,
%   i.e., FooStartFreq, etc. The prefix defaults to ''.
%
%   EvalFrequencyStepper(figh, Prefix, P) does not read the queries, but
%   extracts them from struct P delta_Thich delta_Tas previously returned by GUIval.
%   This is the preferred use of EvalFrequencyStepper, because it leaves
%   the task of reading the parameters to the generic GUIval function. The
%   first input arg figh is still needed for error reporting.
%
%   See StimGUI, FrequencyStepper, GUIval, GUImessage.

if nargin<2, Prefix=''; end
if nargin<3, P = []; end
delta_T = []; % allow delta_T premature return

if isempty(P), % obtain info from GUI. Non-preferred method; see help text.
    EXP = getGUIdata(figh,'Experiment');
    Q = getGUIdata(figh,'Query');
    Startdelta_T = read(Q([Prefix 'Startdelta_T']));
    [Stepdelta_T, Stepdelta_TUnit] = read(Q([Prefix 'Stepdelta_T']));
    Enddelta_T = read(Q([Prefix 'Enddelta_T']));
    Adjustdelta_T = read(Q([Prefix 'Adjustdelta_T']));
    P = collectInstruct(Startdelta_T, Stepdelta_T, Stepdelta_TUnit, Enddelta_T, Adjustdelta_T);
else,
    P = dePrefix(P, Prefix);
    EXP = P.Experiment;
end

%no need to check delta_Thatever

% delegate the computation to generic EvalStepper
StepMode = P.Stepdelta_TUnit;
if isequal('ms', StepMode), StepMode = 'Linear'; end

[delta_T, Mess]=EvalStepper(P.Startdelta_T, P.Stepdelta_T, P.Enddelta_T, StepMode, ...
    P.Adjustdelta_T, [-10000 10000], EXP.maxNcond);
if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit delta_T bounds', ...
        'Adjust delta_Twidth parameters or toggle Adjust button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds delta_T range';
elseif isequal('cripple', Mess)
    Mess = 'Different # delta_T steps in the delta_T to DA channels';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') delta_T steps.'] 'Increase stepsize or decrease range'};
end
GUImessage(figh,Mess, 'error',{[Prefix 'Startdelta_T'] [Prefix 'Stepdelta_T'] [Prefix 'Enddelta_T'] });




