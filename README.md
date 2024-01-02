# GBX-REHexPlugin
A REHex plugin for the .Gbx (GameBox) file format.  
  
This plugin will automaticall detect if a Gbx file was loaded and will offer to analyse it for you.  
  
It will make comments for:
- Version
- Body compression, type, etc.
- Class ID
- User data (chunk entries and chunk data)
- Reference table (with nested folder comments)
- Mark every node terminator (0xfacade01) in the body (if decompressed).

## License
The GBX-REHexPlugin is licensed under the MIT License, you can find it [here](https://github.com/GreffMASTER/GBX-REHexPlugin/blob/main/LICENSE).
