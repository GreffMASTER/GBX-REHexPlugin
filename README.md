# GBX-REHexPlugin
A REHex plugin for the .Gbx (GameBox) file format.  

# WARNING! Currently only working on Linux, the Windows version of REHex uses a different version of Lua, which doesn't have bit32 library. What the f***!
  
# About
This plugin will automaticall detect if a Gbx file was loaded and will offer to analyze it for you.  
  
It will make comments for:
- Version
- Body compression, type, etc.
- Class ID
- User data (chunk entries and chunk data)
- Reference table (with nested folder comments)
- Mark every node terminator (0xfacade01) in the body (if decompressed).
  
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
