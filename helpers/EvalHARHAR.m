function [ P ] = EvalHARHAR( P , figh)
%EvalHARHAR Evaluates the Noise, Distortion and Phase Panels

if strcmpi(P.PhaseType,'schroeder') && (P.Cphase<-1 || P.Cphase>1)
    GUImessage(figh, 'C must be larger then -1 and smaller then 1', 'error', {'Cphase'});
    error('C must be larger then -1 and smaller then 1');
end

if strcmpi(P.PhaseType,'random') && isnan(P.PhaseSeed)
    P.PhaseSeed = round(rand(1,1)*1e6);
end

if strcmpi(P.AddNoise,'yes')
    if P.NoiseLowFreq > P.NoiseHighFreq
        GUImessage(figh, 'The Low Freq of the noise must be lower then the high Freq of the noise.', ...
            'error', {'NoiseLowFreq' 'NoiseHighFreq'});
        error('The Low Freq of the noise must be lower then the high Freq of the noise.');
    end
end

if P.NoiseSPL <= 0
     GUImessage(figh, 'The Noise SPL must be larger then zero.', ...
            'error', {'NoiseSPL'});
     error('The Noise SPL must be larger then zero.');   
end

if P.DistortionSPL <= 0
     GUImessage(figh, 'The Noise SPL must be larger then zero.', ...
            'error', {'DistortionSPL'});
     error('The Noise SPL must be larger then zero.');   
end

if isnan(P.NoiseSeed)
    P.NoiseSeed = round(rand(1,1)*1e6);
end

end

