import Toybox.AntPlus;
import Toybox.Graphics;
import Toybox.Lang;

class Device {

    typedef BatteryData as {
            :identifier as Number,
            :status as Number or Null,
            :voltage as Float or Null,
            :operatingTime as Number or Null,
            :color as Graphics.ColorType,
        };

    public static const BATTERY_STATUS_COLOR = [0,Graphics.COLOR_DK_GREEN,Graphics.COLOR_DK_GREEN,Graphics.COLOR_DK_GREEN,Graphics.COLOR_ORANGE,Graphics.COLOR_RED,0,Graphics.COLOR_DK_RED,Graphics.COLOR_LT_GRAY] as Array<ColorType>;

    public static const BATTERY_STATUSES =[AntPlus.BATT_STATUS_CNT,
                AntPlus.BATT_STATUS_NEW,
                AntPlus.BATT_STATUS_GOOD,
                AntPlus.BATT_STATUS_OK,
                AntPlus.BATT_STATUS_LOW,
                AntPlus.BATT_STATUS_CRITICAL,
                AntPlus.BATT_STATUS_CNT,
                AntPlus.BATT_STATUS_INVALID,
                AntPlus.BATT_STATUS_CNT,

            ] as Array<BatteryStatusValue>;

    private var device as AntPlus.Device;

    function initialize(device as AntPlus.Device){
        self.device=device;
    }
        
    (:release)
    public function getState() as AntPlus.DeviceState {
        return self.device.getDeviceState() as AntPlus.DeviceState;
    }

    (:debug)
    public function getState() as AntPlus.DeviceState {
        var ds=new AntPlus.DeviceState() as AntPlus.DeviceState;
        ds.deviceNumber=999999;
        ds.state=AntPlus.DEVICE_STATE_TRACKING;
        if(System.getClockTime().sec==7){
            ds.state=AntPlus.DEVICE_STATE_SEARCHING;
        } else if(System.getClockTime().sec==13){
            ds.state=AntPlus.DEVICE_STATE_CLOSED;
        } else if(System.getClockTime().sec>58){
            ds.state=AntPlus.DEVICE_STATE_DEAD;
        }
        LogMonkey.Debug.logMessage("Device.getState()","state="+getDeviceStateString(ds.state)+"["+ds.state+"]");
        return ds;
    }

    (:debug)
    public function getBatteries() as Array<BatteryData> {
        var ids=[0x01,0x03,0x55] as Array<Number>;
        var batteries=[] as Array<BatteryData>;
        for(var i=0;i<ids.size();i++){
            var id=ids[i];
            var bs=new BatteryStatus();
            bs.batteryStatus=BATTERY_STATUSES[(1+System.getClockTime().sec%8)];
            bs.batteryVoltage=System.getClockTime().sec/7f;
            bs.operatingTime=System.getClockTime().min*60+System.getClockTime().sec;
            if(bs has :batteryStatus && bs!=null){
                batteries.add({
                        :identifier=>id,
                        :status=>bs.batteryStatus==null?AntPlus.BATT_STATUS_INVALID:bs.batteryStatus,
                        :color=>BATTERY_STATUS_COLOR[bs.batteryStatus],
                        :voltage=>bs.batteryVoltage,
                        :operatingTime=>bs.operatingTime
                    });
            }
        }
        return batteries;
    }

    (:release)
    public function getBatteries() as Array<BatteryData> {
        var ids=device.getComponentIdentifiers() as Array<Number> or Null;
        var batteries=[] as Array<BatteryData>;
        if(ids==null){
            ids=[null] as Array<Number> or Null;
        }
        for(var i=0;i<ids.size();i++){
            var bs=device.getBatteryStatus(ids[i]) as BatteryStatus;
            if(bs!=null){
                batteries.add({
                    :identifier=>ids[i],
                    :status=>bs.batteryStatus==null?AntPlus.BATT_STATUS_INVALID:bs.batteryStatus,
                    :color=>BATTERY_STATUS_COLOR[bs.batteryStatus],
                    :voltage=>bs.batteryVoltage,
                    :operatingTime=>bs.operatingTime
                });
            }
        }
        return batteries;
    }

    public static function getBatteryStatusString(status as BatteryStatusValue or Null) as String {
        if(status==null){
            return "<null>";
        }
        switch(status){
            case 1:
                return "NEW";
            case 2:
                return "GOOD";
            case 3:
                return "OK";
            case 4:
                return "LOW";
            case 5:
                return "CRITICAL";
            case 7:
                return "INVALID";
            case 8:
                return "CNT";
            default:
                return "unknown";
        }
    }
    public static function getDeviceStateString(state as Number or Null) as String{
        if(state==null){
            return "<null>";
        }
        switch(state){
            case 0:
                return "DEAD";
            case 1:
                return "CLOSED";
            case 2:
                return "SEARCHING";
            case 3:
                return "TRACKING";
            case 4:
                return "CNT";
            default:
                return "unknown["+state+"]";
        }
    }
}