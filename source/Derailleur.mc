import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Graphics;
import Toybox.Lang;
import LogMonkey;

class Derailleur extends Device {

    (:debug)
    private const DEBUG_TEETHS = [51, 45, 39, 33, 28, 24, 21, 18, 16, 14, 12, 10] as Array<Number>;

    (:debug)
    private const DEBUG_INDEX = [5,7,9,11,11,11,10,9,8,7,6,5,4,3,2,1,0,0,0,2,3,4,9,11,11,11,8] as Array<Number>;

    private var shiftDevice=new AntPlus.Shifting(new AntPlus.ShiftingListener()) as AntPlus.Shifting;
    public static const BATTERY_NAME={0x01=>"FD",0x02=>"RD",0x03=>"LS",0x04=>"RS"} as Dictionary<Number,String>;

    function initialize(){
        Device.initialize(shiftDevice);
    }
    var frontDerailleur=null as DerailleurStatus;
    var rearDerailleur=null as DerailleurStatus;
    (:debug)
    function compute(info as Activity.Info){
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

        info.frontDerailleurIndex=frontDerailleur==null?null:frontDerailleur.gearIndex+1;
        info.frontDerailleurMax=frontDerailleur==null?null:frontDerailleur.gearMax;
        info.frontDerailleurSize=frontDerailleur==null?null:frontDerailleur.gearSize;
        if(rearDerailleur!=null){
            info.rearDerailleurIndex=rearDerailleur.gearIndex+1;
            info.rearDerailleurMax=rearDerailleur.gearMax;
            info.rearDerailleurSize=rearDerailleur.gearSize;
            LogMonkey.Debug.logMessage("Derailleur.compute()","rearDerailleur.index="+rearDerailleur.gearIndex+" size="+rearDerailleur.gearSize+" invalid="+rearDerailleur.invalidInboardShiftCount+"/"+rearDerailleur.invalidOutboardShiftCount);

        } else {
            info.rearDerailleurIndex=null;
            info.rearDerailleurMax=null;
            info.rearDerailleurSize=null;
            LogMonkey.Debug.logMessage("Derailleur.compute()","rearDerailleur=<null>");

        }
    }
    (:release)
    function compute(info as Activity.Info){
        if(shiftDevice.getShiftingStatus()!=null){
            frontDerailleur=shiftDevice.getShiftingStatus().frontDerailleur;
            rearDerailleur=shiftDevice.getShiftingStatus().rearDerailleur;
        } else {
            frontDerailleur=null;
            rearDerailleur=null;
        }
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