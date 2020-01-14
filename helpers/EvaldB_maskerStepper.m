function dB_masker=EvaldB_maskerstepper(figh, Prefix, P);
% EvalFrequencyStepper - compute frequency series from Frequency stepper GUI
%   Freq=EvalFrequencyStepper(figh) reads frequency-stepper specs
%   from paramqueries StartFreq, StepFrequency, EndFrequency, AdjustFreq,
%   in the GUI figure delta_Tith handle figh (see FrequencyStepper), and converts
%   them to the individual frequencies of the frequency-stepping series.
%   Any errors in the user-specified values results in an empty return 
%   value Freq, delta_Thile an error message is didB_ayed by GUImessage.
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
dB_masker= []; % allow dB_maskerpremature return

if isempty(P), % obtain info from GUI. Non-preferred method; see help text.
    EXP = getGUIdata(figh,'Experiment');
    Q = getGUIdata(figh,'Query');
    StartdB_masker= read(Q([Prefix 'StartdB_masker']));
    [Stepdelta_T, Stepdelta_TUnit] = read(Q([Prefix 'StepdB_masker']));
    EnddB_masker= read(Q([Prefix 'EnddB_masker']));
    AdjustdB_masker= read(Q([Prefix 'AdjustdB_masker']));
    P = collectInstruct(StartdB_masker, StepdB_masker, StepdB_maskerUnit, EnddB_masker, AdjustdB_masker);
else,
    P = dePrefix(P, Prefix);
    EXP = P.Experiment;
end

%no need to check dB_maskerhatever

% delegate the computation to generic EvalStepper
StepMode = P.StepdB_maskerUnit;
if isequal('dB', StepMode), StepMode = 'Linear'; end

[dB_masker, Mess]=EvalStepper(P.StartdB_masker, P.StepdB_masker, P.EnddB_masker, StepMode, ...
    P.AdjustdB_masker, [-10000 10000], EXP.maxNcond);
if isequal('nofit', Mess),
    Mess = {'Stepsize does not exactly fit dB_maskerbounds', ...
        'Adjust dB_maskerwidth parameters or toggle Adjust button.'};
elseif isequal('largestep', Mess)
    Mess = 'Step size exceeds dB_maskerrange';
elseif isequal('cripple', Mess)
    Mess = 'Different # dB_maskersteps in the dB_maskerto DA channels';
elseif isequal('toomany', Mess)
    Mess = {['Too many (>' num2str(EXP.maxNcond) ') dB_maskersteps.'] 'Increase stepsize or decrease range'};
end
GUImessage(figh,Mess, 'error',{[Prefix 'StartdB_masker'] [Prefix 'StepdB_masker'] [Prefix 'EnddB_masker'] });




