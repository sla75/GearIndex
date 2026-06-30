import Toybox.AntPlus;
import Toybox.Application;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;
import LogMonkey;

class GearFitContributions {

    private var field_TotalShifts=null as FitContributor.Field;
    private var field_GearRatio=null as FitContributor.Field;
    private var field_GearIndex=null as FitContributor.Field;
    //private var field_RdBatteryStatus=null as FitContributor.Field;
    //private var field_RdBatteryVoltage=null as FitContributor.Field;

	private var mTimerRunning = STOP as ActivityTimer;
    private var totalShifts=0 as Number;
    private var dataField as WatchUi.DataField;
    private var saveFitFile=false as Boolean;

    private const FIT_RD_TOTALSHIFTS_ID = 0;
    private const FIT_RD_GEARRATIO_ID = 1;
    private const FIT_RD_GEARINDEX_ID = 2;

    enum ActivityTimer {
        STOP,
        RUNNING,
        PAUSE
    }

    function initialize(dataField as WatchUi.DataField) {
        self.dataField=dataField;
    }

    function handleSettingUpdate(saveFitFile as Boolean) as Void {
        self.saveFitFile=saveFitFile;
        LogMonkey.Debug.logMessage("GearFitContributions.handleSettingUpdate()","saveFile="+saveFitFile+" object="+(field_TotalShifts==null?"null":"Exists"));
        if(saveFitFile&&field_TotalShifts==null) {
            field_TotalShifts = dataField.createField("FIT_RD_TOTALSHIFTS_ID", FIT_RD_TOTALSHIFTS_ID, FitContributor.DATA_TYPE_UINT8, {
                :mesgType=>FitContributor.MESG_TYPE_SESSION});
            field_GearRatio = dataField.createField("FIT_RD_GEARRATIO_ID", FIT_RD_GEARRATIO_ID, FitContributor.DATA_TYPE_FLOAT, {
                :mesgType=>FitContributor.MESG_TYPE_RECORD});
            field_GearIndex = dataField.createField("FIT_RD_GEARINDEX_ID", FIT_RD_GEARINDEX_ID, FitContributor.DATA_TYPE_FLOAT, {
                :mesgType=>FitContributor.MESG_TYPE_RECORD});
            //field_RdBatteryStatus = dataField.createField("FIT_RD_BATTERYSTATUS_ID", FIT_RD_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8, {
            //    :mesgType=>FitContributor.MESG_TYPE_RECORD});
            //field_RdBatteryVoltage = dataField.createField("FIT_RD_BATTERYVOLTAGE_ID", FIT_RD_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT, {
            //    :mesgType=>FitContributor.MESG_TYPE_RECORD});
        }
    }

    function setRatio(frontTeeths as Number or Null,rearTeeths as Number or Null) as Void {
        if(!saveFitFile||frontTeeths==null||frontTeeths==0||rearTeeths==null||rearTeeths==0){
            return;
        }
        if(mTimerRunning!=RUNNING) {
            return;
        }
        field_GearIndex.setData(rearTeeths.toNumber());
        var ratio=frontTeeths/rearTeeths.toFloat() as Float;
        field_GearRatio.setData(ratio);
        LogMonkey.Debug.logVariable("GearFitContributions.setDerailleurs()","ratio",ratio.format("%.2f"));
    }

    public function changeIndex(change as Number) as Void {
        if(mTimerRunning!=PAUSE){
            totalShifts+=change>0?change:-change;
            if(saveFitFile){
                field_TotalShifts.setData(totalShifts);
            }
            LogMonkey.Debug.logMessage("GearFitContributions.onChange()","totalShifts="+totalShifts+" save("+saveFitFile+")");
        }
    }
    /***
    public function addRdBatteryStatus(batteryStatus as AntPlus.BatteryStatusValue or Null) as Void {
        LogMonkey.Debug.logMessage("GearFitContributions.addRdBatteryStatus()",batteryStatus+" save("+saveFitFile+")");
        if(saveFitFile&&batteryStatus!=null){
            field_RdBatteryStatus.setData(batteryStatus);
        }
    }
    public function addRdBatteryVoltage(batteryVoltage as Float or Null) as Void {
        LogMonkey.Debug.logMessage("GearFitContributions.addRdBatteryVoltage()",batteryVoltage+" save("+saveFitFile+")");
        if(saveFitFile&&batteryVoltage!=null){
            field_RdBatteryVoltage.setData(batteryVoltage);
        }
    }
    /***/
    function getTotalShifts() as Number{
        return totalShifts;
    }

    function onTimerReset() {
        totalShifts=0;
        mTimerRunning = STOP;
        LogMonkey.Debug.logMessage("GearFitContributions.onTimerReset()","mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }
    
    function onTimerPause() {
        mTimerRunning = PAUSE;
        LogMonkey.Debug.logMessage("GearFitContributions.onTimerPause()","mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }
    
    function onTimerResume() {
        mTimerRunning = RUNNING;
        LogMonkey.Debug.logMessage("GearFitContributions.onTimerResume()","mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }
    
    function onTimerStart() {
        if(mTimerRunning == STOP){
            totalShifts=0;
            LogMonkey.Debug.logMessage("GearFitContributions.onTimerStart()","1 mTimerRunning="+mTimerRunning+" totalShifts=RESET");
        }
        mTimerRunning = RUNNING;
        LogMonkey.Debug.logMessage("GearFitContributions.onTimerStart()","2 mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }

    function onTimerStop() {
        mTimerRunning = PAUSE;
        LogMonkey.Debug.logMessage("GearFitContributions.onTimerStop()","mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    } 
}