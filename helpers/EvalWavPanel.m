function [WavFile, Nwav]=EvalWavPanel(figh, Prefix, P)
% EvalWavPanel - compute frequency series from Frequency stepper GUI
%   Freq=EvalWavPanel(figh) reads the location of the .wavlist file
%   in the GUI figure with handle figh (see WavPanel), and converts
%   it to the locations of the wav files listed in that file if they exist.
%   Any errors in the user-specified values results in an empty return 
%   value WavFile, while an error message is displayed by GUImessage.
%
%   EvalWavPanel(figh, 'Foo') uses prefix Foo for the query names,
%   i.e., FooStartFreq, etc. The prefix defaults to ''.
%
%   EvalWavPanel(figh, Prefix, P) does not read the queries, but
%   extracts them from struct P which was previously returned by GUIval.
%   This is the preferred use of EvalWavPanel, because it leaves
%   the task of reading the parameters to the generic GUIval function. The
%   first input arg figh is still needed for error reporting.
%
%   See StimGUI, WavPanel, GUIval, GUImessage.

if nargin<2, Prefix=''; end
if nargin<3, P = []; end

P = dePrefix(P, Prefix);
EXP = P.Experiment;

[WavFile, Nwav, OK, Mess] = local_readWavList(P.WavList);

if ~OK
    GUImessage(figh, Mess, 'error', [Prefix 'WavList']);
    return;
end


function [wavFileNames, Nwav, OK, Mess] = local_readWavList(wavlistname)
OK = 0;
wavFileNames = {};
Nwav = 0;
Mess = '';
% does wavlistfile exist?
[PP NN EXT] = fileparts(wavlistname);
if isempty(NN),
   Mess = 'No WavList file specified';
   return;
end;
%if isempty(PP), PP = [StimMenuStatus.wavlistDir]; end;
%if isempty(EXT), EXT = '.wavlist'; end;
%fullWLname = [PP '\' NN EXT];
% check existence of wavlist file
if ~isequal(2,exist(wavlistname,'file')),
   Mess = ['Cannot find wavlist file ''' NN ''''];
   return;
end
% read wavlist file
wavFileNames = ...
   textread(wavlistname, '%s', 'commentstyle','matlab');
% check existence and file type of wav files listed
Nwav = length(wavFileNames);
for iwav=1:Nwav,
   [PP2 NN2 EXT2] = fileparts(wavFileNames{iwav});
   if isempty(EXT2), 
      EXT2 = '.wav'; 
   else, % check/provide extension
      if ~isequal(lower(EXT2),'.wav'),
         Mess = strvcat(['''' NN2 EXT2 ''' is not a WAV file'],...
            ['[item number ' num2str(iwav) ' in wavlist file ''' NN ''']']);
         return;
      end
   end;
   % existence
   wavFileNames{iwav} = [PP2 '\' NN2 EXT2];
   wfn = wavFileNames{iwav};
   if ~isequal(2,exist(wfn,'file')),
      Mess = strvcat(['Cannot find wav file ''' NN2 ''''],...
         ['[item number ' num2str(iwav) ' in wavlist file ''' NN ''']']);
      return;
   end
end;
OK = 1;
