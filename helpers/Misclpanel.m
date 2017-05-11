function Miscl=Misclpanel(T, EXP, list_params);
% SPLpanel - generic SPL and DAchannel panel for stimulus GUIs.
%   S=SPLpanel(Title, EXP) returns a GUIpanel M named 'Levels' allowing the 
%   user to specify a fixed sinusiodal amplitude modulation to be applied 
%   to all the stimuli of a series. Guipanel S has title Title. EXP is the 
%   experiment definition, from which the number of DAC channels used 
%   (1 or 2) is determined. Title='-' results in standard title 'SPLs & 
%   active channels'
%
%   The paramQuery objects contained in S are
%         SPL: level of stimuli in dB SPL
%         DAC: active DA channel
%   The messenger contained in S is
%       MaxSPL: report of max attainable SPL (filled by MakeStimXXX)
%
%   SPLpanel is a helper function for stimulus definitions like stimdefFS.
% 
%   M=SPLpanel(Title, ChanSpec, Prefix, 'Foo') prepends the string Prefix
%   to the paramQuery names, e.g. SPL -> NoiseSPL, etc, and calls the
%   components whose SPL is set by the name Foo.
%
%   Use EvalSPLpanel to check the feasibility of SPLs and to update the 
%   MaxSPL messenger display.
%
%   See StimGUI, GUIpanel, ReportMaxSPL, stimdefFS, SPLstepper.

% # DAC channels fixes the allowed multiplicity of user-specied numbers

% [Prefix, CmpName] = arginDefaults('Prefix/CmpName', '', 'Carrier');

if isequal('-',T), T = 'Miscl params'; end

ClickStr = ' Click button to select ';

Miscl = GUIpanel('Misc', T);

for iparam=1:length(list_params)
   param=list_params{iparam};
   tmp = ParamQuery(param{1},param{2},param{3},param{4},param{5},param{6},param{7}); 
   Miscl = add(Miscl,tmp,'below',[0,0]);
end
