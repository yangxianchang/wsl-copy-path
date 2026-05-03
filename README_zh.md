# wsl-copy-path

右键任意文件，或截图后按一个热键——WSL 路径直接进剪贴板。不用再手敲 `/mnt/c/...`。

## 痛点

你在 WSL2 里用 Claude Code 或其他命令行工具，想把文件路径或截图传给终端：

- 拖拽文件到终端 → 粘贴的是 `C:\Users\...`，WSL 无法识别
- 截图/网页复制图片 → 粘贴不出来，终端只接受文本
- 只能每次手动敲 `/mnt/c/Users/xxx/...`

## 干什么

两件事：

- **右键任意文件** → "Copy as WSL Path" — 资源管理器增加右键菜单
- **截图后** → `Ctrl+Alt+P` — 自动找最新截图，复制 WSL 路径到剪贴板

全程不弹终端窗口。

## 安装

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

或者右键 `install.ps1` → **使用 PowerShell 运行**。

无依赖，无需管理员权限。

## 使用

### 复制文件 WSL 路径

1. 在资源管理器中右键任意文件（图片、PDF、文件夹都行）
2. 点击 **"Copy as WSL Path"**
3. 回到 WSL 终端粘贴 → `/mnt/c/Users/you/Documents/report.pdf`

### 复制最新截图路径

1. 截图（`Win+Shift+S` 或 `PrtSc`）
2. 按 **`Ctrl+Alt+P`**
3. 右下角弹出气泡确认
4. 回到 WSL 终端粘贴 → `/mnt/c/Users/you/Pictures/Screenshots/屏幕截图.png`

## 原理

两个功能走同一套流程：

1. VBScript 拿到 Windows 路径（右键菜单传入的文件路径，或扫描 Screenshots 文件夹拿到最新截图路径）
2. 把 `C:\Users\...\file.png` 转成 `/mnt/c/Users/.../file.png`（反斜杠换正斜杠，盘符换成 `/mnt/` 前缀）
3. 管道输给 `clip.exe`（Windows 自带），写入剪贴板

VBScript 通过 `wscript.exe` 运行——这是 Windows 原生执行 `.vbs` 的宿主，不会弹出控制台窗口。

## 卸载

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

## 兼容性

- Windows 10 / 11
- WSL2（任意发行版）
- Windows Terminal、VS Code 集成终端、各种 WSL 终端

## 文件

```
├── install.ps1                       # 添加右键菜单 + 热键快捷方式
├── uninstall.ps1                     # 清理所有安装内容
└── scripts/
    ├── copy-wsl-path.vbs             # 右键菜单处理脚本
    └── copy-latest-screenshot.vbs    # 热键处理脚本
```

## License

MIT
