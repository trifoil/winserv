# Install the ImportExcel module if not already installed
Install-Module -Name ImportExcel -Scope CurrentUser -Force

# Import the ImportExcel module
Import-Module ImportExcel

# Define the path to the input Excel file
$inputFilePath = "Employes.xlsx"

# Read the "Liste3" sheet from the Excel file
$sheetData = Import-Excel -Path $inputFilePath -WorksheetName "Liste3"

# Function to remove diacritics
function Remove-Diacritics {
    param (
        [string]$inputString
    )
    $normalizedString = $inputString.Normalize( [System.Text.NormalizationForm]::FormD )
    $stringBuilder = New-Object System.Text.StringBuilder
    $normalizedString.ToCharArray() | ForEach-Object {
        if ( [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark ) {
            $null = $stringBuilder.Append($_)
        }
    }
    return $stringBuilder.ToString().Normalize( [System.Text.NormalizationForm]::FormC )
}

# Convert all letters to lowercase and remove diacritics
$sheetDataLower = $sheetData | ForEach-Object {
    $_.PSObject.Properties | ForEach-Object {
        $_.Value = (Remove-Diacritics -inputString $_.Value.ToString()).ToLower()
    }
    $_
}

# Add a new column named "test" between the 4th and 5th columns
$sheetDataLower = $sheetDataLower | ForEach-Object {
    $row = $_
    $newRow = New-Object PSObject
    for ($i = 0; $i -lt $row.PSObject.Properties.Count; $i++) {
        if ($i -eq 3) {
            $newRow | Add-Member -MemberType NoteProperty -Name "test" -Value ""
        }
        $newRow | Add-Member -MemberType NoteProperty -Name $row.PSObject.Properties[$i].Name -Value $row.PSObject.Properties[$i].Value
    }
    $newRow
}

# Display the modified sheet in the console
$sheetDataLower | Format-Table -AutoSize

# Define the path to the output CSV file
$outputFilePath = "output.csv"

# Save the modified sheet to a CSV file
$sheetDataLower | Export-Csv -Path $outputFilePath -NoTypeInformation
