param ($ScriptsRoot)
Describe 'Testing against PowerShell Script Analyzer Rules' {
       Context 'PSSA Standard Rules' {

    $Files = Get-ChildItem -Path $ScriptsRoot -Recurse | Where-Object {$_.Extension -eq ".ps1"}
    foreach ($file in $files) {

        $analysis = Invoke-ScriptAnalyzer -Path $file.FullName
        $scriptAnalyzerRules = Get-ScriptAnalyzerRule

        forEach ($rule in $scriptAnalyzerRules) {
            It "File $($File.Name) should pass $rule" {
                If ($analysis.RuleName -contains $rule) {
                    $analysis |
                         Where-Object RuleName -EQ $rule -outvariable failures |
                         Out-Default
                    $failures.Count | Should Be 0
                }
            }
        }
    }
  }
}