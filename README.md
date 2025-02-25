# WimWitch-Reloaded 🧙‍♂️

<div align="center">

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/WimWitch-Reloaded?style=flat-square&label=Release&color=blue)](https://www.powershellgallery.com/packages/WimWitch-Reloaded)
[![GitHub Pre-Release](https://img.shields.io/github/v/release/mchave3/WimWitch-Reloaded?include_prereleases&style=flat-square&label=Pre-Release&color=orange)](https://github.com/mchave3/WimWitch-Reloaded/releases)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/WimWitch-Reloaded?style=flat-square&color=green&label=Downloads)](https://www.powershellgallery.com/packages/WimWitch-Reloaded)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mchave3/WimWitch-Reloaded/Nightly-Run.yml?style=flat-square&label=Build)](https://github.com/mchave3/WimWitch-Reloaded/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](LICENSE)

</div>

> A modern PowerShell-based Windows image customization and deployment tool, focusing on Windows 10/11 and Server customization with an intuitive GUI.

## 📑 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Usage](#-usage)
- [Building from Source](#️-building-from-source)
- [Testing](#-testing)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)

## 📋 Overview

WimWitch-Reloaded is a maintained and enhanced fork of [TheNotoriousDRR's WIM-Witch](https://github.com/thenotoriousdrr/WIM-Witch) (now EOL). This project aims to continue the legacy while adding modern features and ensuring compatibility with the latest Windows versions.

## ✨ Key Features

- **Windows Image Management**: Full support for Windows 10/11 and Server editions
- **Update Integration**: Seamless Windows updates and .NET Framework integration  
- **Driver Management**: Intelligent driver injection for multiple sources
- **Customization Options**:
  - AppX package management
  - Language pack integration
  - Registry modifications
  - Custom scripts execution
- **MEMConfigMgr Integration**: Enhanced ConfigMgr package creation and distribution
- **ISO Creation**: Create bootable ISO files with custom configurations
- **AutoPilot Support**: Automated deployment profile integration
- **Logging**: Detailed logging and error reporting

## 🔧 Requirements

- PowerShell 5.1 or higher
- Windows operating system
- Administrative privileges

## 📥 Installation

### Stable Release
```powershell
Install-Module -Name WimWitch-Reloaded
```

### Prerelease Version
```powershell
Install-Module -Name WimWitch-Reloaded -AllowPrerelease
```

## 🚀 Usage

```powershell
Import-Module WimWitch-Reloaded
Start-WimWitch
```

## 🎯 Quick Start

<div align="center">

```mermaid
%%{init: { 'sequence': {'showSequenceNumbers': false}, 'theme':'default', 'flowchart': {'htmlLabels': true}, 'themeCSS': '.node rect { cursor: default !important; }' } }%%
graph LR
    A["💿 Install<br><i>Module</i>"]:::step --> B["📥 Import<br><i>Module</i>"]:::step
    B --> C["🧙‍♂️ Start<br><i>WimWitch</i>"]:::step
    C --> D["✨ Customize<br><i>Image</i>"]:::final
    
    classDef step fill:#f8f9fa,stroke:#4a5568,stroke-width:2px,color:#2d3748,rx:8,ry:8
    classDef final fill:#ebf8ff,stroke:#3182ce,stroke-width:2px,color:#2c5282,rx:8,ry:8
    linkStyle default stroke:#4a5568,stroke-width:2px,stroke-dasharray: 5 5
```

</div>

## 🛠️ Building from Source

To build the module:

```powershell
.\WimWitch-Reloaded.build.ps1
```

## 🧪 Testing

The project includes Pester tests and uses PSScriptAnalyzer for code quality checks. GitHub Actions workflows are set up for:
- PSScriptAnalyzer checks
- DevSkim security scanning

## 👥 Contributing

We welcome contributions! Please follow these steps:

1. Review our [Code of Conduct](.github/CODE_OF_CONDUCT.md) and [Contributing Guidelines](.github/CONTRIBUTING.md)
2. Open an issue or claim an existing one
3. Fork the repository
4. Create a branch from `main`
5. Write tests for your changes
6. Implement your changes
7. Open a draft pull request:
   - Use the PR template
   - Link the related issue
   - Review your own changes
8. Mark as "Ready for review" when complete
9. Address any review feedback

For detailed guidance, see our [Contributing Guide](.github/CONTRIBUTING.md).

Need help getting started? Check out:
- [Setting up Git](https://docs.github.com/get-started/quickstart/set-up-git)
- [GitHub Flow](https://docs.github.com/get-started/quickstart/github-flow)
- [Working with Pull Requests](https://docs.github.com/github/collaborating-with-pull-requests)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

Mickaël CHAVE

### Original Project Credits
- Based on WIM-Witch by TheNotoriousDRR ([Original Repository](https://github.com/thenotoriousdrr/WIM-Witch))
- Inspired by Alex Laurie's fork ([WimWitchFK](https://github.com/alaurie/WimWitchFK))

---

<div align="center">

**WimWitch-Reloaded** - _Keeping the magic alive_ ✨
</div>
