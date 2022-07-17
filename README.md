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

## What's next:
- History window improvements such as achievement progress, better indicator for pristine artifacts

## Latest Changes

### 9.2.0

- Fixed a lua error
- TOC Bump
- **9.2.0.1** bump toc
- **9.2.0.2** New options to reset companion frame position

### 9.0.5

- Show collector achievement progress for Pandaria artifacts
- Pristine progress is now indicated with user-friendly icons and tooltips
- Fixed the auto-detection of Legion Archaeology bi-weekly quests
- Added support for using Blizzard Map Pins for Digsite navigation (enabled by default, can be disabled)
- Improved performance
- **9.0.5.1** Compatibility changes for skinning addons
- **9.0.5.2** Fix issue with the Companion showing after combat when it shouldn't
- **9.0.5.3** TOC Bump

### 9.0.4

- Added the options to prevent casting Survey on dobule right click while mounted and/or flying
- Added the option and toggle to auto-resize the history window

### 9.0.3 - Maintenance release

- TomTom: Fixed auto-waypoint settings
- Companion: Tooltips for solves/crates are now automatically refreshed
- Fixed a lua error caused by double right click surveying in combat
- Slight performance improvement
- Behind the scenes changes: the addon is getting refactored to speed up development
- **9.0.3.1** Fix version in toc
- **9.0.3.1** Fix artifact bars positioned outside of the main window
- **9.0.3.1** Show races in the main window even if they are not discovered by the player yet
- **9.0.3.2** Fixed main window auto-opening all the time
- **9.0.3.3** Fixed a lua error when opening Companion settings
- **9.0.3.4** Fixed french locale for Site de fouilles : Les confins Lointains
- **9.0.3.4** Added workaround for detecting digsites in the old version of Vale of Eternal Blossoms

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
- Better indication of pristine artifacts
- Option to ignore dig sites you hate

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
