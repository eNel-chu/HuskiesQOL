# HuskiesQOL - Quality of Life Addon for WoW

**Version 2.0.0** - Complete Rewrite  
A modern, performance-optimized addon with customizable Quality of Life features.

## ✨ Features

### 🎯 Crosshair
- Customizable center screen crosshair
- Multiple styles: Cross, Dot, Circle
- Adjustable size, thickness, and color
- Smart visibility: Hide on mount, in vehicles, during dragonriding
- Combat-only mode available

### 🔵 Mouse Ring
- Smooth circle around your mouse cursor
- Fully customizable radius and appearance
- Combat-only mode with pulse animation
- Performance optimized with cached rendering

### 📊 GCD Tracker
- Shows your last used ability with icon
- Cooldown spiral animation
- Customizable position and size
- Auto-fades after configurable time
- Minimal performance impact

### ⚔️ Combat Notifier
- Customizable messages when entering/leaving combat
- Sound effects support
- Screen flash effect on combat start
- Fully configurable messages

### 🔑 Auto Key Insert *(Coming Soon)*
- Automatically insert Mythic+ keystones
- Configurable key detection

## 📦 Installation

1. Download the addon folder
2. Extract to: `World of Warcraft\_retail_\Interface\AddOns\`
3. The folder should be: `...\AddOns\HuskiesQOL\`
4. Make sure the `Media` folder with `HuskiesLogo.tga` is included
5. Restart WoW or type `/reload` in game

## 🎮 Usage

### Slash Commands
- `/huskies` or `/hqol` - Open settings window
- `/huskies reset` - Reset all settings to default

### Interface Options
- ESC → Interface → AddOns → HuskiesQOL
- Click "Open Settings" button

## ⚙️ Configuration

The settings window features **4 tabs** for different categories:

### Crosshair Tab
- Enable/Disable
- Style selection (Cross, Dot, Circle)
- Size and thickness sliders
- Color picker
- Visibility options (combat, mount, vehicle, dragonriding)

### Mouse Ring Tab
- Enable/Disable
- Radius and thickness adjustment
- Color customization
- Combat-only mode
- Pulse animation toggle

### GCD Tracker Tab
- Enable/Disable
- Icon size adjustment
- Fade time configuration
- Show/hide icon and cooldown spiral

### Combat Tab
- Enable/Disable notifications
- Custom enter/leave combat messages
- Sound effects toggle
- Screen flash effect

## 🔧 File Structure

```
HuskiesQOL/
├── HuskiesQOL.toc          # Addon definition
├── Core.lua                # Main initialization
├── Config.lua              # Default settings
├── Modules/
│   ├── Crosshair.lua       # Crosshair feature
│   ├── MouseRing.lua       # Mouse ring feature
│   ├── GCDTracker.lua      # GCD tracking
│   └── CombatNotifier.lua  # Combat notifications
├── UI/
│   ├── ConfigWindow.lua    # Main settings window
│   ├── ConfigWindow_Tabs.lua # Tab content creators
│   └── SettingsPanel.lua   # Interface options integration
└── Media/
    └── HuskiesLogo.tga     # Addon logo
```

## 🎨 Customization

All settings are stored in `SavedVariables/HuskiesQOL.lua` and can be modified:
- Through the in-game UI (recommended)
- By editing the saved variables file directly (advanced)
- Using `/huskies reset` to restore defaults

## 🚀 Performance

This addon is optimized for **minimal performance impact**:
- Event-driven architecture (no constant OnUpdate spam)
- Smart caching and lazy updates
- Efficient texture rendering
- Conditional event registration

## 💡 Tips

1. **Crosshair not visible?** Check if "Only show in combat" is enabled
2. **Mouse ring stuttering?** Reduce segment count in code (default: 64)
3. **GCD Tracker not showing?** Make sure you're using abilities that trigger GCD
4. **Want to reset?** Use `/huskies reset` or delete SavedVariables file

## 🐛 Known Issues

- Circle crosshair requires a texture file (create a simple circle .tga if needed)
- Mouse ring performance depends on segment count (adjust if needed)
- Dragonriding detection uses aura names (may need updates for localization)

## 📝 Changelog

### Version 2.0.0
- Complete rewrite from scratch
- Added modular architecture
- Improved performance significantly
- Modern tabbed UI with logo
- Added Mouse Ring feature
- Added GCD Tracker feature
- Added Combat Notifier feature
- Better settings organization
- Removed library dependencies

### Version 1.0.0
- Initial release
- Basic crosshair functionality

## 👤 Author

**Huskies**

## 📄 License

Free to use and modify for personal use.

---

**Enjoy the addon! Type `/huskies` to get started!** 🎮
