/**
    @name: Ring
    @description:

    @author: Zai Dium
    @updated: "2022-08-26 19:45:44"
    @revision: 145
    @localfile: ?defaultpath\Stargate\?@name.lsl
    @license: MIT

    @ref:

    @notice: Based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
integer owner_only = TRUE;
string ringSound = "RingSound";

integer channel_number = 0; //* Set it to 0 to autogenerate it
integer channel_private_number = 1;

//*
string ringDefaultSound = "e6a27da5-6eed-40e7-b57b-e99ac9eb42fe";

float  ring_total_time = 5;
integer ring_count = 5;
float ring_height = 0.5;

vector start_pos; //* starting pos
integer ring_number = 0; //* ring number
integer temp = 0; //* if enabled do not process teleports

key soundid;

string toRegion;
vector toPos;
vector toLookAt;
key agent;

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

integer dieRing = FALSE;
integer isFinished = FALSE;
key rez_owner;

start()
{
    start_pos = llGetPos();
    llSleep(0.1);
    llSetPos(start_pos + <0, 0, ring_height>);
    llSleep(0.2);
    vector offset;
    offset = <0, 0, ring_height * (ring_count - llAbs(ring_number) + 1)>; //* +1 the initial pos
    llSetPos(start_pos + offset);
    llSleep(0.2);
}

setTimer(integer die)
{
    dieRing = die;
    llSetTimerEvent((ring_total_time / ring_count) * (ring_count - ring_number + 1));//* +1 for not be 0
}

sound(){
    llTriggerSound(soundid, 1.0);
}

teleport()
{
    if (toRegion == "") {
        osTeleportAgent(agent, toPos, toLookAt);
    }
    else {
        osTeleportAgent(agent, toRegion, toPos, toLookAt);
    }
}

init(){
    soundid = llGetInventoryKey(ringSound);
    if (soundid == NULL_KEY)
        soundid = ringDefaultSound;

    sound();

    //ring_number = (integer)llGetObjectDesc();
    if (ring_number < 0) {
        ring_number = -ring_number; //* based on 1 not 0, zero make bug diveded
        temp = 1;
    }
    else
        temp = 0;

    //llOwnerSay("Entry Number: " + (string)ring_number);
    if (ring_number != 0) {
        if (channel_number == 0)
          channel_number = (((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF ) + channel_private_number;

        llListen(channel_number,"","","");
        start();

        if (temp)
            setTimer(TRUE);
        else
        {
            setTimer(FALSE);
            sendCommandTo(rez_owner, "ready", [(string)ring_number]); //* Gate will answer teleport
        }
    }
}

default
{
    state_entry()
    {
        llVolumeDetect(TRUE);
    }

    on_rez(integer param)
    {
        if (param != 0) {
 	    	llTargetOmega(llRot2Up(llGetLocalRot()), PI, 2.0);
            rez_owner = osGetRezzingObject();
            ring_number = param;
            llSetObjectDesc((string)param); //* because not saved to `listen` scope :(
            //start();
            init();
            llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
            //llResetScript();
        }
    }

    touch_start(integer num_detected)
    {
         //sound();
    }

    collision_start(integer num)
    {
        //llSay(0, llDetectedKey(0));
    }

    run_time_permissions(integer perm)
    {
        setTimer(TRUE);
        if(PERMISSION_TELEPORT & perm)
        {
            teleport();
        }
    }

    listen (integer channel, string name, key id, string message)
    {
        if (channel == channel_number)
        {
            if (ring_number > 0)
            {
                list params = llParseStringKeepNulls(message,[";"],[""]);
                string cmd = llList2String(params,0);
                params = llDeleteSubList(params, 0, 0);
                if (cmd == "teleport")
                {
                    //* only not temp rings
                    if (temp == 0)
                    {
                        integer number = llList2Integer(params, 0);
                        if (number == ring_number)
                        {
                            agent = llList2Key(params, 4);
                            if (agent)
                            {
                                toRegion = llList2String(params, 1);
                                toPos = llList2Vector(params, 2 );
                                toLookAt = llList2Vector(params, 3);
                                if ((agent == llGetOwner()) || (llGetPermissions() & PERMISSION_TELEPORT))
                                {
                                    setTimer(TRUE);
                                    teleport();
                                }
                                else {
                                    llRequestPermissions(agent, PERMISSION_TELEPORT);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    timer()
    {
        llSetTimerEvent(0);
        if (!isFinished) {
            sound();
            llSetPos(start_pos);
            isFinished = TRUE;
        }

        if (dieRing) {
            llSleep(0.2);
            llDie();
        }
   }
}
