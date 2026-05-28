import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Lang;
import Toybox.Test;

class GearStat {
    enum Name {
        DISTANCE,
        TIME,
        POWER
    }
    
    private var lastDistance=0 as Float;
    private var lastTimerTime=0 as Number;

    public function initialize() {
    }
    
    public function compute(info as Activity.Info, currentFrontIndex, shiftingStatus as ShiftingStatus) {
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