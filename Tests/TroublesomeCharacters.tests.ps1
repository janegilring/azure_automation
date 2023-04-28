Describe 'Troublesome characters' {
    Context 'Computer says no' {
        BeforeAll {
            $chars =  [char[]](8203, 8211, 8212, 8213)

            $allowedScripts = @(
                'Write-Host First {0} Second'
                'Write-Host "Text {0}"'
                '"Double {0} quoted"'
                "'Single {0} quote'"
                ('@"', 'Here{0}String', '"@' -join "`n")
                "@'`nHere{0}String`n'@"
            )
            $allowedCases = foreach ($char in $chars) {
                foreach ($script in $allowedScripts) {
                    @{ Char = $char; Code = [Int]$Char; Script = $script -f $char }
                }
            }

            $disallowedScripts = @(
                '1 {0} 2'                             # Warn
                'Get-Command Get-Command {0}Syntax'   # Error
                'Get{0}Command'                       # Error
            )
            $disallowedCases = foreach ($char in $chars) {
                foreach ($script in $disallowedScripts) {
                    @{ Char = $char; Code = [Int]$Char; Script = $script -f $char }
                }
            }

            # This will be the body of the rule. May be more efficient as three rules, three different AST types for script analyzer.
            $predicate = {
                param ( $ast )

                $char = $null
                if (($ast -is [System.Management.Automation.Language.BinaryExpressionAst] -and $ast.Operator -eq 'Minus' -and $ast.ErrorPosition.Text.Length -eq 1) -or
                     $ast -is [System.Management.Automation.Language.CommandParameterAst]) {

                    if ($ast.ErrorPosition.Text[0] -in 0x200B, 0x2013, 0x2014, 0x2015) {
                        return $true
                    }
                }
                if ($ast -is [System.Management.Automation.Language.CommandAst] -and
                    $ast.GetCommandName() -match '\u200b|\u2013|\u2014|\u2015') {

                    return $true
                }
            }
        }

        It 'Allows <Char> in a quoted string' -TestCases $allowedCases {
            param (
                [Char]$Char,

                [String]$Script
            )

            $tokens = $errors = @()
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Script, [Ref]$tokens, [Ref]$errors)
            $elements = $ast.FindAll($predicate, $true)

            $elements | Should -BeNullOrEmpty
        }

        It 'Does not allow <Char> outside a quoted string' -TestCases $disallowedCases {
            param (
                [Char]$Char,

                [String]$Script
            )

            $tokens = $errors = @()
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($Script, [Ref]$tokens, [Ref]$errors)
            $elements = $ast.FindAll($predicate, $true)

            $elements | Should -Not -BeNullOrEmpty
            @($elements).Count | Should -Be 1
        }
    }
    
    Context 'Computers say yes, humans will not like' {
        BeforeAll {

        }
    }
}