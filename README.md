## Opensource Stargate ring teleporter ##

Ground ring to teleport multiple avatars (only 5) without sitting, to another position in the same region or another region via notecard "Targets"

Idea is based on "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"

I built it from scratch the code and the mesh too, with better solution, I used sensor to catch avatars, then rezzing a ring and send a message to that ring to teleport one avatar to the new position.

Works in one region by adding multiple gates, it is auto detect other gates by names,
for cross regions, add a notecard inside "Targets" use the same url in Firestorm viewer like

    hop://hg.mygrid.com:8000/My Region/128/64/25
    hg.mygrid.com:8000/My Region/128/64/25
    /My Region/128/64/25
    ./My Region/128/64/25
    /./128/64/25
    ./128/64/25
    #hg.mygrid.com:8000/My Region/128/64/25     it is commented

do not use simicolone : for region links seperator

    hg.mygrid.com:8000:My Region/128/64/25  wrong

Some of grid dose not allow hyper teleport or between regions, you can ask your admin to enabled it for you.

### Setup ###

Easy, rez it , change the description, after rezzing all rings, click `Refresh` in menu, enjoy.
You need refresh button only at then end of setup, or after renaming it in description.
If you like, put GateSound sound file in Gate prim for starting, and put RingSound file in Ring object inside the gate, or it use default sounds

### Buildup ###

From Belnder export Stargate, InternalRing in one export file Stargate.dae
export Ring to Ring.dae
export Hull to Hull.dae

You need

* Import dae files, import Chevrons.png as texture

* Import GateSound.wav, RingSound.wav

* Rez `Stargate`, ensure the external ring as root object (relink if needed), that have scripts, set physic shape to `Prim`, upload Gate.lsl into it, set chevrons face to Chevrons texture.

* Name internal ring `InternalRing`, script need it to rotate, ensure it linked to the root, set Phsyic shape to `none`.

* Put * GateSound.wav in `Stargate`

* Color it as you like

* Rez `Ring`, set it to `Phantom`, make it glow 0.2 and alpha 70, color #b2e2e2

* Put * RingSound.wav in `Ring`

* Take/Copy Ring prim to inventory, copy it into Stargate, name it `Ring`

* Create notecard inside Stargate, name it `Targets`

### License ###

https://opensource.org/licenses/MIT

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Open source ###

The source is on github with blender files and textures.

https://github.com/zadium/StargateRingTP

### Code Syntax ###

I use /**  or  //*  as documentation comment, normal comment is not a documentation, my miniedit highlight it correctly.

### Thanks ###

Many THANKs to my Blender teacher "Modee Parlez"
