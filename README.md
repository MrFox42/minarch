# Description

View all your artifacts progress, and solve them in one compact frame. Also you can view all your artifact history neatly sorted by race, and a list of dig sites. You can left-click the keystone button to attach keystones (or right-click to remove), or if you prefer there are options to automatically use keystones! You can monitor the artifacts progress, or how close you are to the fragment cap.

## Latest Minor Versions

### 9.0.2

- **New feature**: Double right click to Survey (enabled by default)
- Added the option to treat fragment-capped races as irrelevant
- **9.0.2.2** Changed fragment-cap related conditions

#### Companion Improvements:
- Each button can be disabled separately
- Added the option to only show the solve button for relevant races
- Added the option to change background color and background color opacity
- Button spacing and frame padding is now customizable
- Button order is fully customizable

### 9.0.1
- Added the option to lock the Companion in place, disabling dragging
- Added the option to persist Companion position on all characters using the same settings profile
- **9.0.1.1** Fix saving Companion position after dragging the frame

## Latest Major Version: v9.0.0

- New feataure: **Companion** (**distance tracker** and more, details down below)
- Fixed issues caused by Shadowlands LUA changes
- MinArch is now compatible with addons that emulate TomTom (like Carbonite Maps)
- Added an option to prioritize a selected race when creating automatic waypoints (Selectable in the TomTom section of MinArch settings)
- Right clicking on the auto-waypoint button now opens the waypoint settings page
- Fixed an issue with the automatic waypoints sometimes not selecting the closest digsite
- Show confirmation dialog before solving artifacts of fragment-capped races
- **9.0.0.1** Companion frame: Improved dragging
- **9.0.0.2** Fragment-capped solve confirmation: add third option to disable confirmation dialogs

For past changes, visit the [Changelog page](https://www.curseforge.com/wow/addons/minimal-archaeology/pages/minimal-archaeology/changelog).

## Companion

The **Companion** is a tiny little customizable frame that currently includes the following features:

- **Distance tracker** when surveying
- Auto-waypoint button
- Survey spell button
- Solve button for solvable artifacts
- Crate button

The companion can be disabled.

## Upcoming features

The following features are planned for Minimal Archaeology in no particular order and without ETA:

- Detailed, customizable DataBroker tooltip
- Dig site icons on flight maps
- Option to the auto-resize history window
- Achievement progress
- Better indication of pristine artifacts
- Option to ignore dig sites you hate

If you're curious about all planned features, visit the [Upcoming features page](https://www.curseforge.com/wow/addons/minimal-archaeology/pages/minimal-archaeology/upcoming-features).

## Commands
**/minarch**
shows available commands

## Useful Macros
Use this in combination with the auto-hide feature

**/cast Survey**
**/minarch show**

## Feedback
Any Bug reports/Comments/Suggestions/etc... are appreciated.

For feedback, please use the project's issue tracker on CurseForge.

Please open a new issue if you are experiencing bugs, and include as much detail as possible. Make sure you didn't miss the known issues section, and check open issues before you create a new one.


## Known Issues
- Main window auto-hides after solving an artifact, even if there's another solve available
