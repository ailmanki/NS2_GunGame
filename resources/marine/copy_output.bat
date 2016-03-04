cls

@ECHO OFF

ECHO --[ START ]--

SET SOURCEDIR=C:\Users\ZycaR\Documents\ns2_gg\source\modelsrc\marine
SET OUTPUTDIR=C:\Users\ZycaR\Documents\ns2_gg\output\models\marine

ECHO -- Tundra marine

SET FILENAME=male_tundra_colorMap.dds
del %SOURCEDIR%\male\%FILENAME%
del %OUTPUTDIR%\male\%FILENAME%
copy %FILENAME% %SOURCEDIR%\male\%FILENAME%
copy %FILENAME% %OUTPUTDIR%\male\%FILENAME%

ECHO -- Assault marine

SET FILENAME=male_assault_colorMap.dds
del %SOURCEDIR%\male\%FILENAME%
del %OUTPUTDIR%\male\%FILENAME%
copy %FILENAME% %SOURCEDIR%\male\%FILENAME%
copy %FILENAME% %OUTPUTDIR%\male\%FILENAME%

ECHO -- Deluxe marine

SET FILENAME=male_deluxe_colorMap.dds
del %SOURCEDIR%\male\%FILENAME%
del %OUTPUTDIR%\male\%FILENAME%
copy %FILENAME% %SOURCEDIR%\male\%FILENAME%
copy %FILENAME% %OUTPUTDIR%\male\%FILENAME%

ECHO -- Normal marine

SET FILENAME=male_body_colorMap.dds
del %SOURCEDIR%\male\%FILENAME%
del %OUTPUTDIR%\male\%FILENAME%
copy %FILENAME% %SOURCEDIR%\male\%FILENAME%
copy %FILENAME% %OUTPUTDIR%\male\%FILENAME%

ECHO --[ FINISH ]--

ECHO --------------------------
ECHO [ %date% %time% ]
ECHO --------------------------
