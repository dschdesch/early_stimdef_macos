function Noise=LpNoiseHARHAR(T, EXP);
% LpNoiseHARHAR - Low Pass Noise for the HARHAR stimulus GUI.
%   F=LpNoiseHARHAR(Title, EXP) returns a GUIpanel F allowing the 
%   user to specify the parameters for Low Pass Noise which is added to the signal
%   The Guipanel F has title Title. EXP is the experiment 
%   definition, from which the number of DAC channels used (1 or 2) is
%   determined.
%   See StimGUI, GUIpanel, makestimHARHAR.


%==========LP Noise GUIpanel=====================
Noise = GUIpanel('Noise', T);

LF = ParamQuery('NoiseLowFreq', 'Low Freq:', '1200', ...
    'Hz','rreal/positive', 'The lowest frequency contained in the noise');
HF = ParamQuery('NoiseHighFreq', 'High Freq:', '1200', ...
    'Hz','rreal/positive', 'The highest frequency contained in the noise');
NoiseSPL = ParamQuery('NoiseSPL', 'SPL:', '1200', ...
    'dB SPL','rreal/positive', 'The intensity of the noise signal');
NoiseSeed = ParamQuery('NoiseSeed', 'Seed:', '1200', ...
    '','rreal/positive', 'A seed to generate the random signal for the noise');
AddNoise = ParamQuery('AddNoise', 'Add Noise?', '', {'Yes' 'No'}, ...
    '', 'Do you need to add Low Pass Noise to the signal.');

Noise = add(Noise, AddNoise);
Noise = add(Noise, LF, below(AddNoise));
Noise = add(Noise, HF, below(LF));
Noise = add(Noise, NoiseSPL, below(HF), [10 0]);
Noise = add(Noise, NoiseSeed, below(NoiseSPL), [0 2]);







