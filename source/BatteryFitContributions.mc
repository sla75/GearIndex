import Toybox.AntPlus;
import Toybox.Application;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;
import LogMonkey;

class BatteryFitContributions {

    private var field_RD_BatteryVoltage=null as FitContributor.Field;
    private var field_RD_BatteryStatus=null as FitContributor.Field;
    private var field_SL_BatteryVoltage=null as FitContributor.Field;
    private var field_SL_BatteryStatus=null as FitContributor.Field;


    private var dataField as WatchUi.DataField;
    private var saveFitFile=false as Boolean;

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
        LogMonkey.Debug.logMessage("GearFitContributions.handleSettingUpdate()","saveFile="+saveFitFile+" object="+(field_TotalShifts==null?"null":"Exists"));
        if(saveFitFile&&field_RD_BatteryVoltage==null) {
            field_RD_BatteryVoltage = dataField.createField("RearDerailleurBatteryVoltage", FIT_RD_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT, {
                :mesgType=>FitContributor.MESG_TYPE_RECORD});
            field_RD_BatteryStatus = dataField.createField("RearDerailleurBatteryStatus", FIT_RD_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8, {
                :mesgType=>FitContributor.MESG_TYPE_RECORD});
            field_SL_BatteryVoltage = dataField.createField("ShiftLeverBatteryVoltage", FIT_RD_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT, {
                :mesgType=>FitContributor.MESG_TYPE_RECORD});
            field_SL_BatteryStatus = dataField.createField("ShiftLeverBatteryStatus", FIT_RD_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8, {
                :mesgType=>FitContributor.MESG_TYPE_RECORD});
        }
    }

    public function add(batteryData as MyDevice.BatteryData) as Void {
        if(saveFitFile&&field_RD_BatteryVoltage!=null&&batteryData!=null) {
            switch(bd.get(:identifier)){
             case 0x02:
                    field_RD_BatteryVoltage.setData(bd.get(:voltage));
                    field_RD_BatteryStatus.setData(bd.get(:status));
                    break;
            case 0x04:
                    field_SL_BatteryVoltage.setData(bd.get(:voltage));
                    field_SL_BatteryStatus.setData(bd.get(:status));
                    break;
            }
        }
    }
}