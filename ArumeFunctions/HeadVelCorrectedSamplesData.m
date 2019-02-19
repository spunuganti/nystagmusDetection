function [resampledData,rawHeadVel] = HeadVelCorrectedSamplesData(resampledData,samplesDataTable,HeadVelThresh,padding)

% TO DO : CHANGE PADDING TO MAKE IT UBIQUITOUS BY INCORPORATING THE
% SAMPLING FREQUENCY

[eyes, eyeSignals, headSignals] = VOGAnalysis.GetEyesAndSignals(samplesDataTable.Properties.UserData.calibratedData);

cleanedData = samplesDataTable.Properties.UserData.cleanedData;

calibratedData = samplesDataTable.Properties.UserData.calibratedData;

qresampled=[]; qraw=[];

for k = 1:length(eyes)
    
    for p = 1:length(headSignals)
        
        % First putting nans where the position data was
        % removed -----> WOULD BE USEFUL MIGHT BE ?? TO
        % COMPUTE MORE CONSTRICTIVE VELOCITY THRESHOLD?
        nom = ['Head' headSignals{p}];
        
        % Filtering the head data
        temp = interp1(cleanedData.Time(~isnan(cleanedData.(nom))),...
            cleanedData.(nom)(~isnan(cleanedData.(nom))),cleanedData.Time,'pchip');
%         [~,g] = sgolay(1,11);
%         temp = conv(temp,g(:,1),'same');
        temp = sgolayfilt(temp,1,11);
        cleanedData.(nom)(~isnan(cleanedData.(nom))) = temp(~isnan(cleanedData.(nom)));
        
        temp2 = interp1(calibratedData.Time(~isnan(calibratedData.(nom))),...
            calibratedData.(nom)(~isnan(calibratedData.(nom))),cleanedData.Time,'pchip');
%         temp2 = conv(temp2,g(:,1),'same');
        temp2 = sgolayfilt(temp2,1,11);
        
        % Resampsling the head Data
        if ( sum(~isnan(cleanedData.(nom))) > 100 ) % if not everything is nan
            
            % interpolate nans so the resampling does not
            % propagate nans
            xNoNan = interp1(find(~isnan(cleanedData.(nom))), cleanedData.(nom)(~isnan(cleanedData.(nom))),...
                1:length(cleanedData.(nom)),'spline');
            
            % upsample
            resampledData.(nom) = interp1(cleanedData.Time, xNoNan,samplesDataTable.Time,'pchip');
            [~,g] = sgolay(1,51);
            resampledData.(nom) = conv(resampledData.(nom),g(:,1),'same');
%             resampledData.(nom) = sgolayfilt(resampledData.(nom),1,51); % Filtering the headVelocity
            
            % set nans in the upsampled signal
            xnan = interp1(cleanedData.Time, double(isnan(cleanedData.(nom))),samplesDataTable.Time);
            resampledData.(nom)(xnan>0) = nan;
        end
        
        % Creating the quaternion object
        qresampled = [qresampled, resampledData.(nom)];
        qraw = [qraw, temp2];
    end


% Getting the head angular velocity for the calibrated data
quat = quaternion(qraw); % Forming a quaternion Class object
quat = Normalizen(quat); % Normalizing the Quaternion object
[omega,~] = OmegaAxis(quat,cleanedData.Time); % Calculating the head velocity
omega = omega'.*(180/pi); %converting to deg/sec
rawHeadVel = omega(~isnan(cleanedData.RawFrameNumber)); % Transposing to keep vertical vector consistent throughout
clear quat omega qraw

% Getting the head angular velocity for the cleaned data
quat = quaternion(qresampled); % Forming a quaternion Class object
quat = Normalizen(quat); % Normalizing the Quaternion object
[omega,~] = OmegaAxis(quat,resampledData.Time); % Calculating the head velocity
omega = omega'.*(180/pi); 
resampledData.HeadAngularVel = omega;  %converting to deg/sec; % Transposing to keep vertical vector consistent throughout

% TO DO: better implementation than thresholding like peak detection maybe?

% mn = nanmean(omega); sd = nanstd(omega);
% HeadVelThresh = mn+sd;
indxs = find(resampledData.HeadAngularVel>=HeadVelThresh);
 

for p=1:length(eyeSignals)
    for q = 1:numel(indxs)
        resampledData.([eyes{k} eyeSignals{p}])(max(1,indxs(q)-padding):min(height(resampledData),indxs(q)+padding),1) = nan;
%         resampledData.([eyes{k} eyeSignals{p}])(resampledData.HeadAngularVel>=HeadVelThresh) = nan;
    end
end

end

end