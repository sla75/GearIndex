import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Lang;
import Toybox.Test;

class GearStat {

    enum Name {
        DISTANCE0,
        TIME0,
        POWER0
    }

    enum PreferedMeasure {
        DEFAULT,
        CADENCE,
        POWER
    }

    

    private var lastDistance=0 as Float;
    private var lastTime=0 as Number;
    private var prefered as PreferedMeasure;
    private var BYPOWER=[] as Array<StatNums>;

    public function initialize(preferedMeasure as PreferedMeasure) {
        self.prefered=preferedMeasure;
    }
    
    public function compute(info as Activity.Info) {
        if(info==null || info.frontDerailleurSize==null || info.rearDerailleurSize==null){
            setLast(info);
            return;
        }
        if(info.timerState==Activity.TIMER_STATE_ON){
            var diffDistance=info.elapsedDistance-lastDistance;
            var diffTime=info.elapsedTime-lastTime;
            if(prefered==POWER&&info.currentPower!=null){
                if(info.currentPower>0){

                }
            }else if(prefered==CADENCE&&info.currentCadence!=null){
                if(info.currentCadence>0){

                }
            } else {

            }
        }
        setLast(info);
    }
    private function setLast(info as Activity.Info){
        System.println("GearStat.compute setLast");
        lastDistance=info.elapsedDistance;
        lastTime=info.elapsedTime;
    }

}

class Stats {
    typedef StatNum as {
        :suma as Numeric,
        :count as Number,
        :avg as Numeric,
    };
    var value as StatNum;
    public function initialize() {
        reset();
    }
    public function reset(){
        value={:suma=>0, :count=>0, :vag=>0} as StatNum;
    }
    public function add(number as Numeric){
        value.put(:suma,value.get(:suma)+number);
        value.put(:count,value.get(:count)+1);
    }
    public function getAvg() as Double {
        return value.get(:suma)/value.get(:count).toDouble();
    }
    public function getCount() as Number {
        return value.get(:count);
    }
}

class GearStatTest {
    (:test)
    function aTestOfAssert(logger) {
        logger.debug("This tests the assert() function.");
        Test.assert(true);
        logger.debug("Test.assert(true) didn't throw an Exception which is a very good thing.");
        Test.assert(false);
        logger.error("We should not be executing this statement.");
        return true;
    }
}