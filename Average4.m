function [amp_avg,phase_avg] = Average4(compassAng,vidMeanPhase0,vidMeanAmp0,ref_angle)
amp_avg = zeros(72,4);
phase_avg = zeros(72,4);

    for i = 1:72
        compassAng_sel=abs(mod(mod(ref_angle-compassAng,360)-(i-1)*5+180,360)-180)<2.5;
        
        vidMeanPhase0_temp= vidMeanPhase0(compassAng_sel,:);
        vidMeanPhase0_temp=vidMeanPhase0_temp(2:end-1,:);
        vidMeanAmp0_temp= vidMeanAmp0(compassAng_sel,:);
        vidMeanAmp0_temp=vidMeanAmp0_temp(2:end-1,:);
        
        phase_avg(i,:)=mean(unwrap(vidMeanPhase0_temp));
        amp_avg(i,:)=mean(vidMeanAmp0_temp);
    end
    
end
