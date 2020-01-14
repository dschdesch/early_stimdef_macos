function [strSPL, strSpec1, strSpec2] = stimdispILD(Stim)
% stimdispILD - strings describing specific parameters of ILD stimulus
%    [strSPL, strSpec1, strSpec2] = stimdispILD(Stim) returns strings
%    strSPL, strSpec1, strSpec2 describing the stimulus parameters of the
%    ILD stimulus. Stim is the struct containing all the stimulus
%    parameters (see stimdefILD). These strings are used by
%    dataset/stimlist and determine the listing in databrowse.
%
%    See also stimGUI, dataset/stimlist, dataset/stimlist_strfun, databrowse.

STR = stimlist_strfun(dataset); % helpers for num->str conversion

strSPL = [STR.shstring(Stim.Fcar) ' ' Stim.FcarUnit]; % when SPL is the first varied parameter, i.e. Stim.Presentation.X, Fcar is shown here 
strSpec1 = STR.modstr(Stim);
strSpec2 = ['CSTSPL ' STR.shstring(Stim.ConstantSPL) ' ' Stim.ConstantSPLUnit]; % constant level for the other ear 