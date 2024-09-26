/**
    @name: Ring
    @description:

    @author: Zai Dium
    @updated: "2024-09-26 17:32:03"
    @version: 3.1
    @revision: 331
    @localfile: ?defaultpath\Stargate\?@name.lsl
    @license: MIT

    @ref:

    @notice: Based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
string ringSound = "RingSound";

integer ask_perm = TRUE;

//*
string ringDefaultSound = "e6a27da5-6eed-40e7-b57b-e99ac9eb42fe";

float  ring_total_time = 5;
integer ring_count = 5;
float ring_height = 0.5;

vector start_pos; //* starting pos
integer ring_number = 0; //* ring number
integer dieRing = 0; //* if enabled do not process teleports

key soundid;

string toTarget;
vector toPos;
vector toLookAt;
string toType;
key agent;

integer isFinished = FALSE;
key rez_owner;

setTimer()
{
    llSetTimerEvent((ring_total_time / ring_count) * (ring_count - ring_number + 1));//* +1 for not be 0
}

sound(){
    llTriggerSound(soundid, 1.0);
}

teleport()
{
    //llOwnerSay("teleporting: "+(string)agent+" target"+toTarget+" pos:"+(string)toPos);
    if (toTarget == "")
    {
        osLocalTeleportAgent(agent, toPos, ZERO_VECTOR, toLookAt, OS_LTPAG_USELOOKAT);
    }
    else
    {
        //llTeleportAgent(agent, toTarget, toPos, toLookAt);
        //* Need OSSL permission
        osTeleportAgent(agent, toTarget, toPos, toLookAt);
    }

    if (isFinished)
    {
        llSleep(0.2);
//        llOwnerSay("die:teleport");
        llDie();
    }
}

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

raise()
{
    soundid = llGetInventoryKey(ringSound);
    if (soundid == NULL_KEY)
        soundid = ringDefaultSound;

    sound();

//    llOwnerSay("Entry Number: " + (string)ring_number);
    if (ring_number != 0)
    {
        start();
        setTimer();
    }
}

integer ring_channel = 100;

default
{
    state_entry()
    {
        ask_perm = llList2Key(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_OWNER]),0) != llGetOwner();
        llVolumeDetect(TRUE);
    }

    on_rez(integer param)
    {
        //llOwnerSay("rez"+(string)param);
        //osGrantScriptPermissions(llGetOwner(), ["osTeleportAgent"]);
        ask_perm = llList2Key(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_OWNER]),0) != llGetOwner();
        llVolumeDetect(TRUE);
        if (param != 0) //* rezzed from Stargate
        {
            llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
            llTargetOmega(llRot2Up(llGetLocalRot()), PI, 2.0);
            rez_owner = osGetRezzingObject();
            llListen(ring_channel, "", rez_owner, "");
            ring_number = param;
            //llSetObjectDesc((string)param); //* because not saved to `listen` scope :(
            llSetObjectName("Ring"+(string)param);
            //ring_number = (integer)llGetObjectDesc();
            if (ring_number < 0)
            {
                ring_number = -ring_number; //* based on 1 not 0, zero make bug diveded
                dieRing = TRUE;
            }
            else
                dieRing = FALSE;

            raise();
        }

    }

    collision_start(integer num)
    {
        //llSay(0, llDetectedKey(0));
    }

    run_time_permissions(integer perm)
    {
        if(PERMISSION_TELEPORT & perm)
        {
            teleport();
        }
        else
            dieRing = TRUE; //* if timer still working
            if (isFinished)
                setTimer();
    }

    listen(integer channel, string name, key id, string message)
    {
        //llOwnerSay("data: "+data);
        if (ring_number > 0)
        {
            list params = llParseStringKeepNulls(message,[";"],[""]);
            string cmd = llList2String(params,0);
            params = llDeleteSubList(params, 0, 0);
            if (cmd == "teleport")
            {
                //* only not temp rings
                agent = llList2Key(params, 0);
                if (agent != NULL_KEY)
                {
                    toType = llToLower(llList2String(params, 1));
                    toTarget = llList2String(params, 2);
                    toPos = llList2Vector(params, 3);
                    toLookAt = llList2Vector(params, 4);
                    if ((agent == llGetOwner()) || (!ask_perm))
                        teleport();
                    else
                    {
                        llRequestPermissions(agent, PERMISSION_TELEPORT);
                        llRegionSayTo(agent, 0, "To teleport please accept request permissions");
                    }
                }
            }
        }
    }

    timer()
    {
        if (!isFinished)
        {
            sound();
            llSetPos(start_pos);
            isFinished = TRUE;
        }

        if (dieRing)
        {
            //llOwnerSay("die:timer");
            llSetTimerEvent(0);
            llDie();
        }
        else
        {
            dieRing = TRUE;
            llSetTimerEvent(30);
        }

   }
}
