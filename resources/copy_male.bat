cls

@ECHO OFF

ECHO --[ START ]--

SET SOURCEDIR=C:\Users\ZycaR\Documents\ns2_gg\source\modelsrc\marine\male
SET OUTPUTDIR=C:\Users\ZycaR\Documents\ns2_gg\output\models\marine\male

ECHO -- Tundra marine

xcopy male\*.dds %SOURCEDIR%\ /R /Y
xcopy male\*.material %SOURCEDIR%\ /R /Y
xcopy male\*.dds %OUTPUTDIR%\ /R /Y
xcopy male\*.material %OUTPUTDIR%\ /R /Y

ECHO --[ FINISH ]--

ECHO --------------------------
ECHO [ %date% %time% ]
ECHO --------------------------
