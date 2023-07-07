@echo off

for /f %%I in ('powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog; $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer; $folderBrowser.Description = 'Wybierz folder'; $folderBrowser.ShowDialog() | Out-Null; $folderBrowser.SelectedPath"') do set "folder=%%I"

npx create-react-app %folder% --template redux-typescript