---@meta

-- AddonContext

---@class ArcaneWizardLibraryAddon
---@field name string
---@field version string|nil
---@field buildDate string|nil
---@field mediaPath string
---@field mainCategoryId number|nil
---@field initializationAborted boolean|nil
---@field GetMediaPath fun(self: ArcaneWizardLibraryAddon, fileName: string|nil): string Returns the addon media path or a media file path below it.
---@field PrintDebug fun(self: ArcaneWizardLibraryAddon, msg: any) Prints a debug message with the addon name.
---@field SetMainCategoryId fun(self: ArcaneWizardLibraryAddon, categoryId: number) Stores the Blizzard settings category ID for this addon.
---@field OpenCategory fun(self: ArcaneWizardLibraryAddon): boolean Opens the stored Blizzard settings category when not blocked by combat lockdown.
---@field InitializeOptions fun(self: ArcaneWizardLibraryAddon, config: table): table|nil Initializes and binds this addon's GUID-based option profiles.
---@field IsAccountProfile fun(self: ArcaneWizardLibraryAddon): boolean Returns whether the current character uses account settings.
---@field OpenSettingsOnLoading fun(self: ArcaneWizardLibraryAddon): boolean Opens settings when requested by a profile change.
---@field ToggleProfileMode fun(self: ArcaneWizardLibraryAddon) Switches the profile selection and requests settings after reload.
---@field ResetAllCharacterProfiles fun(self: ArcaneWizardLibraryAddon) Resets character profiles while preserving account settings.
---@field AbortInitialization fun(self: ArcaneWizardLibraryAddon, frame: Frame) Stops startup when the player identity is unavailable.
---@field RegisterMinimapButton fun(self: ArcaneWizardLibraryAddon, config: table): table Registers a LibDataBroker minimap button for this addon.
---@field CreateCompartmentHandlers fun(self: ArcaneWizardLibraryAddon, config: table): table Creates AddonCompartment handler functions for this addon.

-- Changelog

---@class ArcaneWizardLibraryChangelogVersion
---@field version string Version label displayed as the section heading.
---@field date? string Optional release or build date.
---@field entries string[] Changelog entries displayed as bullet points.

---@class ArcaneWizardLibraryChangelog
---@field [integer] ArcaneWizardLibraryChangelogVersion
---@field notices? string[] Current notices displayed before the version history.

---@class (partial) ArcaneWizardLibraryChangelogFrame: ArcaneWizardLibraryWindowFrame

-- Controls

---@class ArcaneWizardLibraryButtonConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the button.
---@field width number Button width in pixels.
---@field label string Displayed button label.
---@field onClick? fun(button: ArcaneWizardLibraryActionButton, mouseButton: string, down: boolean) Called when the button is clicked.

---@class ArcaneWizardLibraryCheckboxConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the checkbox.
---@field width number Checkbox width in pixels.
---@field label string Displayed checkbox label.
---@field checked boolean Initial checked state.
---@field onValueChanged? fun(checked: boolean, checkbox: ArcaneWizardLibrarySelectionControl) Called after a user changes the value.

---@class ArcaneWizardLibraryOptionGroupConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the option group.
---@field width number Width of every option in pixels.
---@field options ArcaneWizardLibraryOptionConfig[] Options in display order.
---@field selectedValue string|number|boolean Initially selected option value.
---@field onValueChanged? fun(value: string|number|boolean, option: ArcaneWizardLibrarySelectionControl, group: ArcaneWizardLibraryOptionGroup) Called after a user changes the value.

---@class ArcaneWizardLibraryActionButton: Button

---@class ArcaneWizardLibrarySelectionControl: CheckButton
---@field Text FontString Control label.

---@class ArcaneWizardLibraryOptionConfig
---@field label string Displayed option label.
---@field value string|number|boolean Value represented by the option.

