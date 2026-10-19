# Arcane Wizard: Library

[![GitHub Release](https://img.shields.io/github/v/release/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases) [![GitHub Release Date](https://img.shields.io/github/release-date/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases)

This addon is a library for World of Warcraft that bundles recurring code segments and functionalities. Originally developed to optimize the code of my own addons, it is designed to be easily utilized by other addon developers.

## For Players

This library does not have a standalone interface. Please install this addon only if it is required by another addon you are using. It ensures that those addons run efficiently and use common functions.

## For Developers

This library provides pre-built solutions for common addon functionalities.

### Features

#### Addon Context

Shared addon registration, settings access, minimap and AddonCompartment integration, and debug output.

#### Frames, Tables & Controls

Reusable windows, scrollable tables, tabs, and input controls using Blizzard's native appearance for each supported game version.

#### Prebuilt Windows & Dialogs

Ready-to-use changelog windows, link popups, and confirmation dialogs.

#### Utilities

Common helpers for character identifiers and copying nested tables.

#### Settings

Addon options in Blizzard's settings menu, with reusable layouts and profile support.

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
