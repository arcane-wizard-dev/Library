# Arcane Wizard: Library

[![GitHub Release](https://img.shields.io/github/v/release/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases) [![GitHub Release Date](https://img.shields.io/github/release-date/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases)

This addon is a library for World of Warcraft that bundles recurring code segments and functionalities. Originally developed to optimize the code of my own addons, it is designed to be easily utilized by other addon developers.

## For Players

This library does not have a standalone interface. Please install this addon only if it is required by another addon you are using. It ensures that those addons run efficiently and use common functions.

## For Developers

This library provides pre-built solutions for common addon functionalities.

### Features

#### Addon Context

Provides a shared starting point for each addon, handling registration and access to its settings, minimap button, and AddonCompartment entry.

#### Frames

Creates movable windows, compact popups, insets, content tabs, and scrollable areas using Blizzard's native appearance for each supported game version. Supports configurable backgrounds and close buttons, native scrollbars, and mouse-wheel handling.

#### Controls

Provides buttons, checkboxes, option groups, dropdowns, and text inputs through a shared interface to Blizzard's native controls.

#### Prebuilt Windows

Provides a ready-to-use changelog window that presents an addon's release history on a single page and includes a localized button to open its settings.

#### Dialogs

Handles common interactions through a link popup with preselected text for copying and a Yes/No confirmation dialog that runs the addon's chosen action.

#### Utilities

Supplies shared helpers for character identifiers, separate character and realm values, and independent copies of nested tables.

#### Settings API Wrappers

Builds addon settings within Blizzard's options menu using standard controls, information rows, and reusable Profiles and About sections. Collapsible groups, freely placed horizontal separators, and optional New badges help organize and highlight settings.

### How to Integrate

1.  Add the following to your `.toc` file:

	> `## Dependencies: ArcaneWizardLibrary`

2.  Set the dependency on the CurseForge project page to ensure users download it automatically.

## Supported Languages & Flavors

* Languages: English, German, Russian
* Flavors: Classic, Burning Crusade - Classic Anniversary Edition, Mists of Pandaria - Classic, Forever, Retail

## Bugs & Feedback

If you find a bug or have a suggestion, please use the GitHub Issues or the CurseForge comments.

## Translation Support

If you would like to localize this addon into other languages, your contribution would be very welcome. Please submit your translations directly via GitHub.
