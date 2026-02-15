# Import required modules
Import-Module ActiveDirectory

$DomainDN = "DC=bocorp,DC=local"

# ===============================
# OU Structure Definition
# ===============================

$OUStructure = @{
    "_Admin"            = @{
        "Admin-Users"      = @{}
        "Service-Accounts" = @{}
    }
    "Workstations"      = @{}
    "Servers"           = @{}
    "_Groups"           = @{
        "Global"      = @{}
        "DomainLocal" = @{}
    }
    "Departments"       = @{
        "Finance"         = @{}
        "Human Resources" = @{}
        "IT"              = @{
            "ITSecurity" = @{}
            "ITSupport"  = @{}
        }
        "Sales"           = @{}
    }
    "_Disabled-Objects" = @{}
}

# Creates a new OU if it does not already exist
function Create-OU-IfNotExists {
    param (
        [Parameter(Mandatory)]
        [string]$OUName,

        [Parameter(Mandatory)]
        [string]$ParentDN
    )

    # Construct the full Distinguished Name for the OU
    $OUDN = "OU=$OUName,$ParentDN"

    # Check if OU already exists
    $ExistingOU = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUDN'" -ErrorAction SilentlyContinue

    if ($ExistingOU) {
        Write-Host "[INFO] OU '$OUName' already exists." -ForegroundColor Yellow
    }
    else {
        try {
            New-ADOrganizationalUnit `
                -Name $OUName `
                -Path $ParentDN `
                -ProtectedFromAccidentalDeletion $true

            Write-Host "[CREATED] OU '$OUName' created successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] Failed to create OU '$OUName'." -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }
}

# Recursively creates the OU structure based on the provided hashtable
function Create-OUStructure {
    param (
        [hashtable]$Structure,
        [string]$ParentDN
    )

    foreach ($OU in $Structure.Keys) {

        # Create OU if it does not exist
        Create-OU-IfNotExists -OUName $OU -ParentDN $ParentDN

        # Construct the new Parent DN for any child OUs
        $NewParentDN = "OU=$OU,$ParentDN"

        # Recursively create child OUs if they exist
        if ($Structure[$OU].Count -gt 0) {
            Create-OUStructure -Structure $Structure[$OU] -ParentDN $NewParentDN
        }
    }
}

Create-OUStructure -Structure $OUStructure -ParentDN $DomainDN
Write-Host "OU structure creation completed." -ForegroundColor Cyan

# ===============================
# Security Group Creation
# ===============================
$GlobalGroupsOU = "OU=Global,OU=_Groups,$DomainDN"
$DomainLocalGroupsOU = "OU=DomainLocal,OU=_Groups,$DomainDN"

$GlobalGroups = @(
    "GG-Finance-Users",
    "GG-HR-Users",
    "GG-IT-Users",
    "GG-Sales-Users",
    "GG-Finance-Managers",
    "GG-HR-Managers",
    "GG-IT-Managers",
    "GG-Sales-Managers"
    "GG-Helpdesk-PasswordReset",
    "GG-Workstation-Admins"
)

$DomainLocalGroups = @(
    "DL-Share-Finance-RW",
    "DL-Share-HR-RW",
    "DL-Share-IT-RW",
    "DL-Share-Sales-RW",
    "DL-Share-Finance-RO",
    "DL-Share-HR-RO",
    "DL-Share-IT-RO",
    "DL-Share-Sales-RO"
)

function Create-ADGroup-IfNotExists {
    param (
        [Parameter(Mandatory)]
        [string]$GroupName,

        [Parameter(Mandatory)]
        [ValidateSet("Global", "DomainLocal")]
        [string]$Scope,

        [Parameter(Mandatory)]
        [string]$Path
    )

    # Check if group already exists
    $ExistingGroup = Get-ADGroup `
        -Filter "Name -eq '$GroupName'" `
        -ErrorAction SilentlyContinue

    if ($ExistingGroup) {
        Write-Host "[EXISTS] Group $GroupName" -ForegroundColor Yellow
    }
    else {
        try {
            New-ADGroup `
                -Name $GroupName `
                -SamAccountName $GroupName `
                -GroupScope $Scope `
                -GroupCategory Security `
                -Path $Path

            Write-Host "[CREATED] Group $GroupName" -ForegroundColor Green
        }
        catch {
            Write-Host "[ERROR] Failed to create $GroupName" -ForegroundColor Red
            Write-Host $_.Exception.Message
        }
    }
}

# Create Global Groups
foreach ($Group in $GlobalGroups) {
    Create-ADGroup-IfNotExists `
        -GroupName $Group `
        -Scope "Global" `
        -Path $GlobalGroupsOU
}

# Create Domain Local Groups
foreach ($Group in $DomainLocalGroups) {
    Create-ADGroup-IfNotExists `
        -GroupName $Group `
        -Scope "DomainLocal" `
        -Path $DomainLocalGroupsOU
}

