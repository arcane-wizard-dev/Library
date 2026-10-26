# Arcane Wizard: Library

[![GitHub Release](https://img.shields.io/github/v/release/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases) [![GitHub Release Date](https://img.shields.io/github/release-date/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases)

_The shared foundation of all Arcane Wizard addons._

Arcane Wizard: Library provides shared functions and reusable interface components for World of Warcraft addons. Other addon developers can also use it in their own projects.

## For Players

Install this library if an addon you use requires it. It provides shared functionality and has no standalone interface.

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

### Library Revision

`X-Revision` in `ArcaneWizardLibrary.toc` is an integer maintained separately from the release version and exposed as `ArcaneWizardLibrary.ADDON_REVISION`. Increase it when addons need to distinguish changes to the library's public functions or behavior. Builds preserve the revision.

Each Arcane Wizard addon declares its minimum revision as `X-Library-Revision` in its TOC and checks it before using the library. Equal or higher revisions are accepted. A missing, invalid, or older revision stops addon startup and reports the required and installed revisions in chat and through the Lua error handler. SavedVariables are left intact.

When an addon starts using newer library functionality, raise only that addon's minimum revision to the first revision providing it. Higher library revisions must continue to support addons that require earlier revisions.

## Supported Languages & Flavors

* Languages: English, German, Russian
* Flavors: Classic, Burning Crusade - Classic Anniversary Edition, Mists of Pandaria - Classic, Forever, Retail

## Bugs & Feedback

If you find a bug or have a suggestion, please use the GitHub Issues or the CurseForge comments.

## Translation Support

If you would like to localize this addon into other languages, your contribution would be very welcome. Please submit your translations directly via GitHub.
