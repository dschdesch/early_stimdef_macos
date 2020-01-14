function P=Summary(Nlines)
% Summary - panel displaying a summary of the varied parameters of the stimulus for stimulus GUIs.
%   P=Summary(...) returns a GUIpanel containing a messenger
%   for displaying a summary of the different values of the varied
%   parameter.
%
%   Use reportSummary to compute and report the actual play time.
%
%   Summary is a helper function for stimulus definitions like stimdefFS.
%
%   See StimGUI, GUIpanel, ReportSummary, stimdefFS.


P = GUIpanel('SummaryPanel', 'Summary'); % no title
M = messenger('Summary', ...
    '-- L -------------------- R ------------------ ', ...
    Nlines, 'ForegroundColor', [0 0 0]);
P = add(P, M, 'below', [0 0]);








