cls

@ECHO OFF

ECHO --[ START ]--

SET SOURCEDIR=C:\Users\ZycaR\Documents\ns2_gg\source\modelsrc\marine\female
SET OUTPUTDIR=C:\Users\ZycaR\Documents\ns2_gg\output\models\marine\female

ECHO -- Replace "female" files

xcopy female\*.dds %SOURCEDIR%\ /R /Y
xcopy female\*.material %SOURCEDIR%\ /R /Y
xcopy female\*.dds %OUTPUTDIR%\ /R /Y
xcopy female\*.material %OUTPUTDIR%\ /R /Y

ECHO --[ FINISH ]--

ECHO --------------------------
ECHO [ %date% %time% ]
ECHO --------------------------
