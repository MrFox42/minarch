
[![Install](http://img.shields.io/badge/install-curseforge-f16436)](https://www.curseforge.com/wow/addons/minimal-archaeology)
[![Patreon](http://img.shields.io/badge/support-patreon-ff424d)](https://www.patreon.com/minarch)

---

# Description

View all your artifacts progress, and solve them in one compact frame.
Also you can view all your artifact history neatly sorted by race, and a list of dig sites.
You can left-click the keystone button to attach keystones (or right-click to remove),
or if you prefer there are options to automatically use keystones!
You can monitor the artifacts progress, or how close you are to the fragment cap.

## Recent new features:
- Companion frame (more details below)
- Double Right Click surveying
- Collector achievement progress indicators in the History window

### 10.2.7

- Updated for Cataclysm Classic
- **10.2.8** Options menu restructured, clarified race related settings

### 10.2.0

- Updated for 10.2.0
- **10.2.0.1** Fixed an issue with dbl right click surveying
- **10.2.0** Addon compartment support
- **10.2.2** Use GLOBAL_MOUSE_DOWN instead of HookScript for double click surveying
- **10.2.2** Add optional keystone button to the Companion's solve button
- **10.2.2** Add separate "Hide In Combat" option to the Companion
- **10.2.3** Fix Companion lua error and main window display issue with bars
- **10.2.3** Fix Companion not showing solvable relevant artifacts
- **10.2.4** Change the right click helper button from InSecureActionButtonTemplate to SecureActionButtonTemplate, added some extra debug messages

### 10.1.0

-  Updated for 10.1.5
- **10.1.0.1** Fix ClearOverrideBindings ADDON_ACTION_BLOCKED lua error

### 10.0.5.1

- Fix databroker error
- **10.0.5.2** Fixed an issue caused by right click during combat

## What's next:
- History window improvements such as achievement progress, better indicator for pristine artifacts

## Latest Changes

### 10.0.3

- Companion: added optional button to summon random favorite mount (disabled by default)

### 10.0.2

- Bump TOC
- Companion: customize distance indicator shape
- Fix GetContainer... lua errors

### 10.0.0

- Updated for Dragonflight
- **10.0.1.1** Fixed some lua errors
- **10.0.1.2** Companion: reset distance indicator when casting Survey
- **10.0.1.3** Fix keybinding options

**Known issues:**
- Shortcut buttons on the main options page are not working

For past changes, visit the [Changelog page](https://www.curseforge.com/wow/addons/minimal-archaeology/pages/minimal-archaeology/changelog).

## Companion

The **Companion** is a tiny little customizable frame that currently includes the following features:

- **Distance tracker** when surveying
- Auto-waypoint button
- Survey spell button
- Solve button for solvable artifacts
- Crate button
- Each button can be disabled manually and their order is fully customizable

The companion itself can also be fully disabled.

## Upcoming features

The following features are planned for Minimal Archaeology in no particular order and without ETA:

- Detailed, customizable DataBroker tooltip
- Dig site icons on flight maps
- Achievement progress
- Option to ignore dig sites you hate

## Commands
**/minarch**
shows available commands

## Useful Macros
Use this in combination with the auto-hide feature

**/cast Survey**
**/minarch show**

## Feedback
Any Bug reports/Comments/Suggestions/etc are appreciated.

For feedback, please use the project's issue tracker on CurseForge.

Please open a new issue if you are experiencing bugs, and include as much detail as possible. Make sure you didn't miss the known issues section, and check open issues before you create a new one.
