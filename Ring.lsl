/**
    @name: Ring
    @description:

    @author: Zai Dium
    @updated: "2024-09-28 00:35:40"
    @version: 4
    @revision: 447
    @localfile: ?defaultpath\Stargate\?@name.lsl
    @license: MIT

    @ref:

    @notice: Based on idea "APN Ring Transporters (OSGrid/OpenSim) by Spectre Draconia and author: Warin Cascabel, April 2009"
*/

//* User Setting
string ringSound = "RingSound";

integer ring_channel = 101;

integer ask_perm = TRUE;
integer fake = FALSE;

//*
string ringDefaultSound = "e6a27da5-6eed-40e7-b57b-e99ac9eb42fe";

float  ring_total_time = 5;
integer ring_count = 5;
float ring_height = 0.5;

vector start_pos; //* starting pos
integer ring_number = 0; //* ring number
integer dieRing = 0; //* if enabled do not process teleports

string toTarget;
vector toPos;
vector toLookAt;
string toType;
key agent;

integer isFinished = FALSE;
key rezzer = NULL_KEY;

setTimer()
{
    llSetTimerEvent((ring_total_time / ring_count) * (ring_count - ring_number + 1));//* +1 for not be 0
}

sound(){
    key soundid = llGetInventoryKey(ringSound);
    if (soundid == NULL_KEY)
        soundid = ringDefaultSound;
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

    dieOnFinish();
}

start()
{
    start_pos = llGetPos();
    llSleep(0.1);
    llSetPos(start_pos + <0, 0, ring_height>);
    llSleep(0.2);
    vector offset = <0, 0, ring_height * (ring_count - llAbs(ring_number) + 1)>; //* +1 the initial pos
    llSetPos(start_pos + offset);
    llSleep(0.2);
}

raise()
{
    sound();

    if (ring_number != 0)
    {
        start();
        setTimer();
    }
}

dieOnFinish()
{
    dieRing = TRUE;
    if (isFinished)
    {
        llSetTimerEvent(0);
        llSleep(0.2);
        //llOwnerSay("die:onfinish");
        llDie();
    }
}

default
{
    state_entry()
    {
        ask_perm = llList2Key(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_OWNER]),0) != llGetOwner();
        llVolumeDetect(TRUE);
    }

    on_rez(integer number)
    {
        //llOwnerSay("ring:rez:"+(string)number);
        //osGrantScriptPermissions(llGetOwner(), ["osTeleportAgent"]);
        ask_perm = llList2Key(llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_OWNER]),0) != llGetOwner();
        llVolumeDetect(TRUE);
        if (number != 0) //* rezzed from Stargate
        {
            llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]);
            rezzer = osGetRezzingObject();
            if (number<0)
            {
                //llOwnerSay("fake");
                number = -number;
                fake = TRUE;
            }
            ring_number = number & 0xFF;
            ring_count = number >> 8;
            //llOwnerSay("ring_number "+(string)ring_number+" / ring_count "+(string)ring_count);
            llListen(ring_channel, "", NULL_KEY, "");
            llTargetOmega(llRot2Up(llGetLocalRot()), PI, 2.0);
            llSetObjectName("ring_"+(string)llAbs(ring_number));
            //llOwnerSay("ring: ring_"+(string)ring_number);
            if (fake)
                dieRing = TRUE;
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
            dieOnFinish();
    }

    listen(integer channel, string name, key id, string message)
    {
        //llOwnerSay("ring,rezzer:"+(string)rezzer);
        //llOwnerSay("ring,number:"+(string)ring_number);
        if (rezzer == id)
        {
            //llOwnerSay("ring.message:"+message);
            list params = llParseStringKeepNulls(message,[";"],[""]);
            string cmd = llList2String(params,0);
            params = llDeleteSubList(params, 0, 0);
            integer number = 0;
            if (cmd == "teleport")
            {
                //* only not temp rings
                number = llList2Integer(params, 0);
                agent = llList2Key(params, 1);
                if ((agent == NULL_KEY) || (agent == ""))  //* key from "" is not NULL_KEY
                {
                    dieOnFinish();
                    //llOwnerSay("dieOnFinish,null");
                }
                else
                {
                    //llOwnerSay("ring:"+llKey2Name(agent));
                    //llOwnerSay("ring:"+(string)agent);
                    toType = llToLower(llList2String(params, 2));
                    toTarget = llList2String(params, 3);
                    toPos = llList2Vector(params, 4);
                    toLookAt = llList2Vector(params, 5);
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
