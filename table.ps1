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

# Duplicate the 4th column and name it "five"
$sheetDataLower | ForEach-Object {
    $_.PSObject.Properties.Add([psnoteproperty]::new('five', $_.PSObject.Properties[3].Value))
    $_
} | Select-Object *, five

# Display the modified sheet in the console
$sheetDataLower | Format-Table -AutoSize

# Define the path to the output CSV file
$outputFilePath = "output.csv"

# Save the modified sheet to a CSV file
$sheetDataLower | Export-Csv -Path $outputFilePath -NoTypeInformation
