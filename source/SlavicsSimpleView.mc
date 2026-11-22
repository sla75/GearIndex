import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class SlavicsSimpleView extends WatchUi.SimpleDataField {
    private var bikeShift as AntPlus.Shifting = new AntPlus.Shifting(new AntPlus.ShiftingListener());
    private var name as String="";
    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        var loaded = WatchUi.loadResource(Rez.Strings.label);
        name = (loaded != null) ? loaded as String : "";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var bsds=bikeShift.getDeviceState() as AntPlus.DeviceState;
        if(bsds==null||bsds.state==null){
            return "??";
        }
        switch(bsds.state as Number){
            case AntPlus.DEVICE_STATE_SEARCHING:
                label=System.getClockTime().sec%2==0?"."+name+".":".."+name+"..";
                break;
            case AntPlus.DEVICE_STATE_TRACKING:
                label=name;
                break;
            default:
                label="?"+name+"?";
        }


        var ss=bikeShift.getShiftingStatus() as AntPlus.ShiftingStatus;
        
        if(ss!=null&&ss.rearDerailleur!=null){
            var rd=bikeShift.getShiftingStatus().rearDerailleur as AntPlus.DerailleurStatus;
            if(rd.gearIndex!=AntPlus.REAR_GEAR_INVALID){    
                return (rd.gearIndex+1).toString();
            } else {
                return "--";
            }
            //return System.getClockTime().sec.toString()+Application.loadResource(Rez.Strings.unitTeeth);
        } else {
            return "xx";
        }
    }

}