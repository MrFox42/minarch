# Minimal Archaeology
## Latest Version

### 8.0.8 - 8.0.8.1

- History window now indicates which artifact is available from the current Legion archaeology questline
- Auto-show main window in dig sites, on survey, and/or when a solve becomes available
- Added an option to show more detailed debug messages
- World map overlay icons are now immediately show/hide when dig sites are toggled on the map
- **8.0.8.1**: Changing settings profiles should now immediately apply the changes

## Known issues

- Main window auto-hides after solving an artifact, even if there's another solve available

## Recent updates

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