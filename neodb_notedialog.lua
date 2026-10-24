-- A title and a long note in one composer. MultiInputDialog handles focus and
-- keyboards, but its fields grow to their initial text height. Bound the title
-- to one line and give the scrollable body the remaining screen space instead.
local Device = require("device")
local InputDialog = require("ui/widget/inputdialog")
local MultiInputDialog = require("ui/widget/multiinputdialog")
local UIManager = require("ui/uimanager")
local _ = require("neodb_i18n")

local NoteDialog = MultiInputDialog:extend{
    focused_field_idx = 2,
    is_movable = false,
}

function NoteDialog:init()
    self.fields = self.fields or {
        { text = self.note_title or "", hint = _("Title (optional)") },
        { text = self.note_text or "", hint = self.note_hint or _("Note text"), allow_newline = true },
    }
    self._building_fields = true
    MultiInputDialog.init(self)
    self._building_fields = false
    -- Enter in the title moves to the body; it never submits the post.
    self.input_fields[1].enter_callback = function()
        self:onSwitchFocus(self.input_fields[2])
    end
    self:resizeFields()
end

function NoteDialog:getNoteTitle()
    return (self.input_fields[1]:getText():gsub("[\r\n]+", " "))
end

function NoteDialog:getNoteText()
    return self.input_fields[2]:getText()
end

function NoteDialog:setNoteText(text)
    local body = self.input_fields[2]
    body.charpos = nil
    body.top_line_num = nil
    body.cursor_at_end = true
    body:setText(text)
    UIManager:setDirty(self, "ui")
end

function NoteDialog:resizeFields()
    if self._building_fields or self._switching_focus then return end
    local group = self.dialog_frame[1]
    local title, body = self.input_fields[1], self.input_fields[2]
    local rows = {}
    for _, row in ipairs(group) do
        if row[1] == title or row[1] == body then rows[row[1]] = row end
    end
    local function resize(field, height)
        if field.height ~= height then
            field:resyncPos()
            field.height = height
            field.scroll = true
            field:initTextBox()
            field:initEventListener()
        end
        rows[field].dimen.h = field:getSize().h
    end
    resize(title, title:getLineHeight())
    group:resetLayout()
    local keyboard_height = self.keyboard_visible and self._input_widget:getKeyboardDimen().h or 0
    local available = Device.screen:getHeight() - keyboard_height
    local overhead = self.dialog_frame:getSize().h - body.height
    local line_height = body:getLineHeight()
    resize(body, math.max(line_height, math.floor((available - overhead) / line_height) * line_height))
    group:resetLayout()
    self[1].dimen.h = available
    UIManager:setDirty("all", "ui")
end

function NoteDialog:onShowKeyboard(...)
    InputDialog.onShowKeyboard(self, ...)
    self:resizeFields()
end

function NoteDialog:onCloseKeyboard()
    InputDialog.onCloseKeyboard(self)
    self:resizeFields()
end

function NoteDialog:onSwitchFocus(field)
    if field == self._input_widget then
        -- Tapping the active field must not reset its cursor or scroll position.
        self:onShowKeyboard()
        return
    end
    self._switching_focus = true
    MultiInputDialog.onSwitchFocus(self, field)
    self._switching_focus = false
    self:resizeFields()
end

return NoteDialog
