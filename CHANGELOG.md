# Minimal Archaeology
## Latest Version

### 11.1.0

- Updated for Mainline 11.1
- **11.1.0.1** Set Addon category
- **11.1.0.1** Update zone name in translations
- **11.1.0.2** Update German translations (courtesy of Sneaker42)
- **11.1.0.3** Fix taint/error when opening world map
- **11.1.0.4** Fix map pins on Cata classic
- **11.1.0.5** Bump toc for 11.1.5
- **11.1.0.6** Added German translations (translated by AI, don't hesitate to report any mistranslations)
- **11.1.0.7** Add Mists.toc
- **11.1.0.8** Fix Companion tutorial frame
- **11.1.0.9** Fix MoP config and lua errors
- **11.1.0.10** Fix digsites lua error
- **11.1.0.10** Implement settings migration from Cata to Mop
- **11.1.0.10** Fix history window showing two active fossil artifacts
- **11.1.0.13** Fix lua error with Pandaria digsites

### 11.0.2

- Added support for localizations, if you would like to help with translations, head over to https://curseforge.com/wow/addons/minimal-archaeology/localization
- Fix casting survey with the configured key binding on non-english clients
- "Right click to open settings" now opens the relevant options menu
- Refactored code base to make it a bit more future-proofed. Please don't hesitate reporting any errors/bugs that might come up after this.
- **11.0.2.1** Updated Chinese translations (courtesy of 萌丶汉丶纸)

### 11.0.0

- Updated for War Within
- **11.0.0.1** Fix waypoint creation ignoring hidden races even when the "Ignore Hidden" option is disabled
- **11.0.0.1** Fix opening Options on Mainline
- **11.0.0.2** Fix GetSpellInfo lua error
- **11.0.0.3** Fix surveying
- **11.0.0.4** Fix flight map showing hidden and special pins
- **11.0.0.5** Bump toc for 11.0.2
- **11.0.0.7** Fix Companion position issues
- **11.0.0.8** Show digsite race in digsite list
- **11.0.0.9** Implement option to use left click for double click surveying
- **11.0.0.11** Fix Companion survey button

### 10.2.13

- **New Feature: Taxi Service**: if enabled, waypoints will be created to the nearest flight master if the nearest digsite is farther than the user-configured distance. You can find the options in the Navigation section.
- Added digsite icons on flight maps (indicated on the nearest known flight master)
- History: artifact list is now grouped by progress (enabled by default)
- Fix multiple issues with race icons on the map
- Added HereBeDragons as a dependency, digsite distances are now returned in yards
- **10.2.13.1** Fix issue with unwanted waypoints being generated
- **10.2.13.2** Fix digsite related lua errors
- **10.2.13.2** Fix issue with digsites being undetected
- **10.2.13.2** Fix Main Window and Companion update issue in rare cases

### 10.2.12

- Companion: survey button now respects the same survey settings as double right click
- Companion: show cooldown on Survey button
- Extended priority list: you can now set an order for races instead of prioritizing one at a time
- Experimental New Feature: Path optimization. Path optimization tries to reduce travel times on the long run by calculating the shortest path that touches all active digsites, also preferring sites that are closer to each other. You can enable it under developer settings, still testing, feedback is welcome!
- Fix detecting nearest digsite on Outland
- Create waypoint to digsites related to hidden races if nothing else is available
- Updated the list of patrons, thank you for the support!
- **10.2.12.1** Fix double right click surveying
- **10.2.12.2** Fix survey button being disabled when double right click is disabled
- **10.2.12.2** Fix path optimization calculation
- **10.2.12.2** Add option to hide Companion when no digsites are available on the world
- **11.1.0.14** Fix conflict with Leatrix Plus (tooltip anchor issue)

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

### 10.2.0 - 10.2.2

- Updated for 10.2.0
- **10.2.0.1** Fixed an issue with dbl right click surveying
- **10.2.1** Addon compartment support
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

### 10.0.3

- Companion: added optional button to summon random favorite mount (disabled by default)

### 10.0.2

- Bump TOC
- Companion: customize distance indicator shape
- Fix GetContainer... lua errors

### 10.0.0

- Updated for DragonFlight
- **10.0.1.1** Fixed some lua errors
- **10.0.1.2** Companion: reset distance indicator when casting Survey
- **10.0.1.3** Fix keybinding options

### 9.2.0

- Fixed a lua error
- Bump toc version
- **9.2.0.1** bump toc
- **9.2.0.2** New options to reset companion frame position
- **9.2.0.3** Fix lua error when a database entry is missing for certain locales

### 9.1.0

- Bump toc version

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
