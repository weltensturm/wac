@echo off

SET WAC_DIR="%~dp0" || goto fail
pushd %TEMP% || goto fail

mkdir "WAC Aircraft" || goto fail

xcopy "%~dp0WAC Base\*" "WAC Aircraft" /S /Y /Q || goto fail
xcopy "%~dp0WAC Aircraft\*" "WAC Aircraft" /S /Y /Q || goto fail
xcopy "%~dp0addon.json" "WAC Aircraft\" /Y /Q || goto fail

gmad.exe create -folder "WAC Aircraft" -out wac.gma || goto fail
echo Press 'enter' to upload the package.
pause
gmpublish.exe update -addon wac.gma -id 104990330 || goto fail

goto done

:fail
echo Error while publishing.

:done
rmdir /s /q "WAC Aircraft"
popd
