function [strSPL, strSpec1, strSpec2] = stimdispMBL(Stim)
% stimdispMBL - strings describing specific parameters of MBL stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispMBL(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    MBL stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefMBL). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % when SPL is the first varied parameter, i.e. Stim.Presentation.X, Fcar is shown here 
strSpec1 = STR.modstr(Stim);
strSpec2 = ['MBL ' STR.shstring(Stim.MBLSPL) ' ' Stim.MBLSPLUnit]; % mean binaural level 