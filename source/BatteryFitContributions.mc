import Toybox.AntPlus;
import Toybox.Application;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;
import LogMonkey;

class BatteryFitContributions {

    private var field_RD_BatteryVoltage as FitContributor.Field or Null=null;
    private var field_RD_BatteryStatus as FitContributor.Field or Null=null;
    private var field_SL_BatteryVoltage as FitContributor.Field or Null=null;
    private var field_SL_BatteryStatus as FitContributor.Field or Null=null;


    private var dataField as WatchUi.DataField;
    private var saveFitFile as Boolean=false;

    private const FIT_RD_BATTERYVOLTAGE_ID = 100;
    private const FIT_RD_BATTERYSTATUS_ID = 101;
    private const FIT_SL_BATTERYVOLTAGE_ID = 200;
    private const FIT_SL_BATTERYSTATUS_ID = 201;

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
        if(self.saveFitFile) {
            if(field_RD_BatteryVoltage==null) {
                field_RD_BatteryVoltage = dataField.createField("RearDerailleurBatteryVoltage"
                    , FIT_RD_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT
                    , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
            }
            if(field_RD_BatteryStatus==null) {
                field_RD_BatteryStatus = dataField.createField("RearDerailleurBatteryStatus"
                    , FIT_RD_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8
                    , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
            }
            if(field_SL_BatteryVoltage==null) {
                field_SL_BatteryVoltage = dataField.createField("ShiftLeverBatteryVoltage"
                    , FIT_SL_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT
                    , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
            }
            if(field_SL_BatteryStatus==null) {
                field_SL_BatteryStatus = dataField.createField("ShiftLeverBatteryStatus"
                    , FIT_SL_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8
                    , {:mesgType=>FitContributor.MESG_TYPE_RECORD});
            }
        }
    }

    public function add(batteryArrayData as Array<MyDevice.BatteryData>) as Void {
        var batteryData;
        for(var i=0;i<batteryArrayData.size();i++){
            batteryData=(batteryArrayData as Array<MyDevice.BatteryData>)[i] as MyDevice.BatteryData or Null;
        
            if(saveFitFile&&field_RD_BatteryVoltage!=null&&batteryData!=null) {
                var s=BATTERY_STATUS.get(batteryData.status as BatteryStatusValue) as Number;
                switch(batteryData.identifier as Number) {
                    case 0x02:
                        field_RD_BatteryVoltage.setData(batteryData.voltage as Float);
                        field_RD_BatteryStatus.setData(s==null?0:s);
                        break;
                    case 0x04:
                        field_SL_BatteryVoltage.setData(batteryData.voltage as Float);
                        field_SL_BatteryStatus.setData(s==null?0:s);
                        break;
                }
            }
        }
    }
}