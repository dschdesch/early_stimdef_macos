function PulseType=EvalClickPanel(figh, Prefix, P);
% EvalClickPanel - convert pulse type from click panel GUI
%   PulseType=EvalClickPanel(figh) reads click specs
%   from paramqueries PulseType
%   in the GUI figure with handle figh (see clickPanel), and converts
%   them to an integer number to be used in clikStim.
%   Any errors in the user-specified values results in an empty return 
%   value Freq, while an error message is displayed by GUImessage.
%
%   EvalClickPanel(figh, 'Foo') uses prefix Foo for the query names,
%   i.e., FooStartFreq, etc. The prefix defaults to ''.
%
%   EvalClickPanel(figh, Prefix, P) does not read the queries, but
%   extracts them from struct P which was previously returned by GUIval.
%   This is the preferred use of EvalClickPanel, because it leaves
%   the task of reading the parameters to the generic GUIval function. The
%   first input arg figh is still needed for error reporting.
%
%   See StimGUI, FrequencyStepper, GUIval, GUImessage.

if nargin<2, Prefix=''; end
if nargin<3, P = []; end

PulseType = [];

if isempty(P), % obtain info from GUI. Non-preferred method; see help text.
    return;
else
    P = dePrefix(P, Prefix);
end

% Convert pulse type
PulseStr = P.PulseType;
PulseType = 1;
if strfind(PulseStr,'biphasic')
    PulseType = 2;
elseif strfind(PulseStr,'alternate')
    PulseType = 3;
end

if strfind(PulseStr,'-')
    PulseType = -PulseType;
end
