import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;

class GearStatistic {


    enum PreferedMeasure {
        AUTO,
        CADENCE,
        POWER
    }

    private var lastDistance=null as Float;
    private var lastTimerTime=0 as Number;
    private var prefered as PreferedMeasure;
    private var currentIndex=null as Number;
    private var stats={} as Dictionary<Symbol,SprocketStats>;

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
        info.elapsedDistance=10*(System.getClockTime().hour*360000+System.getClockTime().min*6000+System.getClockTime().sec*100+Math.rand()%100)/10f;
        if(System.getClockTime().sec%20==3){
            info.currentPower=null;
            info.currentCadence=null;
            System.println("GearStat.compute() DEBUG Power, Cadence set NULL");
        }
        System.println("GearStat.compute() DEBUG Derailleur"+info.frontDerailleurSize+"/"+info.rearDerailleurSize+"["+info.rearDerailleurIndex+"] cadence="+info.currentCadence+" power="+info.currentPower);
        computeGraph(info);
    }
    (:release)
    public function compute(info as Activity.Info) {
        computeGraph(info);
    }
    private  function computeGraph(info as Activity.Info) {
        if(info==null || info.frontDerailleurSize==null || info.rearDerailleurSize==null){
            currentIndex=null;
            return;
        }
        var elapsedDistance=info.elapsedDistance==null?0f:info.elapsedDistance;
        if(lastDistance==null){
            lastDistance=elapsedDistance;
        }
        System.println("GearStat.computeGraph() timerState="+info.timerState+" distance="+elapsedDistance+" / "+lastDistance);
        var diffDistance=elapsedDistance-lastDistance;
        System.println("GearStat.computeGraph() timerState="+info.timerState+"     diff="+diffDistance);
        if(lastTimerTime==Activity.TIMER_STATE_OFF&&info.timerState==Activity.TIMER_STATE_ON){
            System.println("GearStat.computeGraph() START");
            stats={} as Dictionary<Symbol,SprocketStats>;
            lastDistance=elapsedDistance;
        } else if((info.timerState==Activity.TIMER_STATE_ON||info.timerState==Activity.TIMER_STATE_OFF)&&diffDistance!=0){
            
            System.println("GearStat.computeGraph() PLAY elapsedDistance="+info.elapsedDistance+"-"+lastDistance);

            var distanceStats=stats.get(:distance) as SprocketStats;
            if(stats.get(:distance)==null){
                distanceStats=new SprocketStats(info.rearDerailleurMax,"Distance on Gear","m",SprocketStats.TYPE_SUM,Graphics.COLOR_BLUE);
            }

            if((prefered==POWER||prefered==AUTO)&&info.currentPower!=null){
                if(info.currentPower>0&&info.rearDerailleurSize!=0&&info.rearDerailleurSize!=AntPlus.FRONT_GEAR_INVALID){
                    var powerStats=stats.get(:power) as SprocketStats;
                    if(stats.get(:power)==null){
                        powerStats=new SprocketStats(info.rearDerailleurMax,"Power on Gear","W",SprocketStats.TYPE_AVG,Graphics.COLOR_DK_RED);
                    }
                    var powerTeeth=stats.get(:powerTeeths) as SprocketStats;
                    if(stats.get(:powerTeeths)==null){
                        powerTeeth=new SprocketStats(info.rearDerailleurMax,"Power at Teeths","W/t",SprocketStats.TYPE_AVG,Graphics.COLOR_DK_GREEN);
                    }        
                    System.println("GearStat.computeGraph() by POWER Sprocket "+info.rearDerailleurIndex+" on Power="+info.currentPower+"W and Distance="+diffDistance+"m");
                    currentIndex=info.rearDerailleurIndex;
                    powerStats.addDiff(info.rearDerailleurIndex,info.currentPower,diffDistance);
                    stats.put(:power,powerStats);

                    powerTeeth.addDiff(info.rearDerailleurIndex,info.currentPower/info.rearDerailleurSize,diffDistance);
                    stats.put(:powerTeeths,powerTeeth);

                    distanceStats.add(info.rearDerailleurIndex,diffDistance);
                    stats.put(:distance,distanceStats);
                }
                lastTimerTime=info.timerTime;
            }else if((prefered==CADENCE||prefered==AUTO)&&info.currentCadence!=null){
                if(info.currentCadence>0){
                    System.println("GearStat.computeGraph() by CADENCE "+info.currentCadence+" on Distance="+diffDistance+"m");
                    distanceStats.addDiff(info.rearDerailleurIndex,1,diffDistance);
                    stats.put(:distance,distanceStats);
                }
            } else {
                System.println("GearStat.computeGraph() by DEFAULT "+info.currentCadence+" on Distance="+diffDistance+"m");
                distanceStats.addDiff(info.rearDerailleurIndex,1,diffDistance);
                stats.put(:distance,distanceStats);
            }
            lastDistance=elapsedDistance;
        } else if(lastTimerTime==Activity.TIMER_STATE_PAUSED){
            System.println("GearStat.computeGraph() PAUSE");
            lastDistance=elapsedDistance;
        } else if(lastTimerTime==Activity.TIMER_STATE_STOPPED&&info.timerState==Activity.TIMER_STATE_OFF){
            System.println("GearStat.computeGraph() RESET");
            stats={} as Dictionary<Symbol,SprocketStats>;
            lastDistance=elapsedDistance;
        }
        lastTimerTime=info.timerState;
    }
    private function reset() as Void {
        stats={} as Dictionary<Symbol,SprocketStats>;
    }

    public function print() as Void {
        System.println("GearStat.print");
        //stats.get(:power).print();
    }
    public function draw(dc as Dc, locX as Number, locY as Number, width as Number, height as Number) as Void{
        //dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
        //dc.drawRectangle(locX,locY,width,height);
        if(stats.size()==0){
            dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
            dc.drawText(locX+width/2,locY+height/2,Graphics.FONT_SMALL,"No Data",Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }
        var ss=(stats.values() as Array)[System.getClockTime().sec/(60/stats.size())];
        ss.print();
        var max=ss.getValue(0);
        //var maxI=0;
        for(var i=1;i<ss.size();i++){
            if(max<ss.getValue(i)){
                //maxI=i;
                max=ss.getValue(i);
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
                var value=ss.getValue(i);
                if(value!=0){
                    var textValue="" as String;
                    if(value>950){
                        textValue=(value/1000f).format("%0.2f")+"k"+ss.getUnit();
                    } else {
                        textValue=value.format("%d")+""+ss.getUnit();
                    }
                    if(i==currentIndex){
                        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
                    } else {
                        dc.setColor(ss.getColor(),Graphics.COLOR_TRANSPARENT);
                    }
                    dc.fillRoundedRectangle(locX,y,ks*value,h,h/6);    
                    dc.drawText(locX+width,y+hf+(h+space)/2,Graphics.FONT_SMALL,textValue,Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
                    
                    dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
                    dc.drawText(hf+locX+1,y+hf+(h+space)/2+1,Graphics.FONT_SMALL,(i+1),Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
                    dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
                    dc.drawText(hf+locX,y+hf+(h+space)/2,Graphics.FONT_SMALL,(i+1),Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

                    dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
                    dc.drawRoundedRectangle(locX,y,ks*value,h,h/6);
                }
                y+=h+space;
            }
        }
        //dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        //dc.drawText(locX-1,locY-1,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        //dc.setColor(Graphics.COLOR_DK_GRAY,Graphics.COLOR_TRANSPARENT);
        //dc.drawText(locX+1,locY+1,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
        dc.drawText(locX,locY,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_LEFT);
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

    enum Type_Value {
        TYPE_AVG,TYPE_SUM,TYPE_COUNT
    }
    private var type as Type_Value;
    private var name as String;
    private var unit as String;
    private var gears as Array<Stat>;
    private var color as Graphics.ColorType;

    public function initialize(gearMaxSize as Number, name as String, unit as String, type as Type_Value, color as Graphics.ColorType) {
        self.type=type;
        self.color=color;
        self.name=name;
        self.unit=unit;
        gears=new[gearMaxSize] as Array<Stat>;
        reset();
    }

    public function add(gearIndex as Number,value as Numeric) as Void {
        gears[gearIndex].sum+=value;
        gears[gearIndex].count+=1;
    }

    public function addDiff(gearIndex as Number,value as Numeric, range as Numeric) as Void {
        gears[gearIndex].sum+=value*range;
        gears[gearIndex].count+=range;
    }

    public function getSum(gearIndex as Number) as Numeric{
        return gears[gearIndex].sum;
    }
    public function getCount(gearIndex as Number) as Numeric{
        return gears[gearIndex].count;
    }
    public function getAvg(gearIndex as Number) as Numeric{
        return getCount(gearIndex)>0?getSum(gearIndex)/getCount(gearIndex).toDouble():0;
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
    public function setColor(color as Graphics.ColorType) as Void{
        self.color=color;
    }
    public function getValue(gearIndex as Number) as Numeric{
        switch(type){
            case TYPE_AVG:
                return getAvg(gearIndex);
            case TYPE_SUM:
                return gears[gearIndex].sum;
            case TYPE_COUNT:
                return gears[gearIndex].count;
            default:
                return 0;
        }
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
            System.println(i+". Sprocket "+getValue(i)+getUnit());
        }
    }
}