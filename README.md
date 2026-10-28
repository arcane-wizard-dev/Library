# Arcane Wizard: Library

[![GitHub Release](https://img.shields.io/github/v/release/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases) [![GitHub Release Date](https://img.shields.io/github/release-date/arcane-wizard-dev/Library?color=blue&logo=github&cacheSeconds=600)](https://github.com/arcane-wizard-dev/Library/releases)

_One library for every addon._

Arcane Wizard: Library is a World of Warcraft addon that provides the shared foundation for all Arcane Wizard addons. It brings common functionality together in one place, making it easier to develop and maintain the addons that use it.

## For Players

Install Arcane Wizard: Library alongside your Arcane Wizard addons and keep it enabled. It provides the shared functionality they need, runs in the background, and has no interface of its own.

## For Developers

Arcane Wizard: Library provides reusable components that simplify addon development and maintenance. Shared functionality can be maintained centrally and used across multiple addons. Other addon developers are welcome to use the library in their own projects.

### Features

#### Addon Context

The library provides shared addon registration, access to settings, minimap and Addon Compartment integration, and debug output.

#### Frames, Tables & Controls

Reusable windows, scrollable tables, tabs, and input controls match Blizzard's native appearance for each supported game version.

#### Prebuilt Windows & Dialogs

The library provides ready-to-use changelog windows, link popups, and confirmation dialogs.

#### Utilities

Shared helpers handle character identifiers and copy nested tables.

#### Settings

The library integrates addon options into Blizzard's settings menu with reusable layouts and profile support.

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

If you find a bug or have a suggestion, please open a GitHub issue or leave a comment on CurseForge.

## Translation Support

If you would like to localize this addon into other languages, your contribution would be very welcome. Please submit your translations directly via GitHub.
