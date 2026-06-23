import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Graphics;
import Toybox.Lang;
import LogMonkey;

class Derailleur extends MyDevice {

    (:debug)
    private const DEBUG_TEETHS = [51, 45, 39, 33, 28, 24, 21, 18, 16, 14, 12, 10] as Array<Number>;

    (:debug)
    private const DEBUG_INDEX = [5,7,9,11,11,11,10,9,8,7,6,5,4,3,2,1,0,0,0,2,3,4,9,11,11,11,8] as Array<Number>;

    private var shiftDevice=new AntPlus.Shifting(new AntPlus.ShiftingListener()) as AntPlus.Shifting;
    public static const BATTERY_NAME={0x00=>"Sys",0x01=>"FD",0x02=>"RD",0x03=>"LS",0x04=>"RS",0x05=>"Sh",0x06=>"les",0x07=>"res",0x08=>"es1",0x09=>"les2",0x0A=>"res2",0x0B=>"es2"} as Dictionary<Number,String>;

    function initialize(){
        MyDevice.initialize(shiftDevice);
    }
    var frontDerailleur=null as DerailleurStatus;
    var rearDerailleur=null as DerailleurStatus;
    (:debug)
    function compute(){
        switch(getState().state){
            case AntPlus.DEVICE_STATE_SEARCHING:
                LogMonkey.Debug.logMessage("Derailleur.compute()","Searching...");
                frontDerailleur=null;
                rearDerailleur=null;
                break;
            case AntPlus.DEVICE_STATE_TRACKING:
                frontDerailleur=new DerailleurStatus();
                rearDerailleur=new DerailleurStatus();
                LogMonkey.Debug.logMessage("Derailleur.compute()","Tracking...");
                frontDerailleur.gearIndex=System.getClockTime().sec/15%2;
                frontDerailleur.gearMax=40;
                frontDerailleur.gearSize=frontDerailleur.gearIndex==0?32:40;
                frontDerailleur.invalidInboardShiftCount=frontDerailleur.invalidInboardShiftCount==null?0:frontDerailleur.invalidInboardShiftCount;
                frontDerailleur.invalidOutboardShiftCount=frontDerailleur.invalidOutboardShiftCount==null?0:frontDerailleur.invalidOutboardShiftCount;
                frontDerailleur.shiftFailureCount=frontDerailleur.shiftFailureCount==null?0:frontDerailleur.shiftFailureCount;
                frontDerailleur.invalidInboardShiftCount+=Math.rand()%50==1?1:0;
                frontDerailleur.invalidOutboardShiftCount+=Math.rand()%50==1?1:0;
                frontDerailleur.shiftFailureCount+=(Math.rand()%20==1?1:0);

                var index=(System.getClockTime().min*60+System.getClockTime().sec)%DEBUG_INDEX.size();
                rearDerailleur.gearIndex=DEBUG_INDEX[index];
                rearDerailleur.gearMax=DEBUG_TEETHS.size();
                rearDerailleur.gearSize=DEBUG_TEETHS[rearDerailleur.gearIndex];
                rearDerailleur.invalidInboardShiftCount=rearDerailleur.invalidInboardShiftCount==null?0:rearDerailleur.invalidInboardShiftCount;
                rearDerailleur.invalidOutboardShiftCount=rearDerailleur.invalidOutboardShiftCount==null?0:rearDerailleur.invalidOutboardShiftCount;
                rearDerailleur.shiftFailureCount=rearDerailleur.shiftFailureCount==null?0:rearDerailleur.shiftFailureCount;
                if(index>0&&rearDerailleur.gearIndex==DEBUG_INDEX[index-1]){
                    if(index==0){
                        rearDerailleur.invalidInboardShiftCount++;
                    } else {
                        rearDerailleur.invalidOutboardShiftCount++;
                    }
                }
                rearDerailleur.shiftFailureCount+=(Math.rand()%20==1?1:0);
                break;
            default:
                LogMonkey.Debug.logMessage("Derailleur.compute()","others");
                frontDerailleur=new DerailleurStatus();
                frontDerailleur.gearIndex=AntPlus.FRONT_GEAR_INVALID;
                frontDerailleur.gearMax=AntPlus.MAX_GEARS_INVALID;
                frontDerailleur.gearSize=0;
                frontDerailleur.invalidInboardShiftCount=0;
                frontDerailleur.invalidOutboardShiftCount=0;
                frontDerailleur.shiftFailureCount=0;

                rearDerailleur=new DerailleurStatus();
                rearDerailleur.gearIndex=AntPlus.REAR_GEAR_INVALID;
                rearDerailleur.gearMax=AntPlus.MAX_GEARS_INVALID;
                rearDerailleur.gearSize=0;
                rearDerailleur.invalidInboardShiftCount=0;
                rearDerailleur.invalidOutboardShiftCount=0;
                rearDerailleur.shiftFailureCount=0;
        }
    }
    (:release)
    function compute(){
        if(shiftDevice.getShiftingStatus()!=null){
            frontDerailleur=shiftDevice.getShiftingStatus().frontDerailleur;
            rearDerailleur=shiftDevice.getShiftingStatus().rearDerailleur;
        } else {
            frontDerailleur=null;
            rearDerailleur=null;
        }
    }
    public function isFrontValidStatus() as Boolean {
        return frontDerailleur!=null && frontDerailleur.gearIndex!=AntPlus.FRONT_GEAR_INVALID;
    }
    public function isRearValidStatus() as Boolean {
        return rearDerailleur!=null && rearDerailleur.gearIndex!=AntPlus.REAR_GEAR_INVALID;
    }
    public function getFrontStatus() as AntPlus.DerailleurStatus {
        return frontDerailleur;
    }

    public function getRearStatus() as AntPlus.DerailleurStatus {
        return rearDerailleur;
    }

    public static function getBatteryName(id as Number or Null) as String {
        if(id==null){
            return "<null>";
        }
        return BATTERY_NAME.hasKey(id)?BATTERY_NAME.get(id):id.format("%x");
    }
}

/***
In the ANT+ ecosystem, SRAM's official manufacturer ID is 57 (Decimal) or 0x0039 
https://forums.garmin.com/developer/connect-iq/f/discussion/430536/question-how-to-distinguish-components-for-electric-sram-shift-systems-via-antplus
This is how I do it. Seems to work. Except in many cases the SRAM shifting components are not reliable in terms of sending battery status on a regular basis. I sometimes get a good status from the shifters close to activity start and sometimes not at all. All the other types work well (radar, power meters, cadence sensor, speed sensor, lights, etc), but SRAM isn't as consistent. 
TABLE 6-3, page 14, ANT PROFILE
Identifier Value
0 System
1 Front Derailleur
2 Rear Derailleur
3 Left Shifter
4 Right Shifter
5 Shifter
6 Left Extension Shifter
7 Right Extension Shifter
8 Extension Shifter 1
9 Left Extension Shifter 2
10 Right Extension Shifter 2
11 Extension Shifter 2
15 Unknown/Identified
component = (payload[2] >> 4) & 0xF;
BatStatus = (payload[7] >> 4) & 0x07;
VoltLvl = (payload[7] & 0x0F) + (payload[6] / 256.0);

switch (component) {
     case 0: // SYSTEM
     case 1: // FRONT SHIFTER
     etc
/***/