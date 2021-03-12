# Minimal Archaeology
## Latest Version

### 9.0.5

- Show collector achievement progress for Pandaria artifacts
- Pristine progress is now indicated with user-friendly icons and tooltips
- Fixed the auto-detection of Legion Archaeology bi-weekly quests
- Added support for using Blizzard Map Pins for Digsite navigation (enabled by default, can be disabled)
- Improved performance
- **9.0.5.1** Compatibility changes for skinning addons
- **9.0.5.2** Fixed issue with the Companion showing after combat when it shouldn't
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

### 9.0.0

- New feataure: **Companion** (**distance tracker** and more, details down below)
- Fixed issues caused by Shadowlands LUA changes
- MinArch is now compatible with addons that emulate TomTom (like Carbonite Maps)
- Added an option to prioritize a selected race when creating automatic waypoints (Selectable in the TomTom section of MinArch settings)
- Right clicking on the auto-waypoint button now opens the waypoint settings page
- Fixed an issue with the automatic waypoints sometimes not selecting the closest digsite
- Show confirmation dialog before solving artifacts of fragment-capped races
- **9.0.0.1** Companion frame: Improved dragging
- **9.0.0.2** Fragment-capped solve confirmation: add third option to disable confirmation dialogs

### 8.3.0

- Bump TOC
- **8.3.0.1**: Fix typo in name of Digsite: The Ruined Sanctum

### 8.2.1

- All Window states are now remembered upon relog/reload, unless the "Always start hidden" option is enabled

## Known issues

- Main window auto-hides after solving an artifact, even if there's another solve available

## Recent updates

### 8.2.0

- Window buttons in the main window are now toggles
- Hiding MinArch windows in combat is now optional
- *Alt + click*ing on the minimap icon now hides all MinArch windows

### 8.0.12

- Replaced relevancy toggle button with a collapse/expand button
- Added a **Crate button** that glows when you have an artifact in your inventory that you can crate
- Windows now automatically hide in combat, and auto-show after combat if they were visible
- **8.0.12.1**: Fixed a lua error thrown when opening certain UI panels

### 8.0.11

- You can now toggle relevant races in the main window based on 3 customizable settings: proximity, continent/expansion, available to solve
- Added item icons to the history window
- Added a quest icon overlay besides the race icon which has an available legion archaeology questline
- History window automatically switches race when solving an artifact
- Moved around some settings into submenus, added buttons for them in the main settings menu
- MinArch windows should now stay behind vendor or other npc related windows
- **8.0.11.1**: Main window delays updates if the player is in combat, fixing *combat lockdown* lua errors

### 8.0.10

- TomTom integration: you can now set TomTom waypoints directly from MinArch. Also, there are two new options for creating automatic digsite waypoints
- Opening the history window in a digsite will now list projects related to that digsite
- Added an option to auto-show the main window, when a fragment cap is reached with one of the races
- DataBroker button now follows MinArch fragment cap settings
- Optimized World Map overlay icons

### 8.0.9

- Minimal Archaeology is now DataBroker compatible
- Archaeology skill bar is now immediately displayed when a new skill rank is learned after being maxed out
- Spear of Rethu is now correctly appears in the list of Highmountain Tauren artifacts
- History window race buttons code completely rewritten, normally you should not notice any difference
- Optimized CPU usage
- **8.0.9.1** DataBroker button now properly shows amounts when a keystone is applied
- **8.0.9.2** Minimap button should no longer behave oddly with minimap button addons
- **8.0.9.3** DataBroker button should now update properly when settings changed or keystones  clicked
- **8.0.9.4** History window updates should now be more reliable

### 8.0.8 - 8.0.8.1

- History window now indicates which artifact is available from the current Legion archaeology questline
- Auto-show main window in dig sites, on survey, and/or when a solve becomes available
- Added an option to show more detailed debug messages
- World map overlay icons are now immediately show/hide when dig sites are toggled on the map
- **8.0.8.1**: Changing settings profiles should now immediately apply the changes

### 8.0.7

- Settings menu revamped from the ground up with profiles support (Your old settings should migrate automatically)
- Right clicking the minimap icon now correctly opens MinArch settings
- Added item tooltip for keystones in the main window
- Keystone count should now update when the player withdraws them from the guild bank
- Fixed dig site icon misalignment after talking with certain flight masters
- Fixed Archaeology skill progress bar background
- Fixed cap for Drust and Zandalari fragments
- The ping sound now correctly plays when there's a solve available (if sounds are not disabled)
- Fixed an issue caused by the default archaeology UI reporting wrong fragment counts

### 8.0.6.x
- Fixed a display issue with the progress bars in the main window
- Dig site zone/subzone is now correctly detected and updated (subzone is only updated when digging)
- Map overlay dig site icons are now working correctly (they now respect pan and zoom and they're hidden if the dig sites (shovel icons) are hidden
- Fixed dig site race data for some sites with the wrong race
- Added missing dig site race info

### 8.0.5
- Added Battle for Azeroth continents to the dig sites window
- Corrected the maximum number of fragments for all races
- Dig sites should now start filling up the dig sites window on all locales (replaced LibBabble DigSites with a custom solution)
- Fixed zone name detection for newly discovered and active dig sites
- Added option to show/hide world map overlay icons next to dig sites (they're now hidden by default)

### 8.0.4.1
 - Fixed an issue with continent detection in the dig site window

### 8.0.4
- Fixed dig site detection for english clients (work in progress for other localizations)
- Fixed hiding the archaeology skill bar on max skill level
- Added support for Zandalari and Drustvari dig sites
- Fixed dig site window continent tooltips
- Fixed artifact bar refresh issues
- Fixed sort order for some history items

### 8.0.3
- Added an option to toggle Minimal Archaeology status messages in the chat (messages are now hidden by default)
- Made some internal changes to the code related to artifact bars, you should not notice any difference
