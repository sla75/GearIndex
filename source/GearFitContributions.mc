import Toybox.AntPlus;
import Toybox.Application;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;

class GearFitContributions {

    private var field_TotalShifts as FitContributor.Field;
    private var field_GearRatio as FitContributor.Field;
    private var field_GearIndex as FitContributor.Field;
    private var field_RdBatteryStatus as FitContributor.Field;
    private var field_RdBatteryVoltage as FitContributor.Field;

	private var mTimerRunning = STOP as ActivityTimer;
    private var totalShifts=0 as Number;

    private const FIT_RD_TOTALSHIFTS_ID = 0;
    private const FIT_RD_GEARRATIO_ID = 1;
    private const FIT_RD_GEARINDEX_ID = 2;
    private const FIT_RD_BATTERYSTATUS_ID = 3;
    private const FIT_RD_BATTERYVOLTAGE_ID = 4;

    enum ActivityTimer {
        STOP,
        RUNNING,
        PAUSE
    }

    function initialize(dataField as WatchUi.DataField) {
        Properties.setValue("property_fitFileSaving",Properties.getValue("property_fitFileSaving")==null?true:Properties.getValue("property_fitFileSaving") as Boolean);
        field_TotalShifts = dataField.createField("FIT_RD_TOTALSHIFTS_ID", FIT_RD_TOTALSHIFTS_ID, FitContributor.DATA_TYPE_UINT8, {
            :mesgType=>FitContributor.MESG_TYPE_SESSION});
        field_GearRatio = dataField.createField("FIT_RD_GEARRATIO_ID", FIT_RD_GEARRATIO_ID, FitContributor.DATA_TYPE_FLOAT, {
            :mesgType=>FitContributor.MESG_TYPE_RECORD});
        field_GearIndex = dataField.createField("FIT_RD_GEARINDEX_ID", FIT_RD_GEARINDEX_ID, FitContributor.DATA_TYPE_UINT8, {
            :mesgType=>FitContributor.MESG_TYPE_RECORD});

        field_RdBatteryStatus = dataField.createField("FIT_RD_BATTERYSTATUS_ID", FIT_RD_BATTERYSTATUS_ID, FitContributor.DATA_TYPE_UINT8, {
            :mesgType=>FitContributor.MESG_TYPE_RECORD});
        field_RdBatteryVoltage = dataField.createField("FIT_RD_BATTERYVOLTAGE_ID", FIT_RD_BATTERYVOLTAGE_ID, FitContributor.DATA_TYPE_FLOAT, {
            :mesgType=>FitContributor.MESG_TYPE_RECORD});
     
    }

    function setDerailleurs(fdSprocket as Number or Null,rdSprocket as Number or Null) as Void {
        if(rdSprocket==null || rdSprocket==AntPlus.REAR_GEAR_INVALID || rdSprocket==0){
            System.println("GearFitContributions.setDerailleurs rdSprocket="+rdSprocket);
            return;
        }

        if(fdSprocket==null || fdSprocket==AntPlus.FRONT_GEAR_INVALID || fdSprocket==0){
            System.println("GearFitContributions.setDerailleurs fdSprocket="+rdSprocket);
            return;
        }
        
        if(mTimerRunning!=RUNNING) {
            return;
        }
        var ratio=fdSprocket/rdSprocket.toFloat() as Float;
        field_GearRatio.setData(ratio);
        System.println("GearFitContributions.setDerailleurs ratio="+ratio.format("%.2f"));
    }

    function setIndex(index as Number or Null) as Void {
        if(index==null || index==AntPlus.REAR_GEAR_INVALID){
            System.println("GearFitContributions.setIndex BAD index="+index);
            return;
        }
        if(mTimerRunning!=RUNNING) {
            return;
        }
        field_GearIndex.setData(index+1);
        System.println("GearFitContributions.setIndex index="+index);
    }

    public function changeIndex(change as Number) as Void {
        if(mTimerRunning!=PAUSE){
            totalShifts+=change>0?change:-change;
            field_TotalShifts.setData(totalShifts);
            System.println("GearFitContributions.onChange totalShifts="+totalShifts);
        }
    }

    public function addRdBatteryStatus(batteryStatus as AntPlus.BatteryStatusValue or Null) as Void {
        System.println("GearFitContributions.addRdBatteryStatus "+batteryStatus);
        if(batteryStatus!=null){
            field_RdBatteryStatus.setData(batteryStatus);
        }
    }
    public function addRdBatteryVoltage(batteryVoltage as Float or Null) as Void {
        System.println("GearFitContributions.addRdBatteryVoltage "+batteryVoltage);
        if(batteryVoltage!=null){
            field_RdBatteryVoltage.setData(batteryVoltage);
        }
    }

    function getTotalShifts(){
        return totalShifts;
    }

    function onTimerReset() {
        totalShifts=0;
        mTimerRunning = STOP;
        System.println("GearFitContributions.onTimerReset mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }
    
    function onTimerPause() {
        mTimerRunning = PAUSE;
        System.println("GearFitContributions.onTimerPause mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }
    
    function onTimerResume() {
        mTimerRunning = RUNNING;
        System.println("GearFitContributions.onTimerResume mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }
    
    function onTimerStart() {
        if(mTimerRunning == STOP){
            totalShifts=0;
            System.println("GearFitContributions.onTimerStart 1 mTimerRunning="+mTimerRunning+" totalShifts=RESET");
        }
        mTimerRunning = RUNNING;
        System.println("GearFitContributions.onTimerStart 2 mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    }

    function onTimerStop() {
        mTimerRunning = PAUSE;
        System.println("GearFitContributions.onTimerStop mTimerRunning="+mTimerRunning+" totalShifts="+totalShifts);
    } 
}