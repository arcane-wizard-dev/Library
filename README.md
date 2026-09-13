# Arcane Wizard: Library

[![GitHub Release](https://img.shields.io/github/v/release/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases) [![GitHub Release Date](https://img.shields.io/github/release-date/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases)

This addon is a library for World of Warcraft that bundles recurring code segments and functionalities. Originally developed to optimize the code of my own addons, it is designed to be easily utilized by other addon developers.

## For Players

This library does not have a standalone interface. Please install this addon only if it is required by another addon you are using. It ensures that those addons run efficiently and use common functions.

## For Developers

This library provides pre-built solutions for common addon functionalities.

### Features

#### Addon Context

* Registers addon contexts.
* Provides addon-dependent helpers for settings category opening, minimap buttons, and AddonCompartment handlers.

#### Frames

* <sup>✨ NEW</sup> Windows: Provides consistently styled, movable windows with configurable backgrounds, borders, portraits, and close buttons.
* <sup>✨ NEW</sup> Window Tabs: Provides bottom text tabs with automatically managed content pages.
* <sup>✨ NEW</sup> Popups: Provides compact popups with configurable backgrounds, borders, and close buttons.

#### Scroll Frames

* <sup>✨ NEW</sup> Provides scroll areas with transparent, solid, or patterned backgrounds, optional borders, custom vertical scrollbars, and mouse-wheel support across supported game versions.

#### Controls

* <sup>✨ NEW</sup> Provides consistently styled action buttons with classic or red styles, checkboxes, option groups, input fields, and dropdown menus across supported game versions.

#### Prebuilt Windows

* <sup>✨ NEW</sup> Changelog Window: Provides a reusable single-page changelog with a localized button for the addon options menu.

#### Dialogs

* Link Dialog: Shows a popup with an auto-highlighted text field for easy copying.
* Confirmation Dialog: Displays a standard Yes/No prompt to confirm actions and execute callbacks.

#### Utilities

* Provides helper methods for common addon values, such as character keys and split character/realm values.
* Includes a deep table copy helper.

#### Settings API Wrappers

* Adds standard UI elements to the Blizzard options menu.
* Includes standard Profiles and About sections.
* Supports buttons and static info text rows with configurable height presets.
* Supports checkboxes, sliders, and dropdown menus.
* Supports combined checkbox and slider elements.
* Supports expandable headers to organize settings sections.

### How to Integrate

1.  Add the following to your `.toc` file:

	> `## Dependencies: ArcaneWizardLibrary`

2.  Set the dependency on the CurseForge project page to ensure users download it automatically.

## Supported Languages & Flavors

* Languages: English, German, Russian
* Flavors: Classic, Burning Crusade - Classic Anniversary Edition, Mists of Pandaria - Classic, Retail

## Bugs & Feedback

If you find a bug or have a suggestion, please use the GitHub Issues or the CurseForge comments.

## Translation Support

If you would like to localize this addon into other languages, your contribution would be very welcome. Please submit your translations directly via GitHub.
