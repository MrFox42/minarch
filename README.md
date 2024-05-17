
[![Patreon](http://img.shields.io/badge/support-patreon-ff424d)](https://www.patreon.com/minarch)
[![Install](http://img.shields.io/badge/install-curseforge-f16436)](https://www.curseforge.com/wow/addons/minimal-archaeology)
[![Install](http://img.shields.io/badge/install-wago-f16436)](https://addons.wago.io/addons/minarch)

---

# Description

View all your artifacts progress, and solve them in one compact frame.
Also you can view all your artifact history neatly sorted by race, and a list of dig sites.
You can left-click the keystone button to attach keystones (or right-click to remove),
or if you prefer there are options to automatically use keystones!
You can monitor the artifacts progress, or how close you are to the fragment cap.

## Recent changes

### 10.2.11

- Companion: implement optional artifact progress bar with optional tooltip and solve on click (enabled by default)
- Companion: add option to hide solvable artifact if it's not related to the nearest digsite
- History: implement total sold price display for race statistics (by *Delrik* via GitHub)
- Implement map pin scaling option
- Fix issue with auto-waypoint sometimes not selecting the closest digsite
- Fix Companion not always hiding properly in combat
- Fix Nerubian issue with digsites on Eastern Kingdoms

### 10.2.10

- History: implement race statistics (can be hidden)
- Companion: added optional skill bar (enabled by default)
- Fix max rank in Cata pre-patch
- Fix main window popping up the wrong time when autoShowOnCap is enabled
- Fix history refresh (mostly, blizzard API sometimes reports the wrong data)
- Fix remember window state functionality
- **10.2.10.2** Fix lua error: attempt to index field 'skillBar'
- **10.2.10.3** History: fix completed counts
- **10.2.10.4** Companion: fix keystone count when canceling solve
- **10.2.10.5** Fix lua error after solving artifacts

### 10.2.9

- Navigation: **new option** to ignore hidden races when creating waypoints (disabled by default)
- Companion: grey out survey button when spell can't be casted
- Companion solve button: prioritize solvable artifacts over nearest available
- History: Fix lua error and history list not loading on first try
- Main Window: Show profession bar until expanion's max skill level is reached
- Fix missing race data for digsites

### 10.2.7

- Updated for Cataclysm Classic
- **10.2.8** Options menu restructured, clarified race related settings
- **10.2.8.6** fixed a lua error (attempt to index local 'artifact')
- **10.2.8.6** fixed race related options
- **10.2.8.6** fixed companion showing hidden races

For past changes, visit the [Changelog page](https://github.com/MrFox42/minarch/blob/master/CHANGELOG.md) on GitHub.

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
