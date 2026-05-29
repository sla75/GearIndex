import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Lang;
import Toybox.Test;

class SprocketStatsTest {
    (:test)
    function sprocketStatsTest(logger) {
        var ss=new SprocketStats(2,"SprocketStatsTest","T");
        logger.debug(ss);
        Test.assertEqual(ss.toString(),"SprocketStats[2]: SprocketStatsTest T");
        logger.debug(ss.getAvg(0));
        Test.assertEqualMessage(0,ss.getAvg(0),"AVG Must equal 0="+ss.getAvg(0));
        ss.add(0,3);
        ss.add(0,4);
        ss.add(0,5);
        logger.debug(ss.getAvg(0));
        Test.assertEqual(ss.getAvg(0),4d);
        logger.debug(ss.getCount(0));
        Test.assertEqual(ss.getCount(0),3);
        logger.debug(ss.getSum(0));
        Test.assertEqual(ss.getSum(0),12);
        logger.debug(ss.getAvg(1));
        Test.assertEqual(ss.getAvg(1),0);
        //logger.debug("Test.assert(true) didn't throw an Exception which is a very good thing.");
        //Test.assert(false);
        //logger.error("We should not be executing this statement.");
        return true;
    }
}