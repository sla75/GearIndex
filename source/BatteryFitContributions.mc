import Toybox.AntPlus;
import Toybox.Application;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;
import LogMonkey;

class BatteryFitContributions {

    private var field_RD_BatteryVoltage=null as FitContributor.Field;
    private var field_RD_BatteryMinMax=null as FitContributor.Field;
    private var field_RD_BatteryStatus=null as FitContributor.Field;
    private var field_SL_BatteryVoltage=null as FitContributor.Field;
    private var field_SL_BatteryMinMax=null as FitContributor.Field;
    private var field_SL_BatteryStatus=null as FitContributor.Field;


    private var dataField as WatchUi.DataField;
    private var saveFitFile=false as Boolean;
    private var battery_RD_MinMax=null as Array<Float> or Null;
    private var battery_SL_MinMax=null as Array<Float> or Null;

    private const FIT_RD_BATTERYVOLTAGE_ID = 100;
    private const FIT_RD_BATTERYMINMAX_ID = 101;
    private const FIT_RD_BATTERYSTATUS_ID = 102;
    private const FIT_SL_BATTERYVOLTAGE_ID = 200;
    private const FIT_SL_BATTERYMINMAX_ID = 201;
    private const FIT_SL_BATTERYSTATUS_ID = 202;

    private static const BATTERY_STATUS={
            0=>0,
            AntPlus.BATT_STATUS_NEW=>8,
            AntPlus.BATT_STATUS_GOOD=>7,
            AntPlus.BATT_STATUS_OK=>6,
            AntPlus.BATT_STATUS_LOW=>5,
            AntPlus.BATT_STATUS_CRITICAL=>4,
            6=>3,
            AntPlus.BATT_STATUS_INVALID=>2,
            AntPlus.BATT_STATUS_CNT=>1,
        } as Dictionary<BatteryStatusValue,Number>;

    function initialize(dataField as WatchUi.DataField) {
        self.dataField=dataField;
    }

    function handleSettingUpdate(saveFitFile as Boolean) as Void {
        self.saveFitFile=saveFitFile;
        if(saveFitFile&&field_RD_BatteryVoltage==null) {
            field_RD_BatteryVoltage = dataField.createField("RearDerailleurBatteryVoltage"
                , FIT_RD_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT
                , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
            field_RD_BatteryMinMax = dataField.createField("RearDerailleurBatteryMinMax"
                , FIT_RD_BATTERYMINMAX_ID, FitContributor.DATA_TYPE_STRING
                , {:mesgType=>FitContributor.MESG_TYPE_SESSION
                    ,:count => 15});
            field_RD_BatteryStatus = dataField.createField("RearDerailleurBatteryStatus"
                , FIT_RD_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8
                , {:mesgType=>FitContributor.MESG_TYPE_RECORD});

            field_SL_BatteryVoltage = dataField.createField("ShiftLeverBatteryVoltage"
                , FIT_SL_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT
                , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
            field_SL_BatteryMinMax = dataField.createField("ShiftDerailleurBatteryMinMax"
                , FIT_SL_BATTERYMINMAX_ID, FitContributor.DATA_TYPE_STRING
                , {:mesgType=>FitContributor.MESG_TYPE_SESSION
                    ,:count => 15});
            field_SL_BatteryStatus = dataField.createField("ShiftLeverBatteryStatus"
                , FIT_SL_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8
                , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
        }
    }

    public function resetMinMax() as Void {
        battery_RD_MinMax=null;
        battery_SL_MinMax=null;
    }

    public function add(batteryArrayData as Array<MyDevice.BatteryData>) as Void {
        var batteryData;
        for(var i=0;i<batteryArrayData.size();i++){
            batteryData=(batteryArrayData as Array<MyDevice.BatteryData>)[i] as MyDevice.BatteryData;
        
            if(saveFitFile&&field_RD_BatteryVoltage!=null) {
                switch(batteryData.get(:identifier)){
                    case 0x02:
                        field_RD_BatteryVoltage.setData(batteryData.get(:voltage));
                        field_RD_BatteryStatus.setData(BATTERY_STATUS.get(batteryData.get(:status) as BatteryStatusValue));
                        battery_RD_MinMax=checkMinMax(battery_RD_MinMax,batteryData.get(:voltage));
                        if(battery_RD_MinMax!=null){
                            field_RD_BatteryMinMax.setData(battery_RD_MinMax[0].format("%.2f")+" – "+battery_RD_MinMax[0].format("%.2f"));
                        } else {
                            field_RD_BatteryMinMax.setData("null – null");
                        }
                        break;
                    case 0x04:
                        field_SL_BatteryVoltage.setData(batteryData.get(:voltage));
                        field_SL_BatteryStatus.setData(BATTERY_STATUS.get(batteryData.get(:status) as BatteryStatusValue));
                        battery_SL_MinMax=checkMinMax(battery_SL_MinMax,batteryData.get(:voltage));
                        if(battery_SL_MinMax!=null){
                            field_SL_BatteryMinMax.setData(battery_SL_MinMax[0].format("%.2f")+" – "+battery_SL_MinMax[0].format("%.2f"));
                        } else {
                            field_SL_BatteryMinMax.setData("null – null");
                        }
                        break;
                }
            }
        }
    }

    private static function checkMinMax(oldValues as Array<Float> or Null, newValue as Float or Null) as Array<Float> {
        if(newValue!=null&&newValue>=0){
            if(oldValues==null){
                oldValues=[999.9,0] as Array<Float>;
            }
            if(oldValues[0]>newValue){
                oldValues[0]=newValue;
            }
            if(oldValues[1]<newValue){
                oldValues[1]=newValue;
            }
        }
        return oldValues;
    }
}