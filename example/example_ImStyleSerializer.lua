local iss = require 'ImStyleSerializer'

local ffi = require "ffi"
local imgui = require "mimgui"

showWindow = imgui.new.bool(false)
textBuffer = imgui.new.char[256]("Style name")
styles = {}

function main()
    while true do wait(0)
        if wasKeyPressed(0x33) then -- VK_3
            showWindow[0] = not showWindow[0]
        end
    end
end

imgui.OnFrame(function() return showWindow[0] end,
function()
    imgui.Begin("Example of usage ImStyleSerializer", showWindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize)
    imgui.InputText('##styleName', textBuffer, ffi.sizeof(textBuffer) - 1) imgui.SameLine()
    if imgui.Button("Save style") then
        iss.saveStyles(imgui.GetStyle(), ffi.string(textBuffer), "imguistyles.ini")
        styles = iss.getStyles()
        stylesArray = imgui.new['const char*'][#styles](styles)
    end
    if styleStatus then
        if imgui.Combo('Select style', styleSelected, stylesArray, #styles) then
            iss.applyStyle(imgui.GetStyle(), styles[styleSelected[0] + 1])
        end
        imgui.Separator()
        imgui.ShowStyleEditor()
    end
end)

imgui.OnInitialize(function()
    if not doesFileExist(getWorkingDirectory()..'\\config\\imguistyles.ini') then iss.saveStyles(imgui.GetStyle(), "Dark", "imguistyles.ini") end
    styleStatus = iss.loadStyles("imguistyles.ini") 
    if styleStatus then
        styles = iss.getStyles()
        stylesArray = imgui.new['const char*'][#styles](styles)
        styleSelected = imgui.new.int(0)
    else print("Can't load styles")
    end
end)
