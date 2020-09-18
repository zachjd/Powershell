$formADGroupMemberTransfer_Load={
}

$buttonApply_Click = {	
	$buttonApply.Text = "Processing"
	$buttonApply.Enabled = $false
	try
	{
		Get-ADGroupMember ($global:x = $textboxGroupAD.Text) |
		Add-ADPrincipalGroupMembership ` -MemberOf ($global:x = $textboxNewGroupAD.Text)
		$a = new-object -comobject wscript.shell
		$intAnswer = $a.popup("Members of $($textboxGroupAD.Text) have been copied to $($textboxNewGroupAD.Text) successfully. 
			Do you want to remove the members from $($textboxGroupAD.Text)?", `
			0, "Success", 4)
		If ($intAnswer -eq 6)
		{
			Get-ADGroupMember ($global:x = $textboxGroupAD.Text) |
			Remove-ADPrincipalGroupMembership ` -MemberOf ($global:x = $textboxGroupAD.Text)
		}
		Else{}
	}
	
	Catch
	{
		[System.Windows.Forms.MessageBox]::Show("One or more groups were not found. Please try again.", "Error", 
		[System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
	}
	
	Finally
	{
		$buttonApply.Text = "Apply"
		$buttonApply.Enabled = $true
	}	
	
}
