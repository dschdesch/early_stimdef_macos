function [okay, ModFreq]=EvalSAMStepper(figh, Prefix, P, Fcar)
% EvalSAMStepper - compute modulation frequency series from SAMStepper GUI
%   ModFreq=EvalSAMStepper(figh) reads modulation frequency-stepper specs
%   from paramqueries StartModFreq, StepModFreq, EndModFreq, AdjustModFreq,
%   in the GUI figure with handle figh (see SAMStepper), and converts
%   them to the individual frequencies of the frequency-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value ModFreq, while an error message is displayed by GUImessage.
%
%   EvalSAMStepper(figh, 'Foo') uses prefix Foo for the query names,
%   i.e., FooStartFreq, etc. The prefix defaults to ''.
%
%   EvalSAMStepper(figh, Prefix, P) does not read the queries, but
%   extracts them from struct P which was previously returned by GUIval.
%   This is the preferred use of EvalSAMStepper, because it leaves
%   the task of reading the parameters to the generic GUIval function. The
%   first input arg figh is still needed for error reporting.
%
%   See StimGUI, FrequencyStepper, GUIval, GUImessage.

if nargin<2, Prefix=''; end
if nargin<3, P = []; end
okay=0;

ModFreq = []; % allow premature return

if isempty(P), % obtain info from GUI. Non-preferred method; see help text.
    error('Empty struct P passed')
else
    P = dePrefix(P, Prefix);
    EXP = P.Experiment;
end

% paramquery names for highlighting
FQnames = {[Prefix 'StartModFreq'] [Prefix 'StepModFreq'] [Prefix 'EndModFreq']};


% delegate the computation to generic EvalStepper
StepMode = P.StepModFreqUnit;
if isequal('Hz', StepMode), StepMode = 'Linear'; end

[ModFreq, Mess]=EvalStepper(P.StartModFreq, P.StepModFreq, P.EndModFreq, StepMode, ...
    P.AdjustModFreq, [-inf inf], EXP.maxNcond);
if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit Frequency bounds', ...
        'Adjust Frequency parameters or toggle Adjust button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds frequency range';
elseif isequal('cripple', Mess)
    Mess = 'Different # frequency steps in the two DA channels';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') frequency steps.'] 'Increase stepsize or decrease range'};
end
GUImessage(figh,Mess, 'error', FQnames);
if isempty(ModFreq), return; end

% get mod frequency from P & compute freqs of sidebands
[Fcar, ModFreq, ModDepth] = SameSize(Fcar, ModFreq, P.ModDepth);
ModFreq = ModFreq.*(ModDepth~=0); % set ModFreq to zero if ModDepth vanishes
Flo = Fcar-ModFreq;
Fhi = Fcar+ModFreq;

% check if stimulus frequencies are within stimFreqRange(EXP)
somethingwrong=1;
if any(Flo(:)<EXP.minStimFreq),
    GUImessage(figh, {'Lower sideband violates min stim frequency'...
        ['of ' num2str(EXP.minStimFreq) ' Hz']},'error', FQnames);
elseif any(Fhi(:)>EXP.maxStimFreq),
    GUImessage(figh, {'Upper sideband exceeds max stim frequency'...
        ['of ' num2str(EXP.maxStimFreq) ' Hz']},'error', FQnames);
else, % passed all the tests..
    somethingwrong=0;
end
if somethingwrong, return; end

okay=1;





