#Documentation: https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Cmdlets/Invoke-ScriptAnalyzer.md#-settings
@{
    Severity = @('Error','Warning')
    ExcludeRules = @(
        'PSMissingModuleManifestField',
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingInvokeExpression'
    )
}