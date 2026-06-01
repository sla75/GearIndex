import Toybox.AntPlus;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;

class GearFitContributions {

    private var totalShiftsRF as FitContributor.Field;
    private var gearRatioRF as FitContributor.Field;
    private var gearIndexRF as FitContributor.Field;
    
	private var mTimerRunning = STOP as ActivityTimer;
    private var totalShifts=0 as Number;

    private const FIT_RD_TOTALSHIFTS_ID = 0;
    private const FIT_RD_GEARRATIO_ID = 1;
    private const FIT_RD_GEARINDEX_ID = 2;

    enum ActivityTimer {
        STOP,
        RUNNING,
        PAUSE
    }

    function initialize(dataField as WatchUi.DataField) {
        totalShiftsRF = dataField.createField("FIT_RD_TOTALSHIFTS_ID", FIT_RD_TOTALSHIFTS_ID, FitContributor.DATA_TYPE_UINT8, {
            :mesgType=>FitContributor.MESG_TYPE_SESSION});

        gearRatioRF = dataField.createField("FIT_RD_GEARRATIO_ID", FIT_RD_GEARRATIO_ID, FitContributor.DATA_TYPE_FLOAT, {
            :mesgType=>FitContributor.MESG_TYPE_RECORD, :nativeNum => 23 });
        
        gearIndexRF = dataField.createField("FIT_RD_GEARINDEX_ID", FIT_RD_GEARINDEX_ID, FitContributor.DATA_TYPE_UINT8, {
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
        gearRatioRF.setData(ratio);
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
        gearIndexRF.setData(index+1);
        System.println("GearFitContributions.setIndex index="+index);
    }

    public function changeIndex(change as Number) as Void {
        if(mTimerRunning!=PAUSE){
            totalShifts+=change>0?change:-change;
            totalShiftsRF.setData(totalShifts);
            System.println("GearFitContributions.onChange totalShifts="+totalShifts);
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