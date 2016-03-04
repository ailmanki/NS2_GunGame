cls

@ECHO OFF

ECHO --[ START ]--

SET SOURCEDIR=C:\Users\ZycaR\Documents\ns2_gg\source\uisrc
SET OUTPUTDIR=C:\Users\ZycaR\Documents\ns2_gg\output\ui

ECHO -- GameEnd

SET FILENAME=GUIGunGameEnd.dds
del %SOURCEDIR%\%FILENAME%
del %OUTPUTDIR%\%FILENAME%
copy %FILENAME% %SOURCEDIR%\%FILENAME%
copy %FILENAME% %OUTPUTDIR%\%FILENAME%

ECHO --[ FINISH ]--

ECHO --------------------------
ECHO [ %date% %time% ]
ECHO --------------------------