---@class ArcaneWizardLibraryOptionGroup: Frame
---@field buttons ArcaneWizardLibrarySelectionControl[] Option buttons in display order.
---@field buttonsByValue table<string|number|boolean, ArcaneWizardLibrarySelectionControl> Option buttons indexed by value.
---@field value string|number|boolean Currently selected value.
---@field enabled boolean Whether the option group is enabled.
---@field GetValue fun(self: ArcaneWizardLibraryOptionGroup): string|number|boolean
---@field SetValue fun(self: ArcaneWizardLibraryOptionGroup, value: string|number|boolean)
---@field SetEnabled fun(self: ArcaneWizardLibraryOptionGroup, enabled: boolean)

-- Dropdown

---@class ArcaneWizardLibraryDropdownOption
---@field label? string Displayed option or group label.
---@field value? string|number|boolean Selectable option value.
---@field icon? string|number Optional texture path or file ID.
---@field atlas? string Optional texture atlas name.
---@field textColor? number[] Optional RGB or RGBA label color.
---@field children? ArcaneWizardLibraryDropdownOption[] Nested options.
---@field divider? boolean Whether the entry is a divider.
---@field disabled? boolean Whether the entry is disabled.

---@class ArcaneWizardLibraryDropdownConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the dropdown.
---@field width number Dropdown width in pixels.
---@field options ArcaneWizardLibraryDropdownOption[]|fun(): ArcaneWizardLibraryDropdownOption[] Static options or a dynamic options provider.
---@field selectedValue? string|number|boolean Initially selected option value.
---@field onValueChanged? fun(value: string|number|boolean, option: ArcaneWizardLibraryDropdownOption, dropdown: ArcaneWizardLibraryDropdown) Called after a user changes the selection.

---@class ArcaneWizardLibraryDropdown: DropdownButton
---@field value? string|number|boolean Currently selected value.
---@field optionsSource ArcaneWizardLibraryDropdownOption[]|fun(): ArcaneWizardLibraryDropdownOption[] Static options or a dynamic options provider.
---@field onValueChanged? fun(value: string|number|boolean, option: ArcaneWizardLibraryDropdownOption, dropdown: ArcaneWizardLibraryDropdown)
---@field defaultText string Text displayed without a selection.
---@field emptyText string Text displayed when the menu has no entries.
---@field SetDefaultText fun(self: ArcaneWizardLibraryDropdown, text: string)
---@field SetupMenu fun(self: ArcaneWizardLibraryDropdown, generator: fun(owner: ArcaneWizardLibraryDropdown, root: table))
---@field GetValue fun(self: ArcaneWizardLibraryDropdown): string|number|boolean|nil
---@field SetValue fun(self: ArcaneWizardLibraryDropdown, value: string|number|boolean|nil)
---@field SetOptions fun(self: ArcaneWizardLibraryDropdown, options: ArcaneWizardLibraryDropdownOption[]|fun(): ArcaneWizardLibraryDropdownOption[])
---@field SetEmptyText fun(self: ArcaneWizardLibraryDropdown, text: string)
---@field CloseMenu fun(self: ArcaneWizardLibraryDropdown)

-- Frames

---@class ArcaneWizardLibraryWindowFrame: Frame
---@field background Texture|Frame Configurable window background.
---@field content Frame Content area inside the window frame.
---@field titleBar Frame Integrated title bar and drag handle.
---@field titleText FontString Title font string.
---@field portraitFrame? Frame Optional portrait frame.
---@field portrait? Texture Optional portrait image.
---@field closeButton? Button Optional close button.
---@field closeOnEscape boolean Whether pressing Escape hides the window.
---@field tabGroup? ArcaneWizardLibraryTabGroup Optional attached tab group.

---@class ArcaneWizardLibraryPopupFrame: Frame, BackdropTemplate
---@field NineSlice? {Center: Texture}
---@field Center? Texture
---@field background Texture Configurable popup background.
---@field content Frame Content area inside the popup frame.
---@field closeButton? Button Optional close button.
---@field closeOnEscape boolean Whether pressing Escape hides the popup.
---@field SetBorderShown fun(self: ArcaneWizardLibraryPopupFrame, shown: boolean) Shows or hides the popup border.

