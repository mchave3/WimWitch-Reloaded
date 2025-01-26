# WimWitch-Reloaded 🧙‍♂️

<div align="center">

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/WimWitch-Reloaded?style=flat-square&label=Release)](https://www.powershellgallery.com/packages/WimWitch-Reloaded)
[![PowerShell Gallery Pre-Release Version](https://img.shields.io/powershellgallery/v/WimWitch-Reloaded?style=flat-square&label=Pre-release&include_prereleases)](https://www.powershellgallery.com/packages/WimWitch-Reloaded)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/WimWitch-Reloaded?style=flat-square)](https://www.powershellgallery.com/packages/WimWitch-Reloaded)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

</div>

> A modern PowerShell-based Windows image customization tool, born from the ashes of the original WIM-Witch project.

<!--
<div align="center">
    <img src="docs/assets/logo.png" alt="WimWitch-Reloaded Logo" width="200"/>
</div>
-->

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
- [Version](#-version)

## 📋 Overview

WimWitch-Reloaded is a maintained and enhanced fork of [TheNotoriousDRR's WIM-Witch](https://github.com/thenotoriousdrr/WIM-Witch) (now EOL). This project aims to continue the legacy while adding modern features and ensuring compatibility with the latest Windows versions.

## ✨ Features

<div align="center">
  <table>
    <tr>
      <td align="center">🖥️<br><b>Image Management</b></td>
      <td align="center">📦<br><b>AppX Handling</b></td>
      <td align="center">🌍<br><b>Language Support</b></td>
    </tr>
    <tr>
      <td>Windows image customization<br>Win10/11 support</td>
      <td>Package management<br>Removal & Installation</td>
      <td>Language pack integration<br>Regional settings</td>
    </tr>
  </table>
</div>

## 🔧 Requirements

- PowerShell 5.1 or higher
- Windows operating system
- Administrative privileges

## 📥 Installation

### Stable Release
```powershell
Install-Module -Name WimWitch-Reloaded
```

### Pre-Release Version
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

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

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