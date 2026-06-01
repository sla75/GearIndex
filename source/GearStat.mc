import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Graphics;
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
    private var currentIndex=null as Number;
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
        computePowerOnSprocket(info);
    }
    (:release)
    public function compute(info as Activity.Info) {
        computePowerOnSprocket(info);
    }
    private  function computePowerOnSprocket(info as Activity.Info) {
        if(info==null || info.frontDerailleurSize==null || info.rearDerailleurSize==null){
            currentIndex=null;
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
                        powerStats=new SprocketStats(info.rearDerailleurMax,"Power on Sprocket","W",Graphics.COLOR_DK_RED);
                    }
                    System.println("GearStat.compute() Sprocket "+info.rearDerailleurIndex+" PowerOnSprocket="+info.currentPower+"W "+diffTime+"ms");
                    currentIndex=info.rearDerailleurIndex;
                    powerStats.addDiff(info.rearDerailleurIndex,info.currentPower,diffTime);
                    stats.put(:power,powerStats);

                    var distanceStats=stats.get(:distance) as SprocketStats;
                    if(stats.get(:distance)==null){
                        distanceStats=new SprocketStats(info.rearDerailleurMax,"Distance on Sprocket","m",Graphics.COLOR_BLUE);
                    }
                    System.println("GearStat.compute() Sprocket "+info.rearDerailleurIndex+" Distance="+diffDistance+"m");
                    distanceStats.addDiff(info.rearDerailleurIndex,1,diffDistance);
                    stats.put(:distance,distanceStats);
                    // TODO Compute power/sprocket
                    // TODO Compute time on sprocket
                    // TODO Compute distance on sprocket
                }
                lastTimerTime=info.timerTime;
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
            stats.get(:power).print();
        }
    }
    private function reset() as Void {
        stats={} as Dictionary<Symbol,SprocketStats>;
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
    public function draw(dc as Dc, locX as Number, locY as Number, width as Number, height as Number) as Void{
        //dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
        //dc.drawRectangle(locX,locY,width,height);
        var ss=null;
        switch(System.getClockTime().sec/50){
            case 0:
                System.println("Draw :power");
                ss=stats.get(:power) as SprocketStats;
                break;
            default:
            System.println("Draw :distance");
                ss=stats.get(:distance) as SprocketStats;
        }
        if(ss==null){
            return;
        }
        
        var max=ss.getAvg(0);var maxI=0;
        for(var i=1;i<ss.size();i++){
            if(max<ss.getAvg(i)){
                maxI=i;
                max=ss.getAvg(i);
            }
        }
        if(max!=0){
            var ks=0.75f*width/max.toFloat();
            var space=2;
            //var h=(height/2-(2*(ss.size()-1)))/ss.size();
            var h=Graphics.getFontHeight(Graphics.FONT_SMALL);
            var hf=Graphics.getFontDescent(Graphics.FONT_SMALL)/3;
            var y=locY+(height/2)-(h*ss.size()/2)-(space*(ss.size()-1)/2);
            dc.setPenWidth(2);
            for(var i=0;i<ss.size();i++){
                var avg=ss.getAvg(i);
                if(avg!=0){
                    if(i==currentIndex){
                        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
                    } else {
                        dc.setColor(ss.getColor(),Graphics.COLOR_TRANSPARENT);
                    }
                    dc.fillRoundedRectangle(locX,y,ks*avg,h,h/6);    
                    dc.drawText(locX+width,y+hf+(h+space)/2,Graphics.FONT_SMALL,avg.toNumber()+ss.getUnit(),Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
                    
                    dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
                    dc.drawText(hf+locX+1,y+hf+(h+space)/2+1,Graphics.FONT_SMALL,(i+1),Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
                    dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
                    dc.drawText(hf+locX,y+hf+(h+space)/2,Graphics.FONT_SMALL,(i+1),Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

                    dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
                    dc.drawRoundedRectangle(locX,y,ks*avg,h,h/6);
                }
                y+=h+space;
            }
        }
        dc.setColor(Graphics.COLOR_DK_GRAY,Graphics.COLOR_TRANSPARENT);
        dc.drawText(locX+width/2+1,locY+height/2+1,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        dc.drawText(locX+width/2,locY+height/2,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
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
    private var color as Graphics.ColorType;

    public function initialize(gearMaxSize as Number, name as String, unit as String, color as Graphics.ColorType) {
        self.name=name;
        self.unit=unit;
        self.color=color;
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
    public function getColor() as Number{
        return color;
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
        System.println("SprocketStats["+size()+"]: "+getName());
        for(var i=0;i<gears.size();i++){
            System.println(i+". Sprocket "+getAvg(i)+getUnit());
        }
    }
}