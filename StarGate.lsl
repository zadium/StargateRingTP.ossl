/**
    @name: StarGate
    @description:

    @author: Zai Dium
    @updated: "2022-09-03 21:56:09"
    @revision: 263
    @version: 2.19
    @localfile: ?defaultpath\Stargate\?@name.lsl
    @license: MIT

    @ref:

    @notice: Based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
//integer owner_only = TRUE;
string soundName = "GateSound";
integer channel_number = 0; //* Set it to 0 to autogenerate it
key app_id = "9846c7bf-bf42-4ee3-9741-e3f7c16a864d";

string defaultSound = "289b4a8d-5a9a-4cc3-8077-3d3e5b08bb8c";
//string ring_start_sound = " ddb8a14d-624a-4da2-861c-8feedd9c9195"; //*
//*

integer version = 250; //*2.5

string hyperPrefix=">";

integer glow_face = 0;
integer ring_count = 5; //* amount of rings to rez and teleport
float ring_total_time = 5;
float sensor_range = 2;

list menu_list = [ "<--", "Refresh", "-->" ]; //* general navigation

key soundid;

list targets_list = []; //* gate rings keys list
list targets_pos_list = []; //* gate rings keys list
list targets_name_list = []; //* gate rings list

list avatars_list = []; //* hold temp list of avatar keys for teleporting
integer dest_index = -1; //* selected dest object index

integer dialog_channel = -1;
integer dialog_listen_id; //* dynamicly generated menu channel
integer cur_page; //* current menu page

key update_id;

vector old_face_color;

key notecardQueryId;
integer notecardLine;
string notecardName = "Regions";

sendUpdate()
{
    update_id = llGenerateKey();
    sendCommand("update", [update_id, version]);
}

readNotecard()
{
    if (llGetInventoryKey(notecardName) != NULL_KEY)
    {
        notecardLine = 0;
        notecardQueryId = llGetNotecardLine(notecardName, notecardLine);
    }
    else
    	sendUpdate();
}

listList(list l)
{
    integer len = llGetListLength(l);
    integer i;
    for( i = 0; i < len; i++ )
    {
        llOwnerSay((string)i + ": " +llList2String(l, i));
    }
    llOwnerSay("Total = " + (string)len);
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

showDialog(key toucher_id) {
    dialog_channel = -1 - (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
    llDialog(toucher_id, "Ring Gate", getMenu(cur_page), dialog_channel);
    llListenRemove(dialog_listen_id);
    dialog_listen_id = llListen(dialog_channel, "", toucher_id, "");
}

sendCommandTo(key id, string cmd, list params)
{
    integer len = llGetListLength(params);
    integer i;
    for( i = 0; i < len; i++ )
    {
        cmd = cmd + ";" + llList2String(params, i);
    }
    if (id)
        llRegionSayTo(id, channel_number, cmd);
    else
        llRegionSay(channel_number, cmd);
}

sendCommand(string cmd, list params)
{
    sendCommandTo(NULL_KEY, cmd, params);
}

sendLocalCommand(string cmd, list params)
{
    integer len = llGetListLength(params);
    integer i;
    for( i = 0; i < len; i++ )
    {
        cmd = cmd + ";" + llList2String(params, i);
    }
    llSay(channel_number, cmd);
}

//* case sensitive
integer getPrimNumber(string name)
{
    integer c = llGetNumberOfPrims();
    integer i = 1; //based on 1
    while(i <= c)
    {
        if (llGetLinkName(i) == name) // llGetLinkName based on 1
            return i;
        i++;
    }
    llOwnerSay("Could not find " + name);
    return -1;
}

sound(){
    llTriggerSound(soundid, 1.0);
}

integer nInternalRing = -1;
integer started = FALSE;

start(integer number_detected)
{
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_OMEGA, llRot2Up(llGetLocalRot()), PI, 1.0]);

    old_face_color = llGetColor(glow_face);
    started = TRUE;
    llSetColor(<255, 255, 255>, glow_face);
    llSetPrimitiveParams([PRIM_GLOW, glow_face, 0.20, PRIM_FULLBRIGHT, glow_face, TRUE]); //* glow face
    sound();
    vector pos = llGetPos() - <0,0,0.1>;
    integer ringNumber;
    for (ringNumber = 1; ringNumber <= ring_count; ringNumber++) {
        llSleep(ring_total_time / 10);
        integer n;
        if (ringNumber > number_detected)
            n = -ringNumber;
        else
            n = ringNumber;
        llRezObject("Ring", pos, ZERO_VECTOR, ZERO_ROTATION, n);
    }
    llSetTimerEvent(ring_total_time);
}

teleport(key id, integer index)
{
/*    if (index >= llGetListLength(avatars_list))
        llOwnerSay("out of index"); //* but we will send teleport command to make ring fall down
*/
    key agent = llList2Key(avatars_list, index - 1); //* -1 based on 0 while ring numbers is based on 1
    string region;
    key dest_id;
    if (llGetListEntryType(targets_list, dest_index) == TYPE_KEY)
        region = "";//llGetRegionName();
    else
        region = llList2Key(targets_list, dest_index);
    vector dest = llList2Vector(targets_pos_list, dest_index) + <0,0,0.8>;
    vector lookAt = llList2Vector(llGetObjectDetails(agent, [OBJECT_ROT]), 0);

    sendCommandTo(id, "teleport", [(string)(index) , region, (string)dest , (string)lookAt, (string)agent]); //* send mesage to incoming
}

finish()
{
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_OMEGA, <0, 0, 0>, PI, 1.0]);
    //* we need this trick to reset rotation
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_ROTATION, llEuler2Rot(<0, 0, -180 * DEG_TO_RAD>)]);
    llSetLinkPrimitiveParams(nInternalRing, [PRIM_ROTATION, llEuler2Rot(<0, 0, 0>)]);

    llSetLinkAlpha(2,1.0,ALL_SIDES); //* show main ring base
    if (started) {
        llSetColor(old_face_color, glow_face);
    }
    llSetPrimitiveParams([PRIM_GLOW, glow_face, 0.00, PRIM_FULLBRIGHT, glow_face, FALSE]); //* deactivate glow
    dest_index = -1;
    //avatars_list = []; nop
    started = FALSE;
}

clear(){
    targets_list = [];
    targets_pos_list = [];
    targets_name_list = [];
}

update(){
    clear();
    readNotecard();
    //* when finish read notecard we send to other gates
}

addGate(key id)
{
    if (llListFindList(targets_list,[id]) == -1)
    {
        targets_list += id; //* add ring to list
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
        vector size = llList2Vector(box, 1) * llGetRot() - llList2Vector(box, 0) * llGetRot();
        sensor_range = ((size.x + size.y) / 2) / 2; //* avarage / 2

        nInternalRing = getPrimNumber("InternalRing");
        if (!nInternalRing)
            llOwnerSay("Could not find InternalRing");
        llSetLinkPrimitiveParams(nInternalRing, [PRIM_OMEGA, <0, 0, 0>, 0, 1.0]);
        if (channel_number == 0)
            channel_number = (((integer)("0x" + llGetSubString((string)llGetOwner(), -8, -1)) & 0x3FFFFFFF) ^ (integer)("0x" + llGetSubString(app_id, -8, -1)));
        llListen(channel_number,"","","");
        update();
    }

    on_rez(integer start_param )
    {
        llResetScript();
    }

    changed (integer change)
    {
        if ((change & CHANGED_REGION_START) || (change & CHANGED_OWNER)) {
            llResetScript();
        }
    }

    touch_start(integer num_detected)
    {
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

            start(number_detected);
            if (llGetListEntryType(targets_list, dest_index) == TYPE_KEY)
                sendCommandTo(llList2Key(targets_list, dest_index), "activate", []); //* send mesage to incoming
            llSleep(ring_total_time / 2);
        }
        else
            llSay(0, "Nothing to teleport");
    }

    no_sensor(){
       finish();
    }

    timer()
    {
        llSetTimerEvent(0);
        finish();
    }

    object_rez(key id)
    {
         sendCommandTo(id, "setup", []);
    }

    dataserver( key queryid, string data )
    {
        if (queryid == notecardQueryId)
        {
            if (data == EOF) //Reached end of notecard (End Of File).
            {
                notecardQueryId = NULL_KEY;
                sendUpdate();
            }
            else
            {
                if (llToLower(llGetSubString(data, 0, 0)) != "#")
                {
                    string name = "";
                    string domain;
                    string region;

                    vector pos;

                    integer p = llSubStringIndex(data, "=");
                    if (p>=0) {
                        name = llGetSubString(data, 0, p - 1);
                        data = llGetSubString(data, p - 1, -1);
                    }

                    if (llToLower(llGetSubString(data, 0, 5)) == "hop://")
                        data = llGetSubString(data, 6, p - 1); //* remove hop

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
                        region = llGetSubString(data, 0, p - 1); //* remove position/coordinates
                        data = llGetSubString(data, p + 1, - 1); //* position/coordinates

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

                    if (domain != "")
                        region = domain+":"+region;
                    //llOwnerSay("name="+ name + " region="+region+" pos="+(string)pos);
                    targets_list += region;
                    targets_pos_list += pos;
                    targets_name_list += hyperPrefix + name;
                }
                ++notecardLine;
                notecardQueryId = llGetNotecardLine(notecardName, notecardLine); //Query the dataserver for the next notecard line.
            }
        }
    }

    listen (integer channel, string name, key id, string message)
    {
    	llOwnerSay(message);
        if (channel == channel_number)
        {
            list params = llParseStringKeepNulls(message,[";"],[""]);
            string cmd = llList2String(params, 0);
            params = llDeleteSubList(params, 0, 0);

            //* rings
            if (cmd == "ready") { //* ring ready to teleport
                if (dest_index>=0)
                {
                    teleport(id, llList2Integer(params, 0));
                }
            }
            //* gates
            if (cmd == "update") {
                if (update_id != llList2Key(params, 0)){
                    clear();
                    update_id = llList2Key(params, 0);
                    sendCommand("update", [update_id, version]); //* send pong reply (ring sync)
                }
                addGate(id);
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
                integer max_limit = llGetListLength(targets_name_list) / 9;
                if (max_limit >= 1 && cur_page <= max_limit)
                    cur_page += 1;
                showDialog(id);
            }
            else if (message == "Refresh") {
                update();
                finish();
            }
            else if (button_index != -1)
            {
                dest_index = button_index;
                llSensor("", NULL_KEY, AGENT, sensor_range, PI);
                llSetTimerEvent(ring_total_time);
           }
        }
    }
}
