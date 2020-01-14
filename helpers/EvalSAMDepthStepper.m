function [okay, ModDepth]=EvalSAMDepthStepper(figh, Prefix, P, Fcar)
% EvalSAMDepthStepper - compute modulation depth series from SAM depth stepper GUI
%   ModDepth=EvalSAMDepthStepper(figh) reads depth-stepper specs
%   from paramqueries StartModDepth, StepModDepth, EndModDepth
%   in the GUI figure with handle figh (see SAMDepthStepper), and converts
%   them to the individual depths of the depth-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value ModDepth, while an error message is displayed by GUImessage.
%
%   EvalSAMDepthStepper(figh, 'Foo') uses prefix Foo for the query names,
%   i.e., FooStartFreq, etc. The prefix defaults to ''.
%
%   EvalSAMDepthStepper(figh, Prefix, P) does not read the queries, but
%   extracts them from struct P which was previously returned by GUIval.
%   This is the preferred use of EvalSAMDepthStepper, because it leaves
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
FQnames = {[Prefix 'StartModDepth'] [Prefix 'StepModDepth'] [Prefix 'EndModDepth']};




StepMode = 'Linear'; % depth stepping is linear
Adjust = 'None'; % adjustment is 'None', because only linear stepping 
                 % so adjustment is not really needed

% delegate the computation to generic EvalStepper
[ModDepth, Mess]=EvalStepper(P.StartModDepth, P.StepModDepth, P.EndModDepth, StepMode, ...
    Adjust, [-inf inf], EXP.maxNcond);
if isequal('nofit', Mess),
    Mess = {'Ste psize does not exactly fit depth bounds'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds range';
elseif isequal('cripple', Mess)
    Mess = 'Different # steps in the two DA channels';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') steps.'] 'Increase stepsize or decrease range'};
end
GUImessage(figh,Mess, 'error', FQnames);
if isempty(ModDepth), return; end

% get mod frequency from P & compute freqs of sidebands
[Fcar, ModFreq, ModDepth] = SameSize(Fcar, P.ModFreq, ModDepth);
ModFreq = ModFreq.*(ModDepth~=0); % set ModFreq to zero if ModDepth vanishes
Flo = Fcar-ModFreq;
Fhi = Fcar+ModFreq;

% check if stimulus frequencies are within stimFreqRange(EXP)

somethingwrong=1;
if any(Flo(:)<EXP.minStimFreq),
    GUImessage(figh, {'Lower sideband violates min stim frequency'...
        ['of ' num2str(EXP.minStimFreq) ' Hz']},'error', [Prefix 'ModFreq']);
elseif any(Fhi(:)>EXP.maxStimFreq),
    GUImessage(figh, {'Upper sideband exceeds max stim frequency'...
        ['of ' num2str(EXP.maxStimFreq) ' Hz']},'error', [Prefix 'ModFreq']);
else, % passed all the tests..
    somethingwrong=0;
end
if somethingwrong, return; end

okay=1;