---@class ArcaneWizardLibraryCloseButtonConfig
---@field size? number Button width and height in pixels; defaults to Blizzard's size.
---@field point? FramePoint Anchor on the button and its window; defaults to TOPRIGHT.
---@field x? number Horizontal offset; defaults to 0 when overriding the anchor.
---@field y? number Vertical offset; defaults to 0 when overriding the anchor.

---@class ArcaneWizardLibraryInsetFrame: Frame
---@field background Texture Configurable inset background.

---@class ArcaneWizardLibraryInsetConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent of the inset.
---@field width number Initial width in pixels.
---@field height number Initial height in pixels.
---@field backgroundStyle? "tiled"|"tiled-dark"|"textured"|"shaded"|"shaded-alt" Defaults to tiled.
---@field backgroundAlpha number Background opacity from 0 to 1.

---@class ArcaneWizardLibraryWindowConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field title string Text displayed in the title bar.
---@field width number Initial frame width.
---@field height number Initial frame height.
---@field style? "standard"|"flat"|"solid" Native window appearance; defaults to standard. Solid keeps the standard background without top streaks.
---@field backgroundAlpha number Initial background opacity from 0 to 1.
---@field showPortrait boolean Whether to create a portrait frame.
---@field showCloseButton boolean Whether to create a close button.
---@field closeButton? ArcaneWizardLibraryCloseButtonConfig Optional size and anchor overrides.
---@field movable boolean Whether the window can be dragged.
---@field closeOnEscape? boolean Whether Escape hides the window.

---@class ArcaneWizardLibraryPopupConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field width number Initial frame width.
---@field height number Initial frame height.
---@field style? "toast"|"tooltip" Native popup appearance; defaults to toast.
---@field backgroundAlpha number Initial background opacity from 0 to 1.
---@field showBorder boolean Whether to create a popup border.
---@field showCloseButton boolean Whether to create a close button.
---@field closeButton? ArcaneWizardLibraryCloseButtonConfig Optional size and anchor overrides.
---@field movable boolean Whether the popup can be dragged.
---@field closeOnEscape? boolean Whether Escape hides the popup.

---@class ArcaneWizardLibraryTabPage: Frame
---@field tabId string Unique tab identifier.
---@field tabButton ArcaneWizardLibraryTabButton Button that selects this page.

---@class ArcaneWizardLibraryTabButton: Button
---@field tabId string Unique tab identifier.
---@field tabGroup ArcaneWizardLibraryTabGroup Owning tab group.
---@field label FontString Displayed tab label.
---@field isDisabled? boolean Whether the tab is disabled.

---@class ArcaneWizardLibraryTabEntry
---@field id string
---@field button ArcaneWizardLibraryTabButton
---@field page ArcaneWizardLibraryTabPage
---@field width number

---@class ArcaneWizardLibraryTabGroup: Frame
---@field window ArcaneWizardLibraryWindowFrame Window that owns the tab group.
---@field selectedTabId? string Currently selected tab identifier.
---@field tabEntries ArcaneWizardLibraryTabEntry[]
---@field tabsById table<string, ArcaneWizardLibraryTabEntry>
---@field onTabChanged? fun(id: string?, page: ArcaneWizardLibraryTabPage?)
---@field AddTab fun(self: ArcaneWizardLibraryTabGroup, id: string, text: string): ArcaneWizardLibraryTabPage
---@field SelectTab fun(self: ArcaneWizardLibraryTabGroup, id: string): ArcaneWizardLibraryTabPage
---@field GetSelectedTab fun(self: ArcaneWizardLibraryTabGroup): string?, ArcaneWizardLibraryTabPage?
---@field SetTabEnabled fun(self: ArcaneWizardLibraryTabGroup, id: string, enabled: boolean)
---@field SetOnTabChanged fun(self: ArcaneWizardLibraryTabGroup, callback: fun(id: string?, page: ArcaneWizardLibraryTabPage?)?)

-- Input

---@class ArcaneWizardLibraryInputConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the input field.
---@field width number Input width in pixels.
---@field text string Initial input text.
---@field placeholder string Text displayed while the unfocused input is empty.
---@field maxLetters? number Maximum number of characters. Nil or zero allows the game default.
---@field onTextChanged? fun(text: string, userInput: boolean, input: ArcaneWizardLibraryInput) Called after the text changes.
---@field onEnterPressed? fun(text: string, input: ArcaneWizardLibraryInput) Called before Enter clears focus.

---@class ArcaneWizardLibraryInput: EditBox
---@field Placeholder FontString
---@field ClearButton Button
---@field placeholderText string
---@field isClearButtonChange boolean
---@field onTextChanged? fun(text: string, userInput: boolean, input: ArcaneWizardLibraryInput)
---@field onEnterPressed? fun(text: string, input: ArcaneWizardLibraryInput)
---@field SetPlaceholder fun(self: ArcaneWizardLibraryInput, text: string)
---@field GetPlaceholder fun(self: ArcaneWizardLibraryInput): string

-- ScrollFrames

---@class ArcaneWizardLibraryScrollFrame: Frame
---@field background Texture
---@field scrollFrame ScrollFrame
---@field content Frame
---@field scrollBar Frame
---@field scrollUpButton Button
---@field scrollDownButton Button
---@field scrollStep number
---@field requestedContentHeight number
---@field SetContentHeight fun(self: ArcaneWizardLibraryScrollFrame, height: number)
---@field SetScrollStep fun(self: ArcaneWizardLibraryScrollFrame, step: number)
---@field ScrollToTop fun(self: ArcaneWizardLibraryScrollFrame)

---@class ArcaneWizardLibraryScrollFrameConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the scroll area.
---@field width number Scroll area width in pixels.
---@field height number Scroll area height in pixels.
---@field backgroundAlpha number Background opacity from 0 to 1.
---@field showBorder boolean Whether to create the outer border.
---@field contentInsets? {left: number, right: number, top: number, bottom: number} Non-negative viewport margins; defaults to the Library margins.

-- Tables

---@class ArcaneWizardLibraryTableColumn
---@field text string Column heading.
---@field width? number Fixed width; omitted widths share the remaining space.
---@field align? string Row text alignment: LEFT, CENTER or RIGHT; defaults to LEFT.

---@class ArcaneWizardLibraryTableColumnLayout
---@field x number Content-relative horizontal position.
---@field width number Available text width.
---@field align string Row text alignment.

---@class ArcaneWizardLibraryTableHeader: Frame
---@field cells Button[] Column heading buttons.

---@class ArcaneWizardLibraryTableConfig
---@field addonName? string Owning addon for errors.
---@field parent Frame Parent frame.
---@field width number Framed body width.
---@field height number Framed body height, excluding the heading above it.
---@field backgroundStyle? string Inset background style.
---@field backgroundAlpha number Inset background opacity.
---@field columns ArcaneWizardLibraryTableColumn[] Column definitions.
---@field tableMenu? fun(owner: DropdownButton, root: table) Native menu builder with addon actions.
---@field showTableMenu? boolean Defaults to true when a menu builder is supplied.

---@class ArcaneWizardLibraryTable: ArcaneWizardLibraryScrollFrame
---@field inset Frame Framed background.
---@field header ArcaneWizardLibraryTableHeader Fixed column headings.
---@field contentInsets {left: number, right: number, top: number, bottom: number} Shared viewport margins.
---@field columns ArcaneWizardLibraryTableColumn[] Owned column definitions.
---@field columnLayouts ArcaneWizardLibraryTableColumnLayout[] Calculated column positions.
---@field layoutWidth? number Width used by the latest layout.
---@field tableMenu? DropdownButton Optional table menu button.
---@field GetContentWidth fun(self: ArcaneWizardLibraryTable): number
---@field GetColumnLayout fun(self: ArcaneWizardLibraryTable, index: number): number, number, string
---@field SetColumnText fun(self: ArcaneWizardLibraryTable, index: number, text: string)
