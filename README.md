# ImStyleSerializer-mimgui

Lua library for working(save, load) with imgui styles in mimgui.    
Dependencies: Moonloader >= `025`

### Structure of file(default - imguistyles.ini) with imgui styles.
  ```INI
  [Style name]
  Style_var = param
  ```

## Functions:
  ```lua
  ImStyleSerializer.getStyles() --return table with style names
  ImStyleSerializer.applyStyle(style, stylename) --apply style by stylename(example: ImStyleSerializer.applyStyle(imgui.GetStyle(), "Dark"))
  ImStyleSerializer.loadStyles( filename ) --load styles by filename (example: ImStyleSerializer.loadStyles( "imguistyles.ini" ))
  ImStyleSerializer.saveStyles( style, stylename, filename ) --save styles in file(example: ImStyleSerializer.saveStyles( imgui.GetStyle(), "Dark", "imguistyles.ini" ))
  ```
  
## Installation:
  Copy the file into the `moonloader/lib/` directory.
