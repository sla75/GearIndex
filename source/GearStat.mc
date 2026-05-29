import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Lang;

class GearStat {


    enum PreferedMeasure {
        DEFAULT,
        CADENCE,
        POWER
    }

    private var lastDistance=0 as Float;
    private var lastTime=0 as Number;
    private var prefered as PreferedMeasure;
    private var BYPOWER=[] as Array<SprocketStats>;

    public function initialize(preferedMeasure as PreferedMeasure) {
        self.prefered=preferedMeasure;
    }
    
    public function compute(info as Activity.Info) {
        if(info==null || info.frontDerailleurSize==null || info.rearDerailleurSize==null){
            //setLast(info);
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

public class SprocketStats {
    
    class Stat {
        var sum=0 as Numeric;
        var count=0 as Numeric;
    }

    private var name as String;
    private var unit as String;
    private var gears as Array<Stat>;

    public function initialize(gearSize as Number, name as String, unit as String) {
        self.name=name;
        self.unit=unit;
        gears=new[gearSize] as Array<Stat>;
        reset();
    }

    public function add(sprocket as Number,value as Numeric) as Void {
        gears[sprocket].sum+=value;
        gears[sprocket].count+=1;
    }

    public function addDiff(sprocket as Number,value as Numeric, range as Numeric) as Void {
        gears[sprocket].sum+=value*range;
        gears[sprocket].count+=range;
    }

    public function getSum(sprocket as Number) as Numeric{
        return gears[sprocket].sum;
    }
    public function getCount(sprocket as Number) as Numeric{
        return gears[sprocket].count;
    }
    public function getAvg(sprocket as Number) as Numeric{
        return getCount(sprocket)>0?getSum(sprocket)/getCount(sprocket).toDouble():0;
    }
    public function getName() as String{
        return self.name;
    }
    public function getUnit() as String{
        return self.unit;
    }
    public function size() as Number{
        return gears.size();
    }
    public function reset() as Void {
        gears=new[gears.size()] as Array<Stat>;
        for(var i=0;i<gears.size();i++){
            gears[i]=new Stat();
        }
    }

    public function toString() as String {
        return "SprocketStats["+size()+"]: "+getName()+" "+getUnit();
    }
}