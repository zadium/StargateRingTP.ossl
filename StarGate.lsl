/**
    @name: StarGate
    @description:

    @author: Zai Dium
    @updated: "2024-09-24 15:46:03"
    @revision: 588
    @version: 3.58
    @localfile: ?defaultpath\Stargate\?@name.lsl
    @license: MIT

    @ref:
        https://www.101soundboards.com/boards/33269-stargate-sg1-soundboard

    @notice: Based on idea Stargate Movie, and "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
integer channel_private_number = 1;
integer ring_channel = 100;

string InternalRingName = "InternalRing";
string notecardName = "Targets";
//integer owner_only = TRUE;
string soundName = "GateSound";
integer channel_number = 0; //* Set it to 0 to autogenerate it depends on group key

string defaultSound = "289b4a8d-5a9a-4cc3-8077-3d3e5b08bb8c";
//string ring_start_sound = " ddb8a14d-624a-4da2-861c-8feedd9c9195"; //*
//*

integer version = 310; //* version

string hyperPrefix=">";

integer glow_face = 0;

integer ring_count = 5; //* amount of rings to rez and teleport
float ring_total_time = 5; //*seconds
float ring_idle_time = 3; //*seconds

list menu_list = [ "<--", "Refresh", "-->" ]; //* general navigation

float sensor_range = 2;//* we change in entry, depend on size of prim
key soundid;

list targets_type_list = []; //* gates list types lm, gate, region, lm is not working yet
list targets_list = []; //* gate rings keys list
list targets_pos_list = []; //* gate rings keys list
list targets_name_list = []; //* gate rings list

list avatars_list = []; //* hold temp list of avatar keys for teleporting
integer dest_index = -1; //* selected dest object index

integer dialog_channel = -1;
integer dialog_listen_id; //* dynamicly generated menu channel
integer cur_page; //* current menu page

list regionAgents;

key notecardQueryId;
integer notecardLine;

readNotecard()
{
    if (llGetInventoryKey(notecardName) != NULL_KEY)
    {
        notecardLine = 0;
        notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
    }
}

list getMenu(integer page)
{
    //llOwnerSay("page " + (string)page);
    //listList(targets_name_list);
    integer length = llGetListLength(targets_name_list);
    if (length >= 9)
    {
        integer x = page * 9;
        return menu_list + llList2List(targets_name_list, x , x + 8);
    }
    else {
        return menu_list + targets_name_list;
    }
}

showDialog(key toucher_id)
{
    dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
    llDialog(toucher_id, "Ring Gate", getMenu(cur_page), dialog_channel);
    llListenRemove(dialog_listen_id);
    dialog_listen_id = llListen(dialog_channel, "", toucher_id, "");
}

messageTo(key id, string cmd, list params)
{
    integer len = llGetListLength(params);
    integer i;
    for( i = 0; i < len; i++ )
    {
        cmd = cmd + ";" + llList2String(params, i);
    }
    llRegionSayTo(id, ring_channel, cmd);
}

sendCommandTo(key id, string cmd, list params)
{
    integer len = llGetListLength(params);
    integer i;
    for( i = 0; i < len; i++ )
    {
        cmd = cmd + ";" + llList2String(params, i);
    }
    if (id == NULL_KEY)
        llRegionSay(channel_number, cmd);
    else
        llRegionSayTo(id, channel_number, cmd);
}

sendCommand(string cmd, list params)
{
    sendCommandTo(NULL_KEY, cmd, params);
}

//* case sensitive
sound(){
    llTriggerSound(soundid, 1.0);
}

integer nInternalRing = -1;
integer started = FALSE;

teleport(key ring_id, key agent)
{
    //* only send message to ring (that have number>0) others are temp
    string target;
    string type = llList2String(targets_type_list, dest_index);
    if (type == "lm" || type == "region")
        target = llList2Key(targets_list, dest_index);
    else //* gate
        target = ""; //llGetRegionName();
    //llOwnerSay("teleport "+(string)ring_id+" "+(string)agent);
    if (agent != NULL_KEY)
    {
        vector lookAt = llList2Vector(llGetObjectDetails(agent, [OBJECT_ROT]), 0);
        vector pos = llList2Vector(targets_pos_list, dest_index) + <0,0,0.8>;
        pos = pos + llList2Vector(llGetObjectDetails(agent, [OBJECT_POS]), 0) - llGetRootPosition();
        messageTo(ring_id, "teleport", [(string)agent, type, target, (string)pos , (string)lookAt]); //* send mesage to incoming
    }
}

vector old_face_color;

endEffects()
{
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_OMEGA, <0, 0, 0>, PI, 1.0]);
    //* we need this trick to reset rotation
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_ROTATION, llEuler2Rot(<0, 0, -180 * DEG_TO_RAD>)]); //* forces to take action for next line
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_ROTATION, llEuler2Rot(<0, 0, 0>)]);
    llSetPrimitiveParams([PRIM_COLOR, glow_face, old_face_color, 1, PRIM_GLOW, glow_face, 0.00, PRIM_FULLBRIGHT, glow_face, FALSE]); //* deactivate glow
}

finish()
{
    //dest_index = -1; nop
    started = FALSE;
    endEffects();
    llSetTimerEvent(ring_idle_time);
}

startEffects()
{
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_OMEGA, llRot2Up(llGetLocalRot()), PI, 1.0]);
    old_face_color = llGetColor(glow_face);
    llSetPrimitiveParams([PRIM_COLOR, glow_face, <255, 255, 255>, 1, PRIM_GLOW, glow_face, 0.20, PRIM_FULLBRIGHT, glow_face, TRUE]); //* glow face
}

start(integer agents_count)
{
    started = TRUE;
    startEffects();
    sound();
    vector pos = llGetPos() - <0,0,0.1>;
    integer ringNumber;
    for (ringNumber = 1; ringNumber <= ring_count; ringNumber++)
    {
        llSleep(ring_total_time / 10);
        integer n;
        if (ringNumber > agents_count)
            n = -ringNumber;
        else
            n = ringNumber;
        llRezObject("Ring", pos, ZERO_VECTOR, ZERO_ROTATION, n);
    }
    llSetTimerEvent(ring_total_time);
}

clear(){
    targets_list = [];
    targets_type_list = [];
    targets_pos_list = [];
    targets_name_list = [];
}

clearGates()
{
    integer c = llGetListLength(targets_list);
    integer i = 0;
    while (i<c)
    {
        if (llList2String(targets_type_list, i) == "gate")
        {
            targets_list = llDeleteSubList(targets_list, i, i);
            targets_type_list = llDeleteSubList(targets_type_list, i, i);
            targets_pos_list = llDeleteSubList(targets_pos_list, i, i);
            targets_name_list = llDeleteSubList(targets_name_list, i, i);
        }
        else
            i++;
    }
}

update(){
    if (channel_number == 0)
    {
        key id = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_GROUP]),0);
        channel_number = (((integer)("0x"+llGetSubString((string)id,-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + channel_private_number;
    }
    llListen(channel_number, "", NULL_KEY, "");
    clear();
    readNotecard();
    //* when finish read notecard we send to other gates
}

addGate(key id)
{
    if (llListFindList(targets_list,[id]) == -1)
    {
        targets_list += id; //* add ring to list
        targets_type_list +=  "gate";
        targets_pos_list +=llList2Vector(llGetObjectDetails(id, [OBJECT_POS]), 0);

        string name = llList2String(llGetObjectDetails(id,[OBJECT_DESC]), 0);
        if (name == "")
            name = llList2String(llGetObjectDetails(id,[OBJECT_NAME]), 0);
        if (name == "")
            llOwnerSay("This id have no name: " + (string)id);

        targets_name_list += name;
    }
}

default
{
    state_entry()
    {
        old_face_color = llGetColor(glow_face);

        soundid = llGetInventoryKey(soundName);
        if (soundid == NULL_KEY)
            soundid = defaultSound;

        list box = llGetBoundingBox(llGetKey());
        vector size = llList2Vector(box, 1) - llList2Vector(box, 0);
        sensor_range = ((size.x + size.y) / 2) / 2; //* avarage / 2

        nInternalRing = osGetLinkNumber(InternalRingName); //* We will use the root if Internal Ring name not set
        /*if (!nInternalRing)
            llOwnerSay("Could not find InternalRing");*/
        llSetLinkPrimitiveParams(nInternalRing, [PRIM_OMEGA, <0, 0, 0>, 0, 1.0]);
        update();
        regionAgents = llGetAgentList(AGENT_LIST_REGION, []);
        llSetTimerEvent(ring_idle_time);
    }

    on_rez(integer start_param )
    {
        llResetScript();
    }

    changed(integer change)
    {
        if ((change & CHANGED_REGION_START) || (change & CHANGED_OWNER)) {
            llResetScript();
        }
        else if (change & CHANGED_INVENTORY)
        {
            update();
            finish();
        }
    }

    touch_start(integer num_detected)
    {
        if (!started)
            showDialog(llDetectedKey(0));
    }

    sensor( integer number_detected )
    {
        if (number_detected > 0)
        {
            integer i;
            avatars_list = [];
            for( i = 0; i < number_detected; i++ ){
                key k = llDetectedKey(i);
                avatars_list += k;
            }

            if (llList2String(targets_type_list, dest_index) == "gate")
                sendCommandTo(llList2Key(targets_list, dest_index), "activate", []); //* send mesage to incoming
            start(number_detected);
        }
        else
            llSay(0, "Nothing to teleport");
    }

    no_sensor()
    {
        finish();
        llSay(0, "Nothing to teleport");
    }

    object_rez(key id)
    {
        if (dest_index>=0)
        {
            if (llGetListLength(avatars_list)>0)
            {
                key agent = llList2Key(avatars_list, 0);
                avatars_list = llDeleteSubList(avatars_list, 0, 0);
                teleport(id, agent);
            }
        }
    }

    timer()
    {
        if (started)
        {
            //*TODO: only local
            llPlaySound("d7a9a565-a013-2a69-797d-5332baa1a947", 1);
            finish();
        }
        else
        {
            regionAgents = llGetAgentList(AGENT_LIST_REGION, []);
        }
    }

    collision_start( integer num_detected )
    {
        if (!started)
        {
            key agent = llDetectedKey(0);
            if ((agent != NULL_KEY) && (llGetOwnerKey(agent) == agent)) //* is an avatar
            {
                if (llListFindList(regionAgents, [agent])<0)
                {
                    regionAgents = llGetAgentList(AGENT_LIST_REGION, []);
                    start(0);
                }
            }
        }
    }

    dataserver( key queryid, string data )
    {
        if (queryid == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
                notecardQueryId = NULL_KEY;
                integer c = llGetInventoryNumber(INVENTORY_LANDMARK);
                integer i = 0;
                string name;
                while (i<c)
                {
                    name = llGetInventoryName(INVENTORY_LANDMARK, i);
                    if (llToLower(name) != llToLower(llGetObjectDesc()))
                    {
                        targets_name_list += "*" + name;
                        targets_type_list += "lm";
                        targets_list += name; //llGetInventoryKey(name);
                        targets_pos_list += ZERO_VECTOR;
                    }
                    i++;
                }
                sendCommand("update", [version]);
            }
            else
            {
                if ((data!="") && (llToLower(llGetSubString(data, 0, 0)) != "#"))
                {
                    string name = "";
                    string domain;
                    string region;

                    vector pos;

                    integer p = llSubStringIndex(data, "=");
                    if (p>=0) {
                        name = llGetSubString(data, 0, p - 1);
                        data = llGetSubString(data, p + 1, -1);
                    }

                    if (llToLower(llGetSubString(data, 0, 5)) == "hop://")
                    {
                        data = llGetSubString(data, 6, -1); //* remove hop
                    }

                    p = llSubStringIndex(data, "/");
                    if (p==0) {
                        domain = "";
                        data = llGetSubString(data, p + 1, -1); //* remove /
                    }
                    else if (p>0) {
                        domain = llGetSubString(data, 0, p - 1); //* domain name
                        data = llGetSubString(data, p + 1, -1); //* remove domain name
                    }
                    else
                        domain = "";
                    p = llSubStringIndex(data, "/");
                    if (p>=0)
                    {
                        if (domain == ".")
                            region = ".";
                        else
                        {
                            region = llGetSubString(data, 0, p - 1); //* remove position/coordinates
                            data = llGetSubString(data, p + 1, - 1); //* position/coordinates
                        }

                        p = llSubStringIndex(data, "/");
                        pos.x = (float)llGetSubString(data, 0, p - 1);
                        data = llGetSubString(data, p + 1, -1);
                        if (data != "")
                        {
                            p = llSubStringIndex(data, "/");
                            pos.y = (float)llGetSubString(data, 0, p - 1);
                            data = llGetSubString(data, p + 1, -1);
                            if (data != "")
                            {
                                p = llSubStringIndex(data, "/");
                                if (p>=0)
                                    pos.z = (float)llGetSubString(data, 0, p - 1);
                                else
                                    pos.z = (float)data;
                            }
                        }
                    }
                    else {
                        region = data;
                        data = "";
                        pos = <0, 0, 0>;
                    }

                    if (name == "")
                        name = region;

                    if (domain == ".")
                        domain = "";
                    if (domain != "")
                        region = domain+":"+region;
                    if (region == ".")
                        region = "";
                    //llOwnerSay("name="+ name + " region="+region+" pos="+(string)pos);
                    if ((name == "") || ((llToLower(name) != llToLower(llGetObjectDesc()))))
                    {
                        targets_list += region;
                        targets_pos_list += pos;
                        targets_name_list += hyperPrefix + name;
                        targets_type_list += "region";
                    }
                }
                ++notecardLine;
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }

    listen (integer channel, string name, key id, string message)
    {
        //llSay(0,(string)channel+":"+message);
        if (channel == channel_number)
        {
            list params = llParseStringKeepNulls(message,[";"],[""]);
            string cmd = llList2String(params, 0);
            params = llDeleteSubList(params, 0, 0);

            //* gates
            if (cmd == "add")
                addGate(id);
            else if (cmd == "update")
            {
                clearGates();
                addGate(id);
                sendCommand("add", [version]); //* send pong reply (ring sync)
            }
            else if (cmd == "activate")
            {
                if (id != llGetKey())
                { //*not self s
                    dest_index = -1;
                    start(0);
                }
            }
        }
        else if (channel == dialog_channel) //* Dialog
        {
            llListenRemove(dialog_listen_id);
            integer button_index = llListFindList(targets_name_list, [message]);

            if (message == "<--")
            {
                if (cur_page > 0)
                    cur_page -= 1;
                showDialog(id);
            }
            else if (message == "-->")
            {
                integer max_limit = (llGetListLength(targets_name_list)-1) / 9;
                if (cur_page < max_limit)
                    cur_page += 1;
                showDialog(id);
            }
            else if (message == "Refresh")
            {
                startEffects();
                update();
                finish();
            }
            else if (button_index != -1)
            {
                dest_index = button_index;
                //* ACTIVE | AGENT i used ACTIVE to detect tiny avatars, ada avatars
                llSensor("", NULL_KEY, ACTIVE | AGENT, sensor_range, PI);
            }
        }
    }
}

