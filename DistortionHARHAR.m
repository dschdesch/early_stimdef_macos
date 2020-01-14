function Distortion=DistortionHARHAR(T, EXP);
% DistortionHARHAR - Panel for the GUI to specify distortion tones.
%   F=DistortionHARHAR(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify if distortion tones.  The Guipanel F has title Title. 
%   EXP is the experiment definition, from which the number of DAC channels 
%   used (1 or 2) is determined.
%
%   See StimGUI, GUIpanel, makestimHARHAR.


%==========frequency GUIpanel=====================
Distortion = GUIpanel('Disortion', T);

DeltaF0 = ParamQuery('DeltaF0', 'Delta F0:', '1200', ...
    'Hz','rreal', 'The change in frequency between F0 and the distortion tone');
SPL = ParamQuery('DistortionSPL', 'Distortion SPL:', '50', ...
    'dB SPL','rreal', 'The Intensity of the distortion tone.');
Fmod = ParamQuery('DistortionFmod', 'Fmod:', '200', ...
    'Hz','rreal', 'The frequency at which the distortion tone is modulated. Zero Hz indicates no Modulation');



Distortion = add(Distortion, DeltaF0);
Distortion = add(Distortion, SPL, below(DeltaF0));
Distortion = add(Distortion, Fmod, below(SPL));





