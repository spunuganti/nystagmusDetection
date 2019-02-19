function dataTable = LoadSpvData(dataFile)
    
    if ( ~exist(dataFile, 'file') )
        error( ['Data file ' dataFile ' does not exist.']);
    end
    
    load(dataFile)
    
    
    varnames = {
    'LeftFrameNumberRaw' 'LeftSeconds' 'LeftX' 'LeftY' 'LeftPupilWidth' 'LeftPupilHeight' 'LeftPupilAngle' 'LeftIrisRadius' 'LeftTorsionAngle' 'LeftUpperEyelid' 'LeftLowerEyelid' 'LeftDataQuality' ...
    'RightFrameNumberRaw' 'RightSeconds' 'RightX' 'RightY' 'RightPupilWidth' 'RightPupilHeight' 'RightPupilAngle' 'RightIrisRadius' 'RightTorsionAngle'  'RightUpperEyelid' 'RightLowerEyelid' 'RightDataQuality' ...
    'AccelerometerX' 'AccelerometerY' 'AccelerometerZ' 'GyroX' 'GyroY' 'GyroZ' 'MagnetometerX' 'MagnetometerY' 'MagnetometerZ' ...
    'KeyEvent' ...
    'Int0' 'Int1' 'Int2' 'Int3' 'Int4' 'Int5' 'Int6' 'Int7' ...
    'Double0' 'Double1' 'Double2' 'Double3' 'Double4' 'Double5' 'Double6' 'Double7' };
    
    


end