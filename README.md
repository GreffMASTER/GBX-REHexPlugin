# GBX-REHexPlugin
A REHex plugin for the .Gbx (GameBox) file format.  
  
# About
This plugin will automaticall detect if a Gbx file was loaded and will offer to analyze it for you.  
  
It will make comments for:
- Version
- Body compression, type, etc.
- Class ID
- User data (chunk headers and chunk data)
- Reference table (with nested folder comments)
- Mark every node terminator (0xfacade01) in the body (if decompressed).

## How to use
Using the plugin is super simple.  
If you open a GBX file, the plugin will automatically detect it and offer to analyse it for you.  
Alternatively, you can use the `Analyse GBX` option in the `Tools` menu.  
The plugin will go through the file and make comments in important sections.  
(Warning: large files might freeze the program for a while and it would look like the editor is not responding, but it's actually taking a long time to find node terminators.)  
  
You can change some settings in the `gbx/plugin.lua` file.  
  
## How to install
Copy the `gbx` folder to your REHex `plugins` folder.  
You can find it in:
> ``` 
>   Windows
>       The Plugins folder alongside rehex.exe
>   Linux
>       ${XDG_DATA_HOME}/rehex/plugins/ (usually ~/.local/share/rehex/plugins/)
>       ${LIBDIR}/rehex/ (usually /usr/lib/rehex/
>   macOS
>       The Contents/PlugIns directory in the application bundle.
>```
(Quote from [https://solemnwarning.net/rehex/manual/plugins.html](https://solemnwarning.net/rehex/manual/plugins.html).)

## License
The GBX-REHexPlugin is licensed under the MIT License, you can find it [here](https://github.com/GreffMASTER/GBX-REHexPlugin/blob/main/LICENSE).
