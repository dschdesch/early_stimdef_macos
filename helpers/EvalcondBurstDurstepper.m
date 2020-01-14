function condBurstDur=EvalcondBurstDurstepper(figh, Prefix, P);
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
%   extracts them from struct P condBurstDurhich condBurstDuras previously returned by GUIval.
%   This is the preferred use of EvalFrequencyStepper, because it leaves
%   the task of reading the parameters to the generic GUIval function. The
%   first input arg figh is still needed for error reporting.
%
%   See StimGUI, FrequencyStepper, GUIval, GUImessage.

if nargin<2, Prefix=''; end
if nargin<3, P = []; end
condBurstDur = []; % allow condBurstDur premature return

if isempty(P), % obtain info from GUI. Non-preferred method; see help text.
    EXP = getGUIdata(figh,'Experiment');
    Q = getGUIdata(figh,'Query');
    StartcondBurstDur = read(Q([Prefix 'StartcondBurstDur']));
    [StepcondBurstDur, StepcondBurstDurUnit] = read(Q([Prefix 'StepcondBurstDur']));
    EndcondBurstDur = read(Q([Prefix 'EndcondBurstDur']));
    AdjustcondBurstDur = read(Q([Prefix 'AdjustcondBurstDur']));
    P = collectInstruct(StartcondBurstDur, StepcondBurstDur, StepcondBurstDurUnit, EndcondBurstDur, AdjustcondBurstDur);
else,
    P = dePrefix(P, Prefix);
    EXP = P.Experiment;
end

%no need to check condBurstDurhatever

% delegate the computation to generic EvalStepper
StepMode = P.StepcondBurstDurUnit;
if isequal('ms', StepMode), StepMode = 'Linear'; end

[condBurstDur, Mess]=EvalStepper(P.StartcondBurstDur, P.StepcondBurstDur, P.EndcondBurstDur, StepMode, ...
    P.AdjustcondBurstDur, [0 10000], EXP.maxNcond);
if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit condBurstDur bounds', ...
        'Adjust condBurstDurwidth parameters or toggle Adjust button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds condBurstDur range';
elseif isequal('cripple', Mess)
    Mess = 'Different # condBurstDur steps in the condBurstDur to DA channels';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') condBurstDur steps.'] 'Increase stepsize or decrease range'};
end
GUImessage(figh,Mess, 'error',{[Prefix 'StartcondBurstDur'] [Prefix 'StepcondBurstDur'] [Prefix 'EndcondBurstDur'] });




