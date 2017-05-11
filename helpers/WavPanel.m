function WavFiles=WavPanel(T, EXP);
% WavPanel - generic SPL and DAchannel panel for stimulus GUIs.
%   S=WavPanel(Title, EXP) returns a GUIpanel M named 'WavFiles' allowing
%   the user to specify a .wavlist file from which the locations of the wav
%   file to be played are determined. Guipanel S has title Title. EXP is the 
%   experiment definition, from which the number of DAC channels used 
%   (1 or 2) is determined. Title='-' results in standard title 'SPLs & 
%   active channels'
%
%   The paramQuery objects contained in S are
%       WAVfiles: the full location of the .wavlist file
%
%   WavPanel is a helper function for stimulus definitions like stimdefFS.
% 
%   M=WavPanel(Title, ChanSpec, Prefix, 'Foo') prepends the string Prefix
%   to the paramQuery names, e.g. SPL -> NoiseSPL, etc, and calls the
%   components whose SPL is set by the name Foo.
%
%   Use EvalWavPanel to check the feasibility of SPLs and to update the 
%   MaxSPL messenger display.
%
%   See StimGUI, GUIpanel, stimdefWAV.
if isequal('-',T), T = 'WAV files'; end

WavList = ParamQuery('WavList', 'WavList file:', 'XXXXXXXXXXXXXXXXXXXXXXXXX', '', 'string',  '.wavList file containing full pathnames of wav files to play.', 1e2, 'fontsize', 10);
WavListButton = ActionButton('WavListButton',  'Browse...', 'xxxxxxxx', 'Click to browse for a wavList file.', @(Src,Ev,LR)local_dialog, 'fontsize',8);


WavFiles = GUIpanel('WAVfiles', T);
WavFiles = add(WavFiles,WavList,'below');
WavFiles = add(WavFiles,WavListButton, nextto(WavList));
WavFiles = marginalize(WavFiles, [0 3]);


function local_dialog
Q = getGUIdata(gcbf, 'Query');
[FileName,PathName] = uigetfile('*.wavList','Select the wavList file');
he = edithandle(Q('WavList'));
set(he, 'string', [PathName FileName]); drawnow;



