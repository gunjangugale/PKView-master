echo off
rmdir C:\PkView_%username% /q /s

md C:\PkView_%username%
cd %~dp0
xcopy "Installation Package\OCP" C:\PkView_%username% /E /K

cd C:\PkView_%username%\iPortal\webroot\App_Data\userData
ren Peter %username%

cd C:\PkView_%username%\iPortal 
icacls webroot /grant %username%:(RX,R) /t
cd C:\PkView_%username%\iPortal\webroot\App_Data
icacls userData /grant %username%:F /t

cd C:\PkView_%username%\Sasjobs.Api
icacls webroot /grant %username%:(RX,R) /t

net share clinical /delete
net share "Output Files" /delete

cd C:\PkView_%username%\data
net share clinical=C:\PkView_%username%\data\clinical /GRANT:everyone,FULL
icacls "C:\PkView_%username%\Sasjobs.Standalone\Stored Procedures\Output Files" /grant %username%:F /t
net share "output files"="C:\PkView_%username%\Sasjobs.Standalone\Stored Procedures\Output Files" /GRANT:everyone,FULL

cd %windir%\system32\inetsrv
appcmd delete site "Default Web Site"
appcmd delete apppool "DefaultAppPool"
appcmd delete apppool "iPortal Pool"
appcmd delete apppool "SasJobs Pool"
appcmd delete site "iPortal"
appcmd delete site "SasJobs.Api"

appcmd add apppool /name:"iPortal Pool" /managedRuntimeVersion:"v4.0" /autoStart:"true" /managedPipelineMode:"Integrated" /processModel.identityType:"SpecificUser" /processModel.userName:"%username%" /processModel.password:"ocpkm"

appcmd add site /name:"iPortal" /id:1 /physicalPath:"C:\PkView_%username%\iPortal\webroot" /bindings:http/"*:80:" /serverAutoStart:"true"
appcmd set app "iPortal/" /applicationPool:"iPortal Pool"
appcmd set config -section:system.applicationHost/sites /[name='iPortal'].logFile.logFormat:"W3C"
appcmd set config -section:system.applicationHost/sites /[name='iPortal'].logFile.period:"Daily"
appcmd set config -section:system.applicationHost/sites /[name='iPortal'].logFile.directory:"C:\PkView_%username%\iPortal\logs"
appcmd set config /section:windowsAuthentication /enabled:true
appcmd set config /section:staticContent /+[fileExtension='.woff',mimeType='application/x-font-woff']

appcmd add apppool /name:"SasJobs Pool" /managedRuntimeVersion:"v4.0" /autoStart:"true" /managedPipelineMode:"Integrated" /processModel.identityType:"SpecificUser" /processModel.userName:"%username%" /processModel.password:"ocpkm" 

appcmd add site /name:"SasJobs.Api" /id:2 /physicalPath:"C:\PkView_%username%\SasJobs.Api\webroot" /bindings:http/"*:5455:" /serverAutoStart:"true"
appcmd set app "SasJobs.Api/" /applicationPool:"SasJobs Pool"
appcmd set config -section:system.applicationHost/sites /[name='SasJobs.Api'].logFile.logFormat:"W3C"
appcmd set config -section:system.applicationHost/sites /[name='SasJobs.Api'].logFile.period:"Daily"
appcmd set config -section:system.applicationHost/sites /[name='SasJobs.Api'].logFile.directory:"C:\PkView_%username%\SasJobs.Api\logs"

rmdir C:\PkView_%username%\iPortal_Publish /q /s
rmdir C:\PkView_%username%\SasJobs_Publish /q /s

md C:\PkView_%username%\iPortal_Publish
md C:\PkView_%username%\SasJobs_Publish

cd %windir%\microsoft.net\framework64\v4.0.30319
msbuild "%~dp0\iPortal.sln" /t:rebuild /p:configuration=Debug
msbuild "%~dp0\SasJobs.sln" /t:rebuild /p:configuration=Debug

msbuild "%~dp0\iportal\iportal.csproj" /p:DeployOnBuild=true /p:PublishProfile="FolderProfile"
msbuild "%~dp0\SasJobs.Api\SasJobs.Api.csproj" /p:DeployOnBuild=true /p:PublishProfile="FolderProfile"

cd %~dp0
start iPortalDeploy.bat 
start SasJobsDeploy.bat 
timeout 5

xcopy "%~dp0\SasJobs.BackgroundWorker.Host\bin\Debug"  "C:\PkView_%username%\Sasjobs.Standalone" /E /K /I /Y
netsh http add urlacl url=http://+:5454/ user=%username%

taskkill /F /IM cmd.exe