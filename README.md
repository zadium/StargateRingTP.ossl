## Opensource Stargate ring teleporter ##

Ground ring to teleport multiple avatars (only 5) to another position in the same region oer another region

Idea is based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"

I rebuilt it from scratch the code and the mesh too, with better solution, I used sensor to catch avatars, rez a ring then send a message to that ring to teleport one avatar to the new position.

Works in one region by adding multiple gates, it is auto detect it by gate names
for cross regions, add a notecard with url of grids like

    /My Region/128/64/25
    hg.mygrid.com:8000/My Region/128/64/25
    hop://hg.mygrid.com:8000/My Region/128/64/25
    #hg.mygrid.com:8000/My Region/128/64/25     it commented

do not use simicolone : for region links seperator

	hg.mygrid.com:8000:My Region/128/64/25  wrong

Some of grid do not allow hyper teleport or between regions, you can ask your admin to enabled it for you.

### Setup ###

Easty, rez it , change the description, after rezzing all rings, click `Refresh` in menu, enjoy.
You need refresh button only at then end of setup, or after renaming it in description.
If you like, put GateSound sound file in Gate prim for starting, and put RingSound file in Ring object inside the gate, or it use default sounds

### Buildup ###

You need

* External Ring, as root object that have script
* Internal Ring, name it as "InternalRing" to rotate it linked to the root
* Ring inside inventory of External ring, with name "Ring"

### License ###

https://opensource.org/licenses/MIT

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Open source ###

The source is on github with blender files and textures.

https://github.com/zaher/StargateRingTP

### Code Syntax ###

I use /**  or  //*  as documentation comment, normal comment is not a documentation, my miniedit highlight it correctly.

### Thanks ###

Many THANKs to my Blender teacher "Modee Parlez"
