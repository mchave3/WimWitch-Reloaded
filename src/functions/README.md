# Function Organization

```mermaid
graph TB
    subgraph Public["📂 Public"]
        Start["Start-WimWitch"]
    end

    subgraph Private["📂 Private"]
        direction TB
        
        subgraph UI["🖥️ UI Functions"]
            GetForm["Get-FormVariables"]
            SelectConfig["Select-Config"] 
            SelectNewJSONDir["Select-NewJSONDir"]
        end

        subgraph Core["🔧 Core Functions"]
            direction LR
            UpdateLog["Update-Log"]
            SaveConfig["Save-Configuration"]
            GetConfig["Get-Configuration"]
            ImportWimInfo["Import-WimInfo"]
            RemoveAppx["Remove-Appx"]
            RemoveOSIndex["Remove-OSIndex"]
        end

        subgraph Image["📀 Image Management"]
            direction LR
            InstallStartLayout["Install-StartLayout"]
            SelectImportPath["Select-ImportOtherPath"]
            ImportFOD["Import-FeatureOnDemand"]
        end

        subgraph ConfigMgr["⚙️ ConfigMgr Integration"]
            SelectDPs["Select-DistributionPoints"]
            GetImageInfo["Get-ImageInfo"]
        end

        subgraph System["🛠️ System Functions"]
            CheckArch["Invoke-ArchitectureCheck"]
            UpdateAutopilot["Update-Autopilot"]
        end
    end

    Start --> GetForm
    GetForm --> UpdateLog
    SelectConfig --> GetConfig
    GetConfig --> ImportWimInfo
    ImportWimInfo --> UpdateLog
    RemoveAppx --> UpdateLog
    InstallStartLayout --> UpdateLog
    SelectDPs --> UpdateLog
    
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef folder fill:#e3f2fd,stroke:#1565c0,stroke-width:2px;
    classDef public fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    
    class Public,Private folder;
    class Start public;
    class UI,Core,Image,ConfigMgr,System folder;