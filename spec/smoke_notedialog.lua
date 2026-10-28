-- Optional smoke test with real KOReader widgets; see dev_notes.md. No network requests.
require("setupkoenv")
local plugin_dir = assert(os.getenv("NEODB_PLUGIN_DIR"), "Set NEODB_PLUGIN_DIR to the checkout")
assert(os.getenv("KO_HOME") == os.getenv("NEODB_UI_TEST_DIR"), "Use an isolated NEODB_UI_TEST_DIR as KO_HOME")
package.path = plugin_dir .. "/?.lua;" .. package.path
local language = os.getenv("NEODB_UI_LANGUAGE") or "C"
G_defaults = require("luadefaults"):open()
G_reader_settings = require("luasettings"):open(os.getenv("KO_HOME") .. "/settings.reader.lua")
G_reader_settings:saveSetting("language", language)
G_reader_settings:saveSetting("virtual_keyboard_enabled", true)
require("gettext").changeLang(language)
require("ui/bidi").setup(language)
local Device = require("device")
require("document/canvascontext"):init(Device)
local UIManager = require("ui/uimanager")
local Actions = require("neodb_actions")
local Store = require("neodb_store")
local Util = require("neodb_util")
local tr = require("neodb_i18n")
local store = Store:new()
store:setInstance("https://example.org")
store:setToken("preview-only")
local settings = require("luasettings"):open(os.getenv("KO_HOME") .. "/book.lua")
store:setLink(settings, { uuid = "preview", title = "Dune" })
local ui = {
    doc_settings = settings,
    document = { file = "preview.epub", getPageCount = function() return 100 end },
    getCurrentPage = function() return 48 end,
    toc = { getTocTitleByPage = function() return "Chapter One" end },
}
store:set("note_title_style", "none")
store:set("quote_intro_style", "none")
store:set("selection_crosspost", false)
store:set("quote_position", "after")
store:set("note_attach_progress", true)
store:set("note_save_local", true)
local NoteDialog = require("neodb_notedialog")
local function open()
    Actions.addNote({store = store, ui = ui}, {quote = "Selected passage", note = "Original note", save_note = function() error("No submit") end})
    for _, window in ipairs(UIManager._window_stack) do
        if window.widget.title == tr("Add note & share") then return window.widget end
    end
    error("Missing composer")
end
local background = require("ui/widget/container/widgetcontainer"):new{}
function background:paintTo(bb) bb:fill(require("ffi/blitbuffer").COLOR_WHITE) end
UIManager:show(background)
local dialog = open()
assert(dialog:getNoteTitle() == "")
assert(dialog.button_table:getButtonById("fediverse").text == tr("Crosspost: off"))
dialog.input_fields[1]:setText("My title")
dialog.input_fields[2]:setText("Long draft\n" .. string.rep("A passage to keep.\n", 40))
local body = dialog:getNoteText()
dialog:onSwitchFocus(dialog.input_fields[1])
dialog:onSwitchFocus(dialog.input_fields[2])
dialog:onCloseKeyboard()
dialog:onShowKeyboard()
assert(dialog:getNoteTitle() == "My title" and dialog:getNoteText() == body)
UIManager:_repaint()
Device.screen.bb:writePNG(os.getenv("KO_HOME") .. "/review-normal.png")
local dirty, all_count = UIManager.setDirty, 0
UIManager.setDirty = function(self, widget, ...)
    if widget == "all" then all_count = all_count + 1 end
    return dirty(self, widget, ...)
end
dialog:resizeFields()
assert(all_count == 0, "unchanged layout must not dirty all widgets")
UIManager.setDirty = dirty
-- Simulate KOReader changing an internal API while editing.
dialog.resizeFieldsUnsafe = function() error("simulated incompatible widget API") end
dialog:resizeFields()
assert(dialog._fallback)
assert(dialog:getNoteTitle() == "My title" and dialog:getNoteText() == body)
dialog:setNoteText("Fallback edited body")
assert(dialog:getNoteText() == "Fallback edited body")
dialog:onShowKeyboard()
UIManager:_repaint()
Device.screen.bb:writePNG(os.getenv("KO_HOME") .. "/review-fallback.png")
dialog:onKeyboardHeightChanged()
assert(dialog:getNoteTitle() == "My title" and dialog:getNoteText() == "Fallback edited body")
dialog.button_table:getButtonById("quote_position").callback()
assert(dialog.button_table:getButtonById("quote_position").text == tr("Quote: above note"))
dialog.button_table:getButtonById("edit_title").callback()
local title_editor
for _, window in ipairs(UIManager._window_stack) do
    if window.widget.title == tr("Title (optional)") then title_editor = window.widget end
end
assert(title_editor)
title_editor:setInputText("Fallback title")
title_editor.buttons[1][2].callback()
assert(dialog:getNoteTitle() == "Fallback title")
UIManager:close(dialog)
assert(#UIManager._window_stack == 1 and UIManager._window_stack[1].widget == background,
    "Closing composer must not leave an orphan keyboard")
-- Also exercise incompatibility on the first initialization.
local resize = NoteDialog.resizeFieldsUnsafe
NoteDialog.resizeFieldsUnsafe = function() error("simulated missing layout") end
dialog = open()
assert(dialog._fallback and dialog:getNoteText() == "Original note")
UIManager:close(dialog)
assert(#UIManager._window_stack == 1 and UIManager._window_stack[1].widget == background,
    "Closing composer must not leave an orphan keyboard")
NoteDialog.resizeFieldsUnsafe = resize
print("Review UI and fallback checks passed: " .. language)
