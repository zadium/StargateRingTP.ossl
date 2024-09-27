## Opensource Stargate ring teleporter ##

Ground ring to teleport multiple avatars without sitting (Stargate name is in description), to another position in the same region or another region via notecard "Targets"

You can use as landing point, it show rings for forign avatar comming to the grid.

Idea is based Stargate Movie, and "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009" (just an Idea)

I built it from scratch the code and the mesh too, with better solution, I used sensor to catch avatars, then rezzing a ring and send a message to that ring to teleport one avatar to the new position.

Works in one region by adding multiple gates, it is auto detect other gates by names,
for cross regions, add a notecard inside "Targets" use the same url in Firestorm viewer like, for fun make sure region positions you have stargate there at same point stargate will show rings too when someone landing.

Target notecard
```
    myname=hop://hg.mygrid.com:8000/My Region/128/64/25
    hop://hg.mygrid.com:8000/My Region/128/64/25
    hg.mygrid.com:8000/My Region/128/64/25
    /My Region/128/64/25
    ./My Region/128/64/25
    /./128/64/25
    ./128/64/25
    #hg.mygrid.com:8000/My Region/128/64/25     it is commented
```

**Do not** use simicolone : for region links seperator

    hg.mygrid.com:8000:My Region/128/64/25  is wrong

If url name have name as description it ignore the url line

Some of grids dose not allow hyper teleport (osTeleportAgent) or between regions or just for parcel owner, you can ask your admin to enabled it for you.

### Setup ###

Easy, rez it , change the description for name it, after rezzing all rings, click `Refresh` in menu, enjoy.
You need refresh button only at then end of setup, or after renaming it in description.

### Buildup ###

From Belnder export Stargate, InternalRing in one export file Stargate.dae

Steps

* Import dae files, import Chevrons.png as texture

* Import GateSound.wav, RingSound.wav

* Rez `Stargate`, ensure the external ring as root object (relink if needed), that have scripts, set physic shape to `Prim`, upload Gate.lsl into it, set chevrons face to Chevrons texture.

* Name internal ring `InternalRing`, script need it to rotate, ensure it linked to the root, set Phsyic shape to `none`.

* Put GateSound.wav in `Stargate`

* Color it as you like

* Rez `Ring`, set it to `Phantom`, make it glow 0.2 and alpha 70, color #b2e2e2

* Put RingSound.wav in `Ring`

* Take/Copy Ring prim to inventory, copy it into Stargate, name it `Ring`

* Create notecard inside Stargate, name it `Targets`

### License ###

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.en)

### Open source ###

The source is on github with blender files and textures.

https://github.com/zadium/StargateRingTP

### Code Syntax ###

I use /**  or  //*  as documentation comment, normal comment is not a documentation, my miniedit highlight it correctly.

### Thanks ###

Many THANKs to my Blender teacher "Modee Parlez"
