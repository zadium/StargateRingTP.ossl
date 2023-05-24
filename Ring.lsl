/**
    @name: Ring
    @description:

    @author: Zai Dium
    @updated: "2023-05-24 15:57:25"
    @version: 3.1
    @revision: 297
    @localfile: ?defaultpath\Stargate\?@name.lsl
    @license: MIT

    @ref:

    @notice: Based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
string ringSound = "RingSound";

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
    //llOwnerSay("teleporting: "+(string)agent+" "+toTarget);
    if (toTarget == "")
    {
        osLocalTeleportAgent(agent, toPos, ZERO_VECTOR, toLookAt, OS_LTPAG_USELOOKAT);
    }
    else
    {
        //llTeleportAgent(agent, toTarget, toPos, toLookAt);
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

default
{
    state_entry()
    {
        llVolumeDetect(TRUE);
    }

    on_rez(integer param)
    {
        //llOwnerSay("rez"+(string)param);
        //osGrantScriptPermissions(llGetOwner(), ["osTeleportAgent"]);
        llVolumeDetect(TRUE);
        if (param != 0) //* rezzed from Stargate
        {
            llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
            llTargetOmega(llRot2Up(llGetLocalRot()), PI, 2.0);
            rez_owner = osGetRezzingObject();
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
    }

    dataserver( key queryid, string data )
    {
        //llOwnerSay("data: "+data);
        if (ring_number > 0)
        {
            list params = llParseStringKeepNulls(data,[";"],[""]);
            string cmd = llList2String(params,0);
            params = llDeleteSubList(params, 0, 0);
            if (cmd == "teleport")
            {
                //* only not temp rings
                integer number = llList2Integer(params, 0);
                if (number == ring_number)
                {
                    agent = llList2Key(params, 1);
                    if (agent != NULL_KEY)
                    {
                        toType = llToLower(llList2String(params, 2));
                        toTarget = llList2String(params, 3);
                        toPos = llList2Vector(params, 4);
                        toLookAt = llList2Vector(params, 5);
                        if ((agent == llGetOwner()) || (llGetPermissions() & PERMISSION_TELEPORT))
                        //if ((toTarget =="") || (agent == llGetOwner()))
                        {
                            teleport();
                        }
                        else
                        {
                            llRequestPermissions(agent, PERMISSION_TELEPORT);
                        }
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
