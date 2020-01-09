-- Licensed under the MIT License
-- Copyright (c) 2020, randazzo <https://github.com/randazz0>

local imgui, ffi, ini = require 'mimgui', require 'ffi', require 'inicfg'

local ImStyleSerializer = {}
local _styles = {}
ImStyleSerializer.__preparetoapply = false

local _ImGuiStyle =
{
    'Alpha',                      -- Global alpha applies to everything in Dear ImGui.
    'WindowPadding',              -- Padding within a window.
    'WindowRounding',             -- Radius of window corners rounding. Set to 0.0f to have rectangular windows.
    'WindowBorderSize',           -- Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    'WindowMinSize',              -- Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().
    'WindowTitleAlign',           -- Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.
    'WindowMenuButtonPosition',   -- Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left.
    'ChildRounding',              -- Radius of child window corners rounding. Set to 0.0f to have rectangular windows.
    'ChildBorderSize',            -- Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    'PopupRounding',              -- Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)
    'PopupBorderSize',            -- Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    'FramePadding',               -- Padding within a framed rectangle (used by most widgets).
    'FrameRounding',              -- Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).
    'FrameBorderSize',            -- Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    'ItemSpacing',                -- Horizontal and vertical spacing between widgets/lines.
    'ItemInnerSpacing',           -- Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).
    'TouchExtraPadding',          -- Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!
    'IndentSpacing',              -- Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).
    'ColumnsMinSpacing',          -- Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1).
    'ScrollbarSize',              -- Width of the vertical scrollbar, Height of the horizontal scrollbar.
    'ScrollbarRounding',          -- Radius of grab corners for scrollbar.
    'GrabMinSize',                -- Minimum width/height of a grab box for slider/scrollbar.
    'GrabRounding',               -- Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.
    'TabRounding',                -- Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.
    'TabBorderSize',              -- Thickness of border around tabs.
    'ColorButtonPosition',        -- Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.
    'ButtonTextAlign',            -- Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered).
    'SelectableTextAlign',        -- Alignment of selectable text when selectable is larger than text. Defaults to (0.0f, 0.0f) (top-left aligned).
    'DisplayWindowPadding',       -- Window position are clamped to be visible within the display area by at least this amount. Only applies to regular windows.
    'DisplaySafeAreaPadding',     -- If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!
    'MouseCursorScale',           -- Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later.
    'AntiAliasedLines',           -- Enable anti-aliasing on lines/borders. Disable if you are really tight on CPU/GPU.
    'AntiAliasedFill',            -- Enable anti-aliasing on filled shapes (rounded rectangles, circles, etc.)
    'CurveTessellationTol',       -- Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.
    'Colors'

};

local _ImGuiCol =
{
    'Text',
    'TextDisabled',
    'WindowBg',              -- Background of normal windows
    'ChildBg',               -- Background of child windows
    'PopupBg',               -- Background of popups, menus, tooltips windows
    'Border',
    'BorderShadow',
    'FrameBg',               -- Background of checkbox, radio button, plot, slider, text input
    'FrameBgHovered',
    'FrameBgActive',
    'TitleBg',
    'TitleBgActive',
    'TitleBgCollapsed',
    'MenuBarBg',
    'ScrollbarBg',
    'ScrollbarGrab',
    'ScrollbarGrabHovered',
    'ScrollbarGrabActive',
    'CheckMark',
    'SliderGrab',
    'SliderGrabActive',
    'Button',
    'ButtonHovered',
    'ButtonActive',
    'Header',                -- Header* colors are used for CollapsingHeader, TreeNode, Selectable, MenuItem
    'HeaderHovered',
    'HeaderActive',
    'Separator',
    'SeparatorHovered',
    'SeparatorActive',
    'ResizeGrip',
    'ResizeGripHovered',
    'ResizeGripActive',
    'Tab',
    'TabHovered',
    'TabActive',
    'TabUnfocused',
    'TabUnfocusedActive',
    'PlotLines',
    'PlotLinesHovered',
    'PlotHistogram',
    'PlotHistogramHovered',
    'TextSelectedBg',
    'DragDropTarget',
    'NavHighlight',          -- Gamepad/keyboard: current highlighted item
    'NavWindowingHighlight', -- Highlight window when using CTRL+TAB
    'NavWindowingDimBg',     -- Darken/colorize entire screen behind the CTRL+TAB window list, when active
    'ModalWindowDimBg'      -- Darken/colorize entire screen behind a modal window, when one is active
};

local function split(str, delim, plain)
    local lines, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
      local npos, epos = string.find(str, delim, pos, plain)
      table.insert(lines, string.sub(str, pos, npos and npos - 1))
      pos = epos and epos + 1
    until not pos
    return lines
end

function ImStyleSerializer.getStyles()
    local tmp = {}
    for k in pairs(_styles) do table.insert( tmp, k ); ImStyleSerializer.__preparetoapply = true end
    return ImStyleSerializer.__preparetoapply and tmp or {"No styles"}
end

function ImStyleSerializer.applyStyle(style, stylename)
    imgui.SwitchContext()
    if ImStyleSerializer.__preparetoapply and _styles[stylename] then
        for _,v in pairs(_ImGuiStyle) do
            if v == 'Colors' then
                for k, d in pairs(_ImGuiCol) do
                    style[v][k-1] = imgui.ColorConvertU32ToFloat4(tonumber(bit.tohex(_styles[stylename][d]), 16))
                end
                break
            end
            if tostring(_styles[stylename][v]):find("(%d+) (%d+)") then
                local n = split(_styles[stylename][v], " ")
                style[v] = imgui.ImVec2(tonumber(n[1]), tonumber(n[2]))
            elseif tonumber(_styles[stylename][v]) then
                style[v] = tonumber(_styles[stylename][v])
            end
        end
        return true
    end
    return false
end

function ImStyleSerializer.loadStyles( filename )
    if doesFileExist(getWorkingDirectory()..'\\config\\'..filename) then
        ImStyleSerializer.__preparetoapply = ini.load(_styles, '..\\config\\'..filename) and true or false
        return ImStyleSerializer.__preparetoapply
    end
    return false
end

function ImStyleSerializer.saveStyles( style, stylename, filename )
    _styles[stylename] = {}
    for _, v in pairs(_ImGuiStyle) do
        if v == 'Colors' then
            for k, d in pairs(_ImGuiCol) do
                _styles[stylename][d] = "0x"..bit.tohex(imgui.ColorConvertFloat4ToU32(style[v][k-1]))
            end
            break
        end
        _styles[stylename][v] = type(style[v]) == 'cdata' and (style[v].x.." "..style[v].y) or style[v]
    end
    return ini.save(_styles, '..\\config\\'..filename) and true or false
end

return ImStyleSerializer
