import Toybox.AntPlus;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.WatchUi;

const FIT_RD_TOTALSHIFTS_ID = 0;
const FIT_RD_GEARRATIO_ID = 1;
//const BATTERY_STATUS_FIELD_SESSION_ID = 2;

class GearFitContributions {

    private var totalShiftsRF as FitContributor.Field;
    private var gearRatioRF as FitContributor.Field;
    
	private var mTimerRunning = false as Boolean;
    private var totalShifts as Number;
    private var lastSprocket=-1 as Number;

    function initialize(dataField as WatchUi.DataField) {
        totalShiftsRF = dataField.createField("FIT_RD_TOTALSHIFTS_ID", FIT_RD_TOTALSHIFTS_ID, FitContributor.DATA_TYPE_UINT8, {
            :mesgType=>FitContributor.MESG_TYPE_SESSION});

        gearRatioRF = dataField.createField("FIT_RD_GEARRATIO_ID", FIT_RD_GEARRATIO_ID, FitContributor.DATA_TYPE_FLOAT, {
            :mesgType=>FitContributor.MESG_TYPE_RECORD });

       totalShifts=0;
    }
    function setDerailleurs(fdSprocket as Number or Null,rdSprocket as Number or Null) as Void {
        if(!mTimerRunning) {
            return;
        }
        if(fdSprocket==null || fdSprocket==AntPlus.FRONT_GEAR_INVALID || fdSprocket==0){
            System.println("GearFitContributions fdSprocket="+fdSprocket);
            return;
        }
        if(rdSprocket==null || rdSprocket==AntPlus.REAR_GEAR_INVALID || rdSprocket==0){
            System.println("GearFitContributions rdSprocket="+rdSprocket);
            return;
        }
        setSprocket(rdSprocket);
        var ratio=fdSprocket*100/rdSprocket;
        gearRatioRF.setData(ratio/100f);
    }
    private function setSprocket(currentSprocket as Number) as Void {
        if(mTimerRunning && lastSprocket!=currentSprocket){
            if(lastSprocket>0){
                totalShifts++;
                totalShiftsRF.setData(totalShifts);
            }
            lastSprocket=currentSprocket;
        }
    }

    function onTimerReset() {
        totalShifts=0;
    }
    
    function onTimerPause() {
    	mTimerRunning = false;
    }
    
    function onTimerResume() {
        mTimerRunning = true;
    }
    
    function onTimerStart() {
        mTimerRunning = true;
    }

    function onTimerStop() {
        mTimerRunning = false;
    } 
}