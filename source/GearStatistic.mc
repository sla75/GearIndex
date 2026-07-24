import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import LogMonkey;

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
    private var colorMode as ColorMode;
    protected var valueArea=new WatchUi.TextArea({
            :text=>"",
            :color=>Graphics.COLOR_BLACK,
            :font=>[Graphics.FONT_NUMBER_HOT,Graphics.FONT_NUMBER_MEDIUM,Graphics.FONT_NUMBER_MILD,Graphics.FONT_LARGE,Graphics.FONT_MEDIUM],
            :justification => Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER,
        }) as TextArea;

    public function initialize(preferedMeasure as PreferedMeasure, colorMode as ColorMode) {
        self.prefered=preferedMeasure;
        self.colorMode=colorMode;
    }
    
    public function compute(info as Activity.Info, derailleur as Derailleur) {
        if(derailleur==null || !derailleur.isFrontValidStatus() || !derailleur.isRearValidStatus()){
            currentIndex=null;
            return;
        }
        var elapsedDistance=info.elapsedDistance==null?0f:info.elapsedDistance;
        if(lastDistance==null){
            lastDistance=elapsedDistance;
        }
        LogMonkey.Debug.logMessage("GearStat.computeGraph()","timerState="+info.timerState+" distance="+elapsedDistance+" / "+lastDistance);

        var diffDistance=elapsedDistance-lastDistance;
        var ts=["TIMER_STATE_OFF","TIMER_STATE_STOPPED","TIMER_STATE_PAUSED","TIMER_STATE_ON"] as Array<String>;
        LogMonkey.Debug.logMessage("GearStat.computeGraph()","timerState["+info.timerState+"]="+ts[info.timerState]+" diffDistance="+diffDistance);
        if(lastTimerTime==Activity.TIMER_STATE_OFF&&info.timerState==Activity.TIMER_STATE_ON){
            LogMonkey.Debug.logMessage("GearStat.computeGraph()","START");
            stats={} as Dictionary<Symbol,SprocketStats>;
            lastDistance=elapsedDistance;
        } else if((info.timerState==Activity.TIMER_STATE_ON||info.timerState==Activity.TIMER_STATE_OFF)&&diffDistance!=0){
            
            LogMonkey.Debug.logMessage("GearStat.computeGraph()","PLAY elapsedDistance="+info.elapsedDistance+"-"+lastDistance);

            var distanceStats=stats.get(:distance) as SprocketStats;
            if(stats.get(:distance)==null){
                distanceStats=new SprocketStats(derailleur.getRearStatus().gearMax,@Rez.Strings.SprocketStats_DistanceOnGear,"m",SprocketStats.TYPE_SUM);
            }

            if((prefered==POWER||prefered==AUTO)&&info.currentPower!=null){
                if(info.currentPower>0&&derailleur.isRearValidStatus()){
                    var powerStats=stats.get(:power) as SprocketStats;
                    if(stats.get(:power)==null){
                        powerStats=new SprocketStats(derailleur.getRearStatus().gearMax,@Rez.Strings.SprocketStats_PowerOnGear,"W",SprocketStats.TYPE_AVG);
                    }
                    LogMonkey.Debug.logMessage("GearStat.computeGraph()","by POWER Sprocket "+(derailleur.getRearStatus().gearIndex+1)+" on Power="+info.currentPower+"W and Distance="+diffDistance+"m");
                    currentIndex=derailleur.getRearStatus().gearIndex;
                    powerStats.addDiff(derailleur.getRearStatus().gearIndex,info.currentPower,diffDistance);
                    stats.put(:power,powerStats);

                    distanceStats.add(derailleur.getRearStatus().gearIndex,diffDistance);
                    stats.put(:distance,distanceStats);
                }
                lastTimerTime=info.timerTime;
            }else if((prefered==CADENCE||prefered==AUTO)&&info.currentCadence!=null){
                if(info.currentCadence>0){
                    LogMonkey.Debug.logMessage("GearStat.computeGraph()","by CADENCE "+info.currentCadence+" on Distance="+diffDistance+"m");
                    distanceStats.addDiff(derailleur.getRearStatus().gearIndex,1,diffDistance);
                    stats.put(:distance,distanceStats);
                }
            } else {
                LogMonkey.Debug.logMessage("GearStat.computeGraph()","by DEFAULT "+info.currentCadence+" on Distance="+diffDistance+"m");
                distanceStats.addDiff(derailleur.getRearStatus().gearIndex,1,diffDistance);
                stats.put(:distance,distanceStats);
            }
            lastDistance=elapsedDistance;
        } else if(lastTimerTime==Activity.TIMER_STATE_PAUSED){
            LogMonkey.Debug.logMessage("GearStat.computeGraph()","PAUSE");
            lastDistance=elapsedDistance;
        } else if(lastTimerTime==Activity.TIMER_STATE_STOPPED&&info.timerState==Activity.TIMER_STATE_OFF){
            LogMonkey.Debug.logMessage("GearStat.computeGraph()","RESET");
            stats={} as Dictionary<Symbol,SprocketStats>;
            lastDistance=elapsedDistance;
        }
        lastTimerTime=info.timerState;
    }
    private function reset() as Void {
        stats={} as Dictionary<Symbol,SprocketStats>;
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
        //dc.setColor(colorMode.getFieldColor(:label),Graphics.COLOR_TRANSPARENT);
        //dc.drawText(locX,locY-Graphics.getFontHeight(Graphics.FONT_MEDIUM)*1.1,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_LEFT);
        valueArea.locX=locX;
        valueArea.locY=locY-Graphics.getFontHeight(Graphics.FONT_MEDIUM)*1.5;
        valueArea.height=Graphics.getFontHeight(Graphics.FONT_MEDIUM)*3;
        valueArea.width=width*0.67;
        valueArea.setColor(colorMode.getFieldColor(:label));
        valueArea.setText(ss.getName());
        //valueArea.setText("undefined for language 'hun'");
        valueArea.draw(dc);
        //dc.setColor(Graphics.COLOR_PURPLE,Graphics.COLOR_TRANSPARENT);
        //dc.drawRectangle(valueArea.locX,valueArea.locY,valueArea.width,valueArea.height);

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
                var li=i+1;
                if(value!=0){
                    var textValue="" as String;
                    if(value>9950){
                        textValue=(value/1000f).format("%0.1f")+"k"+ss.getUnit();
                    } else if(value>950){
                        textValue=(value/1000f).format("%0.2f")+"k"+ss.getUnit();
                    } else {
                        textValue=value.format("%d")+""+ss.getUnit();
                    }

                    var indexBarColor=Graphics.COLOR_ORANGE;
                    var nonIndexBarColor=colorMode.getFieldColor(:value);
                    var indexLabelColor=colorMode.getFieldColor(:background);
                    var indexValueColor=indexBarColor;
                    var nonIndexValueColor=colorMode.getFieldColor(:value);
                    if (indexBarColor==colorMode.getFieldColor(:background)) {
                        indexBarColor=Graphics.COLOR_DK_BLUE;
                        indexLabelColor=Graphics.COLOR_WHITE;
                    }
                    /***
                    if (!colorMode.isNight) {
                        if (ss.getColor()==colorMode.getFieldColor(:background)) {
                            System.println("GearStatistic.draw DAY eq Background");
                            indexBarColor=Graphics.COLOR_WHITE;
                            nonIndexBarColor=Graphics.COLOR_BLACK;
                            indexValueColor=ss.getColor();
                            nonIndexValueColor=Graphics.COLOR_WHITE;
                        } else {
                            System.println("GearStatistic.draw DAY neq Background");
                            indexBarColor=colorMode.getFieldColor(:value);
                            nonIndexBarColor=ss.getColor();
                            indexValueColor=colorMode.getFieldColor(:background);
                            nonIndexValueColor=colorMode.getFieldColor(:background);
                        }
                    } else {
                        if (ss.getColor()==colorMode.getFieldColor(:background)) {
                            System.println("GearStatistic.draw NIGHT eq Background");
                            indexBarColor=Graphics.COLOR_WHITE;
                            nonIndexBarColor=ss.getColor();
                            indexValueColor=ss.getColor();
                            nonIndexValueColor=Graphics.COLOR_WHITE;
                        } else {
                            System.println("GearStatistic.draw NIGHT neq Background");
                            indexBarColor=colorMode.getFieldColor(:value);
                            nonIndexBarColor=ss.getColor();
                            indexValueColor=colorMode.getFieldColor(:background);
                            nonIndexValueColor=colorMode.getFieldColor(:background);
                        }
                    }
                    /***/
                    // Bar color
                    dc.setColor(li==currentIndex?indexBarColor:nonIndexBarColor,Graphics.COLOR_TRANSPARENT);
                    dc.fillRoundedRectangle(locX,y,ks*value,h,h/6);

                    // Outline
                    dc.setColor(nonIndexBarColor,Graphics.COLOR_TRANSPARENT);
                    dc.drawRoundedRectangle(locX,y,ks*value,h,h/6);
                    dc.drawText(hf+locX,y+hf+(h+space)/2,Graphics.FONT_SMALL,li,Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

                    // Left value
                    //dc.setColor(i!=currentIndex?indexBarColor:nonIndexBarColor,Graphics.COLOR_TRANSPARENT);
                    //dc.drawText(hf+locX+1,y+hf+(h+space)/2+1,Graphics.FONT_SMALL,(i+1),Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
                    dc.setColor(indexLabelColor,Graphics.COLOR_TRANSPARENT);
                    dc.drawText(hf+locX,y+hf+(h+space)/2,Graphics.FONT_SMALL,li,Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);

                    // Right label    
                    //dc.setColor(i==currentIndex?indexBarColor:nonIndexBarColor,Graphics.COLOR_TRANSPARENT);
                    //dc.drawText(locX+width+1,y+hf+(h+space)/2+1,Graphics.FONT_SMALL,textValue,Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
                    dc.setColor(li==currentIndex?indexValueColor:nonIndexValueColor,Graphics.COLOR_TRANSPARENT);                    
                    dc.drawText(locX+width,y+hf+(h+space)/2,Graphics.FONT_SMALL,textValue,Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
                    
                    
                }
                y+=h+space;
            }
        }
        //dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        //dc.drawText(locX-1,locY-1,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        //dc.setColor(Graphics.COLOR_DK_GRAY,Graphics.COLOR_TRANSPARENT);
        //dc.drawText(locX+1,locY+1,Graphics.FONT_SMALL,ss.getName(),Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
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

    public function initialize(gearMaxSize as Number, name as String or ResourceId, unit as String, type as Type_Value) {
        self.type=type;
        self.name=name instanceof ResourceId?Application.loadResource(name):name;
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
        LogMonkey.Debug.logMessage("SprocketStats.print()","Name: "+getName()+"["+size()+"]");
        for(var i=0;i<gears.size();i++){
            LogMonkey.Debug.logMessage("\tSprocket "+i,getValue(i)+" "+getUnit());
        }
    }
}