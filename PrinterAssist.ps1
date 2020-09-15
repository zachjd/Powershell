$formWSD3PrinterAssist_Load = {
	#Find only copiers for combobox selection
	Function Get-Copier
	{
		Get-Printer | foreach { $_.Name } |
		Where-Object {
			$_ -Match "CPY" }
	}
		$copiers = Get-Copier
		
		ForEach ($name in $copiers)
		{
			$comboboxCopier.Items.Add($name)
		}
	
	#Find all printers to run a test page
	Function Get-TestPageList
	{
		Get-Printer | foreach { $_.Name } |
		Where-Object {
			$_ -Match "CPY" -or $_ -Match "PRN"
		}
	}
	$tplist = get-testpagelist
		
		ForEach ($tp in $tplist)
		{
			$comboboxTestPrint.Items.Add($tp)
		}
}

#Runs Group Policy Update
$btnUpdate_Click = {
	$btnUpdate.Enabled = $false
	
	$btnUpdate.text = "Please wait.."
		
	$printerOutputbox.lines = "Updating group policy..."
	
	gpupdate /force
	
	$printerOutputbox.lines = ""
	
	$this.Enabled = $true
	
	$btnUpdate.text = "Update"
	
	$a = new-object -comobject wscript.shell	
	$intAnswer = $a.popup("A restart is needed for completion, do you want to continue?", `
		0, "Restart Computer", 4)
	If ($intAnswer -eq 6)
	{
		restart-computer
	}
	Else
	{
		
	}
}

#Search Printers
$buttonMyPrinters_Click = {
	$buttonMyPrinters.Enabled = $false
	
	$buttonMyPrinters.Text = "Loading.."
	
	function get-printers
	{
		Get-Printer | Select-Object Name, Location, PrinterStatus |
		Where-Object {
			$_ -NotMatch "Microsoft Print to PDF" -and $_ -NotMatch "Fax" -and
			$_ -NotMatch "Adobe PDF" -and $_ -NotMatch "Microsoft XPS Document Writer" -and
			$_ -NotMatch "Send to OneNote 16" -and $_ -NotMatch "OneNote for Windows 10"
		} |
		ForEach-Object {
			"Printer Name: $($_.Name -replace "(wsd-prn01)", $blank -replace "(\\)", $blank -replace "(whs-fsps)",
				$blank -replace "(sjh-fsps)", $blank -replace "(mhs-fsps)", $blank -replace "(jjh-fsps)", $blank -replace "(whs12a)",
				$blank -replace "(wjh-fsps)", $blank)" + "`r`n" + "Location: $($_.Location)" + "`r`n" + "Status: $($_.PrinterStatus)" + "`r`n"
		}
	}
	
	$printerOutputbox.lines = get-printers
	
	$buttonMyPrinters.Enabled = $true
	
	$buttonMyPrinters.Text = "My Printers"
}

#Enable print code button upon selection
$comboboxCopier_SelectedIndexChanged = {
	$printcodeButton.Enabled = $true
}

#Enable test print button upon selection
$comboboxTestPrint_SelectedIndexChanged = {
	$testprintButton.Enabled = $true
}

#Open preferences
$printcodeButton_Click = {
	$copiername = $comboboxCopier.SelectedItem
	
	[System.Windows.Forms.MessageBox]::Show("To enter your printer code, click the 'JOB HANDLING' tab then enter your 'USER NUMBER' and click 'APPLY'", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Asterisk)
	
	cmd.exe /c RUNDLL32 PRINTUI.DLL, PrintUIEntry /e /n $copiername
}

#Double click to copy text
$printerOutputbox_DoubleClick = {
	$printerOutputbox.SelectAll()
	
	Set-Clipboard -Value $printerOutputbox.text
	
	[System.Windows.Forms.MessageBox]::Show("Copied to clipboard.", "Copied", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Asterisk)
	
	$printerOutputbox.DeselectAll()
}

#Ability to right click
$copyToolStripMenuItem_Click = {
	Set-Clipboard -Value $printerOutputbox.text
}

#Prints a test page for selected printer
$testprintButton_Click = {
	$testprints = $comboboxTestPrint.SelectedItem
	cmd.exe /c RUNDLL32 PRINTUI.DLL, PrintUIEntry /e /n $testprints /k
	
}