# Adds a child group to a parent group if not already a member
function Ensure-GroupMembership {
    param (
        [Parameter(Mandatory)]
        [string]$ParentGroup,

        [Parameter(Mandatory)]
        [string]$ChildGroup
    )

    $IsMember = Get-ADGroupMember -Identity $ParentGroup -Recursive |
    Where-Object { $_.Name -eq $ChildGroup }

    if (-not $IsMember) {
        Add-ADGroupMember -Identity $ParentGroup -Members $ChildGroup
        Write-Host "[NESTED] $ChildGroup -> $ParentGroup" -ForegroundColor Green
    }
    else {
        Write-Host "[EXISTS]  $ChildGroup already in $ParentGroup" -ForegroundColor Yellow
    }
}

foreach ($Group in $GlobalGroups) {
    if ($Group -match "^GG-(.+)-Managers$") {
        $Department = $Matches[1]
        $TargetDL = "DL-Share-$Department-RW"

        Ensure-GroupMembership `
            -ParentGroup $TargetDL `
            -ChildGroup $Group
    }
    elseif ($Group -match "^GG-(.+)-Users$") {
        $Department = $Matches[1]
        $TargetDL = "DL-Share-$Department-RO"

        Ensure-GroupMembership `
            -ParentGroup $TargetDL `
            -ChildGroup $Group
    }
}

Write-Host "Security group creation completed." -ForegroundColor Cyan

# ===============================
# User Account Creation
# ===============================

# Function to generate a random password
function New-RandomPassword {
    param (
        [int]$Length = 14
    )

    $Upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
    $Lower = "abcdefghijklmnopqrstuvwxyz".ToCharArray()
    $Numbers = "0123456789".ToCharArray()
    $Special = "!@#$%^&*()-_=+".ToCharArray()

    $AllChars = $Upper + $Lower + $Numbers + $Special

    $Password = @()

    # Ensure password contains at least one character from each category
    $Password += Get-Random -InputObject $Upper   -Count 1
    $Password += Get-Random -InputObject $Lower   -Count 1
    $Password += Get-Random -InputObject $Numbers -Count 1
    $Password += Get-Random -InputObject $Special -Count 1

    for ($i = $Password.Count; $i -lt $Length; $i++) {
        $Password += Get-Random -InputObject $AllChars -Count 1
    }

    $Password = $Password | Sort-Object { Get-Random }

    return -join $Password
}

$InputCSV = "C:\Lab\Csv\bocorp-users.csv"
$OutputCSV = "C:\Lab\Csv\bocorp-users-with-passwords.csv"

$Users = Import-Csv -Path $InputCSV
$CreatedUsers = @()

foreach ($User in $Users) {
    $FirstName = $User.FirstName
    $LastName = $User.LastName
    $Username = ($FirstName + $LastName).ToLower()
    $Department = $User.Department
    $OUPath = $User.DepartmentOUPath
    $Title = $User.Title
    $SamAccountName = $Username

    # Check if user already exists
    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        Write-Host "[EXISTS] User $SamAccountName already exists." -ForegroundColor Yellow
        continue
    }

    $PlainPassword = New-RandomPassword
    $SecurePassword = ConvertTo-SecureString $PlainPassword -AsPlainText -Force

    # Create the user account
    try {
        New-ADUser `
            -SamAccountName $SamAccountName `
            -UserPrincipalName "$SamAccountName@bocorp.local" `
            -Name "$FirstName $LastName" `
            -GivenName $FirstName `
            -Surname $LastName `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Department $Department `
            -Title $Title `
            -City "CABA" `
            -Country "AR" `
            -Path $OUPath `
            -AccountPassword $SecurePassword `
            -Company "Bocorp" `
            -ErrorAction Stop

        Write-Host "[SUCCESS] User $SamAccountName created successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to create user $SamAccountName" -ForegroundColor Red
        Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor DarkRed
        continue
    }


    $GroupDepartment = $Department
    if ($GroupDepartment -eq "Human Resources") {
        $GroupDepartment = "HR"
    }
    if ($Title -match "Manager") {
        $GroupName = "GG-$GroupDepartment-Managers"
    }
    else {
        $GroupName = "GG-$GroupDepartment-Users"
    }

    Add-ADGroupMember -Identity $GroupName -Members $SamAccountName
    Write-Host "[ADDED] $SamAccountName added to $GroupName" -ForegroundColor Cyan

    $CreatedUsers += [PSCustomObject]@{
        FirstName     = $FirstName
        LastName      = $LastName
        Username      = $SamAccountName
        Department    = $Department
        Title         = $Title
        OUPath        = $OUPath
        PlainPassword = $PlainPassword
    }
}

# Export created users with passwords to a new CSV file
$CreatedUsers | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8
Write-Host "User account creation completed. Details exported to $OutputCSV" -ForegroundColor Magenta