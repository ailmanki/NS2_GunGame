cls

@ECHO OFF

ECHO --[ START ]--

SET SOURCEDIR=C:\Users\ZycaR\Documents\ns2_gg\source\modelsrc\marine\exosuit
SET OUTPUTDIR=C:\Users\ZycaR\Documents\ns2_gg\output\models\marine\exosuit

ECHO --Replace "exosuit" files

xcopy exosuit\*.dds %SOURCEDIR%\ /R /Y
xcopy exosuit\*.material %SOURCEDIR%\ /R /Y
xcopy exosuit\*.dds %OUTPUTDIR%\ /R /Y
xcopy exosuit\*.material %OUTPUTDIR%\ /R /Y

ECHO --[ FINISH ]--

ECHO --------------------------
ECHO [ %date% %time% ]
ECHO --------------------------
