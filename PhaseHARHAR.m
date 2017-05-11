function PhasePanel=PhaseHARHAR(T, EXP);
% PhaseHARHAR - Phase panel for the HARHAR stimulus GUIs.
%   F=PhaseHARHAR(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify the phase component of the harmonic.
%   The Guipanel F has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%   See StimGUI, GUIpanel, makestimHARHAR.



%==========Phase GUIpanel=====================
PhasePanel = GUIpanel('Phase', T);
PhaseSeed = ParamQuery('PhaseSeed', 'PhaseSeed:', '1200', '', ...
    'rreal/positive', 'Fill in the Seed value for the Random Phase.');
C = ParamQuery('Cphase', 'C:', '1200', '', ...
    'rreal', 'Fill in the C value for the Schroeder Phase. C must be between -1 & 1');
Type = ParamQuery('PhaseType', 'Type:', '', {'Cos' 'Alt' 'Schroeder' 'Random'}, ...
    '', 'Select the type of phase applied to the harmonics.');


PhasePanel = add(PhasePanel, Type);
PhasePanel = add(PhasePanel, C, below(Type));
PhasePanel = add(PhasePanel, PhaseSeed, nextto(C));






