import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Graphics;
import Toybox.Lang;

class Derailleur extends Device {

    (:debug)
    private const DEBUG_TEETHS = [51, 45, 39, 33, 28, 24, 21, 18, 16, 14, 12, 10] as Array<Number>;

    private var shiftDevice=new AntPlus.Shifting(new AntPlus.ShiftingListener()) as AntPlus.Shifting;
    public static const BATTERY_NAME={0x01=>"FD",0x02=>"RD",0x03=>"LS",0x04=>"RS"} as Dictionary<Number,String>;

    function initialize(){
        Device.initialize(shiftDevice);
    }
    var frontDerailleur=new DerailleurStatus();
    var rearDerailleur=new DerailleurStatus();
    (:debug)
    function compute(info as Activity.Info){
        if(System.getClockTime().sec==26){
            frontDerailleur.gearIndex=AntPlus.REAR_GEAR_INVALID;
            frontDerailleur.gearMax=AntPlus.MAX_GEARS_INVALID;
            frontDerailleur.gearSize=0;
            frontDerailleur.invalidInboardShiftCount=0;
            frontDerailleur.invalidOutboardShiftCount=0;
            frontDerailleur.shiftFailureCount=0;
        } else {
            frontDerailleur.gearIndex=System.getClockTime().sec/15%2;
            frontDerailleur.gearMax=40;
            frontDerailleur.gearSize=frontDerailleur.gearIndex==0?32:40;
            frontDerailleur.invalidInboardShiftCount=frontDerailleur.invalidInboardShiftCount==null?0:frontDerailleur.invalidInboardShiftCount;
            frontDerailleur.invalidOutboardShiftCount=frontDerailleur.invalidOutboardShiftCount==null?0:frontDerailleur.invalidOutboardShiftCount;
            frontDerailleur.shiftFailureCount=frontDerailleur.shiftFailureCount==null?0:frontDerailleur.shiftFailureCount;
            frontDerailleur.invalidInboardShiftCount+=Math.rand()%50==1?1:0;
            frontDerailleur.invalidOutboardShiftCount+=Math.rand()%50==1?1:0;
            frontDerailleur.shiftFailureCount+=(Math.rand()%20==1?1:0);
        }
        if(System.getClockTime().sec==13){
            rearDerailleur.gearIndex=AntPlus.FRONT_GEAR_INVALID;
            rearDerailleur.gearMax=AntPlus.MAX_GEARS_INVALID;
            rearDerailleur.gearSize=0;
            rearDerailleur.invalidInboardShiftCount=0;
            rearDerailleur.invalidOutboardShiftCount=0;
            rearDerailleur.shiftFailureCount=0;
        } else {
            rearDerailleur.gearIndex=System.getClockTime().sec/3%DEBUG_TEETHS.size();
            if(rearDerailleur.gearIndex==3){
                rearDerailleur.gearIndex=5;
            }
            rearDerailleur.gearMax=DEBUG_TEETHS.size();
            rearDerailleur.gearSize=DEBUG_TEETHS[rearDerailleur.gearIndex];
            rearDerailleur.invalidInboardShiftCount=rearDerailleur.invalidInboardShiftCount==null?0:rearDerailleur.invalidInboardShiftCount;
            rearDerailleur.invalidOutboardShiftCount=rearDerailleur.invalidOutboardShiftCount==null?0:rearDerailleur.invalidOutboardShiftCount;
            rearDerailleur.shiftFailureCount=rearDerailleur.shiftFailureCount==null?0:rearDerailleur.shiftFailureCount;
            rearDerailleur.invalidInboardShiftCount+=Math.rand()%50==1?1:0;
            rearDerailleur.invalidOutboardShiftCount+=Math.rand()%50==1?1:0;
            rearDerailleur.shiftFailureCount+=(Math.rand()%20==1?1:0);
        }
        info.frontDerailleurIndex=frontDerailleur.gearIndex==null?null:frontDerailleur.gearIndex+1;
        info.frontDerailleurMax=frontDerailleur.gearMax;
        info.frontDerailleurSize=frontDerailleur.gearSize;
        info.rearDerailleurIndex=rearDerailleur.gearIndex==null?null:rearDerailleur.gearIndex+1;
        info.rearDerailleurMax=rearDerailleur.gearMax;
        info.rearDerailleurSize=rearDerailleur.gearSize;
    }
    (:release)
    function compute(info as Activity.Info){
        frontDerailleur=shiftDevice.getShiftingStatus().frontDerailleur;
        rearDerailleur=shiftDevice.getShiftingStatus().rearDerailleur;
    }

    public function getFrontStatus() as AntPlus.DerailleurStatus {
        return frontDerailleur;
    }

    public function getRearStatus() as AntPlus.DerailleurStatus {
        return rearDerailleur;
    }

    public static function getBatteryName(id as Number or Null) as String {
        if(id==null){
            return "";
        }
        return BATTERY_NAME.hasKey(id)?BATTERY_NAME.get(id):id.format("%x");
    }
}