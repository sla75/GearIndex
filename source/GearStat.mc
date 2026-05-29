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
    private var lastTimerTime=0 as Number;
    private var prefered as PreferedMeasure;
    private var stats={:power=>null,:time=>null,:distance=>null} as Dictionary<Symbol,SprocketStats>;

    public function initialize(preferedMeasure as PreferedMeasure) {
        self.prefered=preferedMeasure;
    }
    private const DEBUG_TEETHS = [51, 45, 39, 33, 28, 24, 21, 18, 16, 14, 12, 10] as Array<Number>;
    (:debug)
    public function compute(info as Activity.Info) {
        info.frontDerailleurSize=32;
        info.rearDerailleurIndex=System.getClockTime().sec/3%DEBUG_TEETHS.size();
        info.rearDerailleurMax=DEBUG_TEETHS.size();
        info.rearDerailleurSize=DEBUG_TEETHS[info.rearDerailleurIndex];
        info.currentPower=50+Math.rand()%300;
        info.currentCadence=50+Math.rand()%70;
        if(System.getClockTime().sec%20==3){
            info.currentPower=null;
            info.currentCadence=null;
        }
        System.println("GearStat.compute() DEBUG Derailleur"+info.frontDerailleurSize+"/"+info.rearDerailleurSize+"["+info.rearDerailleurIndex+"] cadence="+info.currentCadence+" power="+info.currentPower);
        computeTeeth(info);
    }
    (:release)
    public function compute(info as Activity.Info) {
        computeTeeth(info);
    }
    private  function computeTeeth(info as Activity.Info) {
        if(info==null || info.frontDerailleurSize==null || info.rearDerailleurSize==null){
            return;
        }
        if(info.timerState==Activity.TIMER_STATE_ON&&info.elapsedDistance!=null){
            
            System.println("GearStat.compute() elapsedDistance="+info.elapsedDistance+"-"+lastDistance);
            var diffDistance=info.elapsedDistance-lastDistance;
            var diffTime=info.timerTime-lastTimerTime;
            if(prefered==POWER&&info.currentPower!=null){
                if(info.currentPower>0&&info.rearDerailleurSize!=0&&info.rearDerailleurSize!=AntPlus.FRONT_GEAR_INVALID){
                    var powerStats=stats.get(:power) as SprocketStats;
                    if(stats.get(:power)==null){
                        powerStats=new SprocketStats(info.rearDerailleurMax,"Power at Teeth","p/t");
                    }
                    System.println("GearStat.compute() POWER");
                    var pot=info.currentPower/info.rearDerailleurSize.toDouble();
                    System.println("GearStat.compute() Sprocket "+info.rearDerailleurIndex+" PowerOnTeeths="+pot+"W/t "+diffTime+"ms");
                    powerStats.add(info.rearDerailleurIndex,pot);
                    stats.put(:power,powerStats);
                    // TODO Compute power/teeth
                    // TODO Compute time on sprocket
                    // TODO Compute distance on sprocket
                }
            }else if(prefered==CADENCE&&info.currentCadence!=null){
                if(info.currentCadence>0){
                    System.println("GearStat.compute() CADENCE");
                    // TODO Compute time on sprocket
                    // TODO Compute distance on sprocket
                }
            } else {
                System.println("GearStat.compute() DEFAULT");
                // TODO Compute time on sprocket
                // TODO Compute distance on sprocket
            }
            setLast(info);
        }
    }
    private function setLast(info as Activity.Info){
        System.println("GearStat.compute setLast");
        lastDistance=info.elapsedDistance;
        lastTimerTime=info.timerTime;
    }

    public function print() as Void {
        System.println("GearStat.print");
        stats.get(:power).print();
    }

}

public class SprocketStats {
    
    class Stat {
        var sum=0 as Numeric;
        var count=0 as Numeric;
        function toString() as String {
            return "Avg="+(count==0?0:sum/count.toDouble()+" ("+sum+"/"+count+")");
        }
    }

    private var name as String;
    private var unit as String;
    private var gears as Array<Stat>;

    public function initialize(gearMaxSize as Number, name as String, unit as String) {
        self.name=name;
        self.unit=unit;
        gears=new[gearMaxSize] as Array<Stat>;
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

    public function print() as Void {
        System.println("SprocketStats["+size()+"]: "+getName()+" "+getUnit());
        for(var i=0;i<gears.size();i++){
            System.println(i+". Sprocket "+gears[i].toString());
        }
    }
}