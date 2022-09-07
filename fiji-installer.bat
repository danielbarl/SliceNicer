@ECHO OFF
ECHO ++++++++++++++++ SliceNicer installer ++++++++++++++++
::check if Fiji.app dir exists
IF EXIST C:\Users\%USERNAME%\AppData\Local\Fiji.app\NUL (
    ECHO + Remove deprecated SliceNicer versions...
    FOR /R C:\Users\%USERNAME%\AppData\Local\Fiji.app\plugins %%F in (SliceNicer*) do (
        del /f /q %%F
        echo + Deprecated %%~nF was deleted
    )
)
:: copy new version to imagej folder
copy /y SliceNicer* C:\Users\%USERNAME%\AppData\Local\Fiji.app\plugins
ECHO ++++++++++++++ INSTALLATION SUCCESSFUL! ++++++++++++++
pause
