<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Kill-Java
{
    [CmdletBinding()]
    Param
    (
        # Log defaults to "$env:SystemDrive\Logs\$env:COMPUTERNAME Java Runtime Removal.log"
        $Log="$env:SystemDrive\Logs\$env:COMPUTERNAME Java Runtime Removal.log",

        # force
        $force=$true,

        # Reinstall Java? crazy...
        $Reinstall=$false,

        # Java Install file and location, ForEach-Objectmated with x64.exe or x86.exe at the end. Have both in the same folder.
        $JavaBin=".\java-x64.exe",

        #Java Arg, defaults to "/s /v'ADDLOCAL=ALL IEXPLORER=1 MOZILLA=1 JAVAUPDATE=0 REBOOT=suppress' /qn"
        $JavaArgs="/s /v'ADDLOCAL=ALL IEXPLORER=1 MOZILLA=1 JAVAUPDATE=0 REBOOT=suppress' /qn"
    )

    Begin
    {
        $force_exitcode="1618"
        $Title="Java Runtime Nuker"
        $arch=$env:PROCESSOR_ARCHITECTURE
        $isXP=$false
        if((Get-WmiObject -class Win32_OperatingSystem).Caption -match "XP"){
            $isXP=$true}
        # Clear log and create log dir if it's not there
        $mkdirs = $Log.Substring(0,$Log.Length - $Log.split('\')[$Log.split('\').Count - 1].Length)
        mkdir $mkdirs -ErrorAction SilentlyContinue
        Clear-Content $Log -ErrorAction SilentlyContinue

        Write-Verbose ""
        Write-Verbose " JAVA RUNTIME NUKER"
        if($isXP=$true){Write-Verbose ""; Write-Verbose " ! Windows XP detected, using alternate command set to compensate."}
        Write-Verbose ""
        Write-Output "$(Get-Date)   Beginning removal of Java Runtime Environments (series 3-7, x86 and x64) and JavaFX..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Beginning removal of Java Runtime Environments (series 3-7, x86 and x64) and JavaFX..."

        #Do a quick check to make sure WMI is working
        $wmiproc=Start-Proc "WINMGMT.EXE" "/verifyrepository"
        if($wmiproc.ExitCode -ne 0){
            Write-Output "$(Get-Date) WMI appears to be working." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date) WMI appears to be working." 
        }else{
            Write-Output "$(Get-Date) WMI appears to be broken. It should still work. Please use WMIDiag.vbs to help diagnose. http://www.microsoft.com/en-us/download/details.aspx?id=7684" | Out-File -FilePath $Log -Append
            Write-Warning "$(Get-Date) WMI appears to be broken. It should still work. Please use WMIDiag.vbs to help diagnose. http://www.microsoft.com/en-us/download/details.aspx?id=7684" 
        }

        # I don't think this is needed any more
        # cscript.exe $WMIdiagBin LogFilePath=$env:TEMP
        $killlist="java,javaw,javaws,jqs,jusched,iexplore,iexplorer,firefox,chrome,palemoon".Split(",")
        #########
        #force-CLOSE PROCESSES #-- Do we want to kill Java beForEach-Objecte running? If so, this is where it happens
        #########
        if ($force=$true) {
	        #Kill all browsers and running Java instances
	        Write-Output "$(Get-Date)   Looking ForEach-Object and closing all running browsers and Java instances..." | Out-File -FilePath $Log -Append
	        Write-Verbose "$(Get-Date)   Looking ForEach-Object and closing all running browsers and Java instances..."
		    Write-Verbose ""
		    ForEach-Object-each ($killlist) {
			    Write-Output "Searching ForEach-Object $_.exe..."
			    (Get-Process $_).Kill() | Out-File -FilePath $Log -Append
		    }
		    Write-Verbose ""
        }

        #If we DON'T want to force-close Java, then check ForEach-Object possible running Java processes and abort the script if we find any
        if ($force=$false) {
	        Write-Output "$(Get-Date)   Variable force_CLOSE_PROCESSES is set to '$force'. Checking ForEach-Object running processes beForEach-Objecte execution." | Out-File -FilePath $Log -Append
	        Write-Verbose "$(Get-Date)   Variable force_CLOSE_PROCESSES is set to '$force'. Checking ForEach-Object running processes beForEach-Objecte execution."


	        #Search and report if processes of the list are running and exit if any are running
	        ForEach-Object-each ($killlist) {
		        Write-Output "$(Get-Date)   Searching ForEach-Object $_.exe..."
		        if(Get-Process $_){
				        Write-Output "$(Get-Date) ! ERROR: Process '$_' is currently running, aborting." | Out-File -FilePath $Log -Append
				        Write-Error "$(Get-Date) ! ERROR: Process '$_' is currently running, aborting."
				        exit $force_exitcode
			        }
		        }
	        }
	        #If we made it this far, we didn't find anything, so we can go ahead
	        Write-Output "$(Get-Date)   All clear, no running processes found. Going ahead with removal..." | Out-File -FilePath $Log -Append
	        Write-Verbose "$(Get-Date)   All clear, no running processes found. Going ahead with removal..."
        }


        ########
        #UNINSTALLER SECTION #-- Basically here we just brute-force every "normal" method ForEach-Object
        ########   removing Java, and then resort to more painstaking methods later
        Write-Output "$(Get-Date)   Targeting individual JRE versions..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Targeting individual JRE versions..."
        Write-Verbose "$(Get-Date)   This might take a few minutes. Don't close this window."

        #Okay, so all JRE runtimes (series 4-7) use product GUIDs, with certain numbers that increment with each new update (e.g. Update 25)
        #This makes it easy to catch ALL of them through liberal use of WMI wildcards ("_" is single character, "%" is any number of characters)
        #Additionally, JRE 6 introduced 64-bit runtimes, so in addition to the two-digit Update XX revision number, we also check ForEach-Object the architecture 
        #type, which always equals '32' or '64'. The first wildcard is the architecture, the second is the revision/update number.

        #JRE 7
        Write-Output "$(Get-Date)   JRE 7..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   JRE 7..."
        $t = (Get-WmiObject win32_product -filter "IdentifyingNumber like '{26A24AE4-039D-4CA4-87B4-2F8__170__FF}'"); $t.Uninstall() | Out-File -FilePath $Log -Append

        #JRE 6
        Write-Output "$(Get-Date)   JRE 6..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   JRE 6..."
        #1st line is ForEach-Object updates 23-xx, after 64-bit runtimes were introduced.
        #2nd line is ForEach-Object updates 1-22, beForEach-Objecte Oracle released 64-bit JRE 6 runtimes
        $t = (Get-WmiObject win32_product -filter "IdentifyingNumber like '{26A24AE4-039D-4CA4-87B4-2F8__160__FF}'"); $t.Uninstall() | Out-File -FilePath $Log -Append
        $t = (Get-WmiObject win32_product -filter "IdentifyingNumber like '{3248F0A8-6813-11D6-A77B-00B0D0160__0}'"); $t.Uninstall() | Out-File -FilePath $Log -Append

        #JRE 5
        Write-Output "$(Get-Date)   JRE 5..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   JRE 5..."
        $t = (Get-WmiObject win32_product -filter "IdentifyingNumber like '{3248F0A8-6813-11D6-A77B-00B0D0150__0}'"); $t.Uninstall() | Out-File -FilePath $Log -Append

        #JRE 4
        Write-Output "$(Get-Date)   JRE 4..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   JRE 4..."
        $t = (Get-WmiObject win32_product -filter "IdentifyingNumber like '{7148F0A8-6813-11D6-A77B-00B0D0142__0}'"); $t.Uninstall() | Out-File -FilePath $Log -Append

        #JRE 3 (AKA "Java 2 Runtime Environment Standard Edition" v1.3.1_00-25)
        Write-Output "$(Get-Date)   JRE 3 (AKA Java 2 Runtime v1.3.xx)..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   JRE 3 (AKA Java 2 Runtime v1.3.xx)..."
        #This version is so old we have to resort to different methods of removing it
        #Loop through each sub-version
        "01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25".Split(",") | ForEach-Object {
	        Start-Proc "$env:SystemRoot\IsUninst.exe" "-f'$env:ProgramFiles\JavaSoft\JRE\1.3.1_$_\Uninst.isu' -a"
	        Start-Proc "$env:SystemRoot\IsUninst.exe" "-f'${env:ProgramFiles(x86)}\JavaSoft\JRE\1.3.1_$_\Uninst.isu' -a"
        }
        #This one wouldn't fit in the loop above
        Start-Proc "$env:SystemRoot\IsUninst.exe" "-f'$env:ProgramFiles\JavaSoft\JRE\1.3\Uninst.isu' -a"
        Start-Proc "$env:SystemRoot\IsUninst.exe" "-f'${env:ProgramFiles(x86)}\JavaSoft\JRE\1.3\Uninst.isu' -a"

        #Wildcard uninstallers
        Write-Output "$(Get-Date)   Specific targeting done. Now running WMIC wildcard catchall uninstallation..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Specific targeting done. Now running WMIC wildcard catchall uninstallation..."
        $t = (Get-WmiObject win32_product -filter "name like '%%J2SE Runtime%%'"); $t.Uninstall() | Out-File -FilePath $Log -Append
        $t = (Get-WmiObject win32_product -filter "name like 'Java%%Runtime%%'"); $t.Uninstall() | Out-File -FilePath $Log -Append
        $t = (Get-WmiObject win32_product -filter "name like 'JavaFX%%'"); $t.Uninstall() | Out-File -FilePath $Log -Append
        Write-Output "$(Get-Date)   Done." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Done."


        #######:
        #REGISTRY CLEANUP #-- This is where it gets hairy. Don't read ahead if you have a weak constitution.
        #######:
        # If not XP then Clean the Registry
        if ($isXP=$false) {

	        

            Write-Output "$(Get-Date)   Commencing registry cleanup..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Commencing registry cleanup..."
            Write-Output "$(Get-Date)   Searching ForEach-Object residual registry keys..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Searching ForEach-Object residual registry keys..."

            #Search MSIExec installer class hive ForEach-Object keys
            Write-Output "$(Get-Date)   Looking in HKLM\software\classes\installer\products..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Looking in HKLM\software\classes\installer\products..."
            reg query HKLM\software\classes\installer\products /f "J2SE Runtime" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\software\classes\installer\products /f "Java(TM) 6 Update" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\software\classes\installer\products /f "Java 7" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\software\classes\installer\products /f "Java*Runtime" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt

            #Search the Add/Remove programs list (this helps with broken Java installations)
            Write-Output "$(Get-Date)   Looking in HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Looking in HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall..."
            reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /f "J2SE Runtime" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /f "Java(TM) 6 Update" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /f "Java 7" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /f "Java*Runtime" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt

            #Search the Add/Remove programs list, x86/Wow64 node (this helps with broken Java installations)
            Write-Output "$(Get-Date)   Looking in HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Looking in HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall..."
            reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /f "J2SE Runtime" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /f "Java(TM) 6 Update" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /f "Java 7" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt
            reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall /f "Java*Runtime" /s | find "HKEY_LOCAL_MACHINE" >> $env:TEMP\java_purge_registry_keys.txt

            #List the leftover registry keys
            Write-Output "$(Get-Date)   Found these keys..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Found these keys..."
            Write-Output "" | Out-File -FilePath $Log -Append
            Write-Verbose ""
            Get-Content "$env:TEMP\java_purge_registry_keys.txt" | Out-File -FilePath $Log -Append
            Write-Verbose (Get-Content "$env:TEMP\java_purge_registry_keys.txt").ToString()
            Write-Output "" | Out-File -FilePath $Log -Append

            #Backup the various registry keys that will get deleted (if they exist)
            #We do this mainly because we're using wildcards, so we want a method to roll back if we accidentally nuke the wrong thing
            Write-Output "$(Get-Date)   Backing up keys..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Backing up keys..."
            if("$env:TEMP\java_purge_registry_backup"){ Remove-Item -force "$env:TEMP\java_purge_registry_backup"}
            mkdir "$env:TEMP\java_purge_registry_backup"
            #This line walks through the file we generated and dumps each key to a file
            ForEach-Object("$env:TEMP\java_purge_registry_keys.txt".Split('["\n\r"|"\r\n"|\n|\r]')) {(reg query $_) >> $env:TEMP\java_purge_registry_backup\java_reg_keys_1.bak}

            Write-Output "$(Get-Date)   Keys backed up to $env:TEMP\java_purge_registry_backup\ " | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Keys backed up to $env:TEMP\java_purge_registry_backup\"
            Write-Output "$(Get-Date)   This directory will be deleted at next reboot, so get it now if you need it! " | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   This directory will be deleted at next reboot, so get it now if you need it!"

            #Purge the keys
            Write-Output "$(Get-Date)   Purging keys..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Purging keys..."

            #This line walks through the file we generated and deletes each key listed
            ForEach-Object("$env:TEMP\java_purge_registry_keys.txt".Split('["\n\r"|"\r\n"|\n|\r]')){reg delete $_ /va /f  | Out-File -FilePath $Log -Append}

            #These lines delete some specific Java locations
            #These keys AREN'T backed up because these are specific, known Java keys, whereas above we were nuking
            #keys based on wildcards, so those need backups in case we nuke something we didn't want to.

            #Delete keys ForEach-Object 32-bit Java installations on a 64-bit copy of Windows
            reg delete "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Auto Update" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Plug-in" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Update" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Web Start" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\Wow6432Node\JreMetrics" /va /f | Out-File -FilePath $Log -Append

            #Delete keys ForEach-Object ForEach-Object 32-bit and 64-bit Java installations on matching Windows architecture
            reg delete "HKLM\SOFTWARE\JavaSoft\Auto Update" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\JavaSoft\Java Plug-in" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\JavaSoft\Java Runtime Environment" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\JavaSoft\Java Update" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\JavaSoft\Java Web Start" /va /f | Out-File -FilePath $Log -Append
            reg delete "HKLM\SOFTWARE\JreMetrics" /va /f | Out-File -FilePath $Log -Append

            Write-Output "$(Get-Date)   Keys purged." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Keys purged."
            Write-Output "$(Get-Date)   Registry cleanup done." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date)   Registry cleanup done."

        }else{
            # We are XP so te above was skipped
            Write-Output "$(Get-Date) ! Registry cleanup doesn't work on Windows XP. Skipping..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date) ! Registry cleanup doesn't work on Windows XP. Skipping..."
        }
        ##########::
        #FILE AND DIRECTORY CLEANUP ::
        ##########::
        #:file_cleanup ---------------------------------
        Write-Output "$(Get-Date)   Commencing file and directory cleanup..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Commencing file and directory cleanup..."

        #Kill accursed Java tasks in Task Scheduler
        Write-Output "$(Get-Date)   Removing Java tasks from the Windows Task Scheduler..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Removing Java tasks from the Windows Task Scheduler..."
        if("$env:windir\tasks\Java*.job"){ Remove-Item -Force $env:windir\tasks\Java*.job | Out-File -FilePath $Log -Append}
        if("$env:windir\System32\tasks\Java*.job"){Remove-Item -Force $env:windir\System32\tasks\Java*.job | Out-File -FilePath $Log -Append}
        if("$env:windir\SysWOW64\tasks\Java*.job"){Remove-Item -Force $env:windir\SysWOW64\tasks\Java*.job | Out-File -FilePath $Log -Append}

        #Kill the accursed Java Quickstarter service
        sc query JavaQuickStarterService >NUL
        if( -not ($? -eq 1060)){
	        Write-Output "$(Get-Date)   De-registering and removing Java Quickstarter service..." | Out-File -FilePath $Log -Append
	        Write-Verbose "$(Get-Date)   De-registering and removing Java Quickstarter service..."
	        net stop JavaQuickStarterService | Out-File -FilePath $Log -Append
	        sc delete JavaQuickStarterService | Out-File -FilePath $Log -Append
        }

        #Kill the accursed Java Update Scheduler service
        sc query jusched >NUL
        if( -not ($? -eq 1060)) {
	        Write-Output "$(Get-Date)   De-registering and removing Java Update Scheduler service..." | Out-File -FilePath $Log -Append
	        Write-Verbose "$(Get-Date)   De-registering and removing Java Update Scheduler service..."
	        net stop jusched | Out-File -FilePath $Log -Append
	        sc delete jusched | Out-File -FilePath $Log -Append
        }

        #This is the Oracle method of disabling the Java services. 99% of the time these commands aren't required. 
        if("${env:ProgramFiles(x86)}\Java\jre6\bin\jqs.exe"){ Start-Proc "${env:ProgramFiles(x86)}\Java\jre6\bin\jqs.exe" "-disable" | Out-File -FilePath $Log -Append}
        if("${env:ProgramFiles(x86)}\Java\jre7\bin\jqs.exe"){ Start-Proc "${env:ProgramFiles(x86)}\Java\jre7\bin\jqs.exe" "-disable" | Out-File -FilePath $Log -Append}
        if("$env:ProgramFiles\Java\jre6\bin\jqs.exe"){ Start-Proc "$env:ProgramFiles\Java\jre6\bin\jqs.exe" "-disable" | Out-File -FilePath $Log -Append}
        if("$env:ProgramFiles\Java\jre7\bin\jqs.exe"){ Start-Proc "$env:ProgramFiles\Java\jre7\bin\jqs.exe" "-disable" | Out-File -FilePath $Log -Append}
        if("${env:ProgramFiles(x86)}\Java\jre6\bin\jqs.exe"){ Start-Proc "${env:ProgramFiles(x86)}\Java\jre6\bin\jqs.exe" "-unregister" | Out-File -FilePath $Log -Append}
        if("${env:ProgramFiles(x86)}\Java\jre7\bin\jqs.exe"){ Start-Proc "${env:ProgramFiles(x86)}\Java\jre7\bin\jqs.exe" "-unregister" | Out-File -FilePath $Log -Append}
        if("$env:ProgramFiles\Java\jre6\bin\jqs.exe"){ Start-Proc "$env:ProgramFiles\Java\jre6\bin\jqs.exe" "-unregister" | Out-File -FilePath $Log -Append}
        if("$env:ProgramFiles\Java\jre7\bin\jqs.exe"){ Start-Proc "$env:ProgramFiles\Java\jre7\bin\jqs.exe" "-unregister" | Out-File -FilePath $Log -Append}
        Start-Proc "msiexec.exe" "/x {4A03706F-666A-4037-7777-5F2748764D10} /qn /norestart"

        #Nuke 32-bit Java installation directories
        Write-Output "$(Get-Date)   Removing "${env:ProgramFiles(x86)}\Java\jre*" directories..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Removing "${env:ProgramFiles(x86)}\Java\jre*" directories..."
	    ForEach-Object(Get-ChildItem -Filter { -like "j2re" -or -like "jre" } "${env:ProgramFiles(x86)}\Java\"){if($_){Remove-Item -Force "$_" | Out-File -FilePath $Log -Append}}
	    if("${env:ProgramFiles(x86)}\JavaSoft\JRE"){ Remove-Item -force "${env:ProgramFiles(x86)}\JavaSoft\JRE" | Out-File -FilePath $Log -Append}

        #Nuke 64-bit Java installation directories
        Write-Output "$(Get-Date)   Removing "$env:ProgramFiles\Java\jre*" directories..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Removing "$env:ProgramFiles\Java\jre*" directories..."
        ForEach-Object(Get-ChildItem -Filter { -like "j2re" -or -like "jre" } "$env:ProgramFiles\Java\"){if($_){Remove-Item -Force "$_" | Out-File -FilePath $Log -Append}}
        if("$env:ProgramFiles\JavaSoft\JRE"){ Remove-Item -force "$env:ProgramFiles\JavaSoft\JRE" | Out-File -FilePath $Log -Append}

        #Nuke Java installer cache ( thanks to cannibalkitteh )
        Write-Output "$(Get-Date)   Purging Java installer cache..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Purging Java installer cache..."
        #XP VERSION
        if ($isXP=$true) {
            #Get list of users, put it in a file, then use it to iterate through each users profile, deleting the AU folder
            dir "$env:SystemDrive\Documents and Settings\" /B > $env:TEMP\userlist.txt
            ForEach-Object(Get-Content "$env:TEMP\userlist.txt"){
		        if("$env:SystemDrive\Documents and Settings\$_\AppData\LocalLow\Sun\Java\AU"){Remove-Item -force "$env:SystemDrive\Documents and Settings\$_\AppData\LocalLow\Sun\Java\AU"}
	        }
            ForEach-Object( "$env:SystemDrive\Documents and Settings\" $_ in (jre*) do if exist "$_" {Remove-Item -force "$_"}
        } else {
	        #ALL OTHER VERSIONS OF WINDOWS
            #Get list of users, put it in a file, then use it to iterate through each users profile, deleting the AU folder
            dir $env:SystemDrive\Users /B > $env:TEMP\userlist.txt
            ForEach-Object(Get-Content "$env:TEMP\userlist.txt") { Remove-Item -force "$env:SystemDrive\Users\$_\AppData\LocalLow\Sun\Java\AU"}
            #Get the other JRE directories
            ForEach-Object( Get-ChildItem -Filter { -like "jre"} "$env:SystemDrive\Users"){Remove-Item -force $_}
        }

        #Miscellaneous stuff, sometimes left over by the installers
        Write-Output "$(Get-Date)   Searching ForEach-Object and purging other Java Runtime-related directories..." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   Searching ForEach-Object and purging other Java Runtime-related directories..."
        del /F /Q "$env:SystemDrive\1033.mst " | Out-File -FilePath $Log -Append
        del /F /S /Q "$env:SystemDrive\J2SE Runtime Environment*" | Out-File -FilePath $Log -Append
        Write-Output ""

        Write-Output "$(Get-Date)   File and directory cleanup done." | Out-File -FilePath $Log -Append
        Write-Verbose "$(Get-Date)   File and directory cleanup done."


        ########:
        #JAVA REINSTALLATION #-- If we wanted to reinstall the JRE after cleanup, this is where it happens
        ########:
        #x64
        if($Reinstall=$true) {
            Write-Output "$(Get-Date) ! Variable REINSTALL_JAVA_x64 was set to 'yes'. Now installing %JAVA_BINARY_x64%..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date) ! Variable REINSTALL_JAVA_x64 was set to 'yes'. Now installing %JAVA_BINARY_x64%..."
            "%JAVA_LOCATION_x64%\%JAVA_BINARY_x64%" %JAVA_ARGUMENTS_x64%
            java -version
            Write-Output "Done." | Out-File -FilePath $Log -Append
            }

        #x86
        if($Reinstall=$true) {
            Write-Output "$(Get-Date) ! Variable REINSTALL_JAVA_x86 was set to 'yes'. Now installing %JAVA_BINARY_x86%..." | Out-File -FilePath $Log -Append
            Write-Verbose "$(Get-Date) ! Variable REINSTALL_JAVA_x86 was set to 'yes'. Now installing %JAVA_BINARY_x86%..."
            "%JAVA_LOCATION_x86%\%JAVA_BINARY_x86%" %JAVA_ARGUMENTS_x86%
            java -version
            Write-Output "Done." | Out-File -FilePath $Log -Append
            }

        #Done.
        Write-Output "$(Get-Date)   Registry hive backups: $env:TEMP\java_purge_registry_backup\" | Out-File -FilePath $Log -Append
        Write-Output "$(Get-Date)   Registry hive backups: $env:TEMP\java_purge_registry_backup\"
        Write-Output "$(Get-Date)   Log file: $Log" | Out-File -FilePath $Log -Append
        Write-Output "$(Get-Date)   Log file: $Log"
        Write-Output "$(Get-Date)   JAVA NUKER COMPLETE. Recommend rebooting and washing your hands." | Out-File -FilePath $Log -Append
        Write-Output "$(Get-Date)   JAVA NUKER COMPLETE. Recommend rebooting and washing your hands."

        #Return exit code to SCCM/PDQ Deploy/PSexec/etc
        exit %EXIT_CODE%

        
    }
    Process
    {
    }
    End
    {
    }
}

function Start-Proc{
Param
    (
        # Program
        [Parameter(Mandatory=$true)]
        [string]$program,
        # Args
        [Parameter(Mandatory=$true)]
        [string]$args
    )
    $proc = [System.Diagnostics.Process]::Start($program,$args).WaitForExit()
    return $proc
}
