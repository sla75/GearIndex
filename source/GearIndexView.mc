import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

class GearIndexView extends SlavicsSimpleDataField {

    public static const xBATTERY_STATUS_TEXT = ["0","New","Good","Ok","Low","Crit.","Unkn.","Inv.","Cnt"] as Array<String>;
    private var rearShift=new RearShifting() as RearShifting;
    private var batteries=[] as Array<RearShifting.BatteryData>;
    //private const INVALID_SHIFTS=[:shiftFailureCount,:invalidInboardShiftCount,:invalidOutboardShiftCount] as Array<Symbol>;
    private const RD_totalShifts_unit=Application.loadResource(Rez.Strings.RD_totalShifts_unit);
    /***
    private var fails={
            INVALID_SHIFTS[0]=>{:count=>0,:change=>false},
            INVALID_SHIFTS[1]=>{:count=>0,:change=>false},
            INVALID_SHIFTS[2]=>{:count=>0,:change=>false},
        } as Dictionary<Symbol,Dictionary<Symbol,Object>>;
    /***/
    
    
        /***
    private var failLabel=new Text({
            :text=>"fail",
            :color=>Graphics.COLOR_DK_RED,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
        });/***/
    private const TOTAL_SHIFTS_TIME_COUNTER=10 as Number;
    private var totalShiftsTime=TOTAL_SHIFTS_TIME_COUNTER as Number;
    private var unitTeeths as String;
    private var versionTest=null as String;
    private var lastIndex=-1 as Number;
    private var colorMode as ColorMode;
    private var propDebugMode=false as Boolean;
    private var gearFIT as GearFitContributions or Null;
    private var gearStatistic as GearStatistic;
    private var screen=null as Screen;
    private var debugData=[] as Array<Dictionary>;
    private var totalShiftsNum=0 as Number;

    enum Screen {
        FULL,FIELD
    }

    function initialize() {
        System.println("GearIndexView.initialize()");
        SlavicsSimpleDataField.initialize();
        Properties.setValue("property_fitFileSaving",Properties.getValue("property_fitFileSaving")==null?true:Properties.getValue("property_fitFileSaving") as Boolean);
        gearFIT = Properties.getValue("property_fitFileSaving")?new GearFitContributions(self):null;
        unitTeeths=Application.loadResource(Rez.Strings.unitTeeths);
        var pos=Application.loadResource(Rez.Strings.AppName).find("Test") as Number or Null;
        if(pos!=null){
            versionTest=Application.loadResource(Rez.Strings.version);
        }
        self.setTextLabel(Application.loadResource(Rez.Strings.label));
        Properties.setValue("property_version",Application.loadResource(Rez.Strings.version));
        Properties.setValue("property_showTeeth",Properties.getValue("property_showTeeth")==null?true:Properties.getValue("property_showTeeth") as Boolean);
        Properties.setValue("property_debugMode",Properties.getValue("property_debugMode")==null?false:Properties.getValue("property_debugMode") as Boolean);
        Properties.setValue("property_numberOfShifts",Properties.getValue("property_numberOfShifts")==null?true:Properties.getValue("property_numberOfShifts") as Boolean);
        colorMode=new ColorMode();
        gearStatistic=new GearStatistic(GearStatistic.POWER,colorMode);
        handleSettingUpdate();
    }

    function onLayout(dc as Dc) as Void {
        System.println("GearIndexView.onLayout() "+dc.getWidth()+"x"+dc.getHeight());
        SlavicsSimpleDataField.onLayout(dc);
        if(dc.getHeight()==System.getDeviceSettings().screenHeight){
            screen=FULL;
            labelArea.setJustification(Graphics.TEXT_JUSTIFY_RIGHT);
            labelArea.height=dc.getHeight()*0.15f;

            valueArea.locX=rim;
            valueArea.locY=labelArea.height;
            valueArea.width=dc.getWidth()-2*rim;
            valueArea.height=dc.getHeight()-labelArea.height-rim;
            valueArea.setJustification(Graphics.TEXT_JUSTIFY_RIGHT);

            topLeftLabel.setVisible(false);
            topLeftLabel.locY=labelArea.height;

            bottomLeftLabel.setVisible(false);
        } else {
            screen=FIELD;
            topLeftLabel.setVisible(Properties.getValue("property_showTeeth") as Boolean);
            bottomLeftLabel.setVisible(Properties.getValue("property_numberOfShifts") as Boolean);
        }
        /***
        System.println("PartNumber: "+System.getDeviceSettings().partNumber);
        System.println("Screen: "+dc.getWidth()+"x"+dc.getHeight());
        System.println("|Font|Height|Ascent|Descent|");
        System.println("|---:|---:|---:|---:|");
        System.println("|FONT_XTINY|"+Graphics.getFontHeight(Graphics.FONT_XTINY)+"|"+Graphics.getFontAscent(Graphics.FONT_XTINY)+"|"+Graphics.getFontDescent(Graphics.FONT_XTINY)+"|");
        System.println("|FONT_TINY|"+Graphics.getFontHeight(Graphics.FONT_TINY)+"|"+Graphics.getFontAscent(Graphics.FONT_TINY)+"|"+Graphics.getFontDescent(Graphics.FONT_TINY)+"|");
        System.println("|FONT_SMALL|"+Graphics.getFontHeight(Graphics.FONT_SMALL)+"|"+Graphics.getFontAscent(Graphics.FONT_SMALL)+"|"+Graphics.getFontDescent(Graphics.FONT_SMALL)+"|");
        System.println("|FONT_MEDIUM|"+Graphics.getFontHeight(Graphics.FONT_MEDIUM)+"|"+Graphics.getFontAscent(Graphics.FONT_MEDIUM)+"|"+Graphics.getFontDescent(Graphics.FONT_MEDIUM)+"|");
        System.println("|FONT_LARGE|"+Graphics.getFontHeight(Graphics.FONT_LARGE)+"|"+Graphics.getFontAscent(Graphics.FONT_LARGE)+"|"+Graphics.getFontDescent(Graphics.FONT_LARGE)+"|");
        /***/
    }
    public function handleSettingUpdate() as Void {
        System.println("GearIndexView.onSettingsChanged()");
        topLeftLabel.setVisible(Properties.getValue("property_showTeeth") as Boolean);
        bottomLeftLabel.setVisible(Properties.getValue("property_numberOfShifts") as Boolean);
        if(Properties.getValue("property_numberOfShifts") as Boolean){
            totalShiftsTime=TOTAL_SHIFTS_TIME_COUNTER;
        }
        propDebugMode=Properties.getValue("property_debugMode") as Boolean;
        if(Properties.getValue("property_fitFileSaving")){
            gearFIT = gearFIT==null?new GearFitContributions(self):gearFIT;
        } else {
            gearFIT=null;
        }
        
        colorMode.handleSettingUpdate();
    }
    /***
    function onShow() {
        System.println("SlavicsGearRearView.onShow()");
        SlavicsSimpleDataField.onShow();
        self.setTextLabel(label);
    }
    /***/
    private var invalidBoardShiftCount=0 as Number;
    function compute(info as Activity.Info) as Void {
        SlavicsSimpleDataField.compute(info);
        gearStatistic.compute(info);
        colorMode.compute();
        SlavicsSimpleDataField.setColors(colorMode.getColors());

        batteries=rearShift.getBatteries() as Array<RearShifting.BatteryData>;
        if(gearFIT!=null){
            for(var i=0;i<batteries.size();i++){
                if(i==0x02){ // RD Battery
                    var rdBat=batteries[i] as Dictionary;
                    gearFIT.addRdBatteryStatus(rdBat.get(:status));
                    gearFIT.addRdBatteryVoltage(rdBat.get(:voltage));
                }
            }
        }

        var rds=rearShift.getRearDerailleurStatus() as AntPlus.DerailleurStatus;
        topLeftLabel.setColor(colorMode.getFieldColor(:label));
        if(rds!=null){
            if(rds.gearIndex!=null&&rds.gearIndex!=AntPlus.REAR_GEAR_INVALID){
                if(lastIndex<0){
                    lastIndex=rds.gearIndex;
                }
                if(gearFIT!=null){
                    gearFIT.setIndex(rds.gearIndex);
                    if(rearShift.getFrontDerailleurStatus()!=null){
                        gearFIT.setDerailleurs(rearShift.getFrontDerailleurStatus().gearSize,rds.gearSize);
                    }
                }
                if(rds.gearIndex!=lastIndex){
                    valueArea.setColor(colorMode.getFieldColor(:valueChange));
                    totalShiftsNum+=rds.gearIndex>lastIndex?rds.gearIndex-lastIndex:lastIndex-rds.gearIndex;
                    if(gearFIT!=null){
                        gearFIT.changeIndex(rds.gearIndex-lastIndex);
                        bottomLeftLabel.setText(gearFIT.getTotalShifts().toString()+RD_totalShifts_unit);
                    } else {
                        System.println("GearIndex.compute() totalShiftsNum="+totalShiftsNum);
                        bottomLeftLabel.setText(totalShiftsNum.toString());
                    }

                    if(Properties.getValue("property_numberOfShifts") as Boolean){
                        bottomLeftLabel.setColor(colorMode.getFieldColor(:label));
                        totalShiftsTime=TOTAL_SHIFTS_TIME_COUNTER;
                        bottomLeftLabel.setVisible(true);
                    }
                    if (Attention has :playTone) {
                        if(rds.gearIndex==rds.gearMax-1){
                            Attention.playTone(Attention.TONE_ALERT_HI);
                        } else if (rds.gearIndex==0) {
                            Attention.playTone(Attention.TONE_ALERT_LO);
                        }
                    }
                } else if(rds.gearIndex==0||rds.gearIndex==rds.gearMax-1){
                    valueArea.setColor(colorMode.getFieldColor(:valueEdge));
                }
                setTextValue((rds.gearIndex+1).toString());
                topLeftLabel.setText(rds.gearSize+unitTeeths);
                lastIndex=rds.gearIndex;
            } else {
                setTextValue("--");
                topLeftLabel.setText("");
                lastIndex=-1;
            }

            if(invalidBoardShiftCount!=(rds.invalidInboardShiftCount+rds.invalidOutboardShiftCount)){
                invalidBoardShiftCount=rds.invalidInboardShiftCount+rds.invalidOutboardShiftCount;
                if (Attention has :playTone) {
                    if(rds.gearIndex==rds.gearMax-1){
                        Attention.playTone(Attention.TONE_ALERT_HI);
                    } else if (rds.gearIndex==0) {
                        Attention.playTone(Attention.TONE_ALERT_LO);
                    }
                }
            }
        } else {
            topLeftLabel.setText("");
            valueArea.setColor(colorMode.getFieldColor(:error));
            setTextValue("xx");
            lastIndex=-2;
        }

        if(totalShiftsTime>=0){
            if(totalShiftsTime>0){
                totalShiftsTime--;
            } else {
                totalShiftsTime=-1;
                bottomLeftLabel.setVisible(false);
            }
        }
        if(propDebugMode){
            debugData=[] as Array<Dictionary>;
            switch(info.timerState){
                case 0:
                    debugData.add({:label=>"info.timerState",:value=>"OFF[0]"});
                    break;
                case 1:
                    debugData.add({:label=>"info.timerState",:value=>"STOPPED[1]"});
                    break;
                case 2:
                    debugData.add({:label=>"info.timerState",:value=>"PAUSED[2]"});
                    break;
                case 3:
                    debugData.add({:label=>"info.timerState",:value=>"ON[3]"});
                    break;
                default:
                    debugData.add({:label=>"info.timerState",:value=>"unknown["+info.timerState+"]"});
            }
            debugData.add({:label=>"info.currentSpeed",:value=>info.currentSpeed});
            debugData.add({:label=>"info.currentCadence",:value=>info.currentCadence});
            debugData.add({:label=>"info.currentPower",:value=>info.currentPower});
            debugData.add({:break=>true});
            /***
            debugData.add({:label=>"info.distanceToDestination",:value=>info.distanceToDestination});
            debugData.add({:label=>"info.elapsedDistance",:value=>info.elapsedDistance});
            debugData.add({:label=>"info.nameOfNextPoint",:value=>info.nameOfNextPoint});
            debugData.add({:label=>"info.distanceToNextPoint",:value=>info.distanceToNextPoint});
            /***/
            
            debugData.add({:label=>"info.frontDerailleurIndex",:value=>info.frontDerailleurIndex});
            debugData.add({:label=>"info.frontDerailleurMax",:value=>info.frontDerailleurMax});
            debugData.add({:label=>"info.frontDerailleurSize",:value=>info.frontDerailleurSize});
            debugData.add({:label=>"info.rearDerailleurIndex",:value=>info.rearDerailleurIndex});
            debugData.add({:label=>"info.rearDerailleurMax",:value=>info.rearDerailleurMax});
            debugData.add({:label=>"info.rearDerailleurSize",:value=>info.rearDerailleurSize});
            debugData.add({:break=>true});

            if(rearShift.getFrontDerailleurStatus()!=null){
                debugData.add({:label=>"FDS.gearIndex",:value=>checkGearError(rearShift.getFrontDerailleurStatus().gearIndex,AntPlus.FRONT_GEAR_INVALID)});
                debugData.add({:label=>"FDS.gearMax",:value=>checkGearError(rearShift.getFrontDerailleurStatus().gearMax,AntPlus.MAX_GEARS_INVALID)});
                debugData.add({:label=>"FDS.gearSize",:value=>rearShift.getFrontDerailleurStatus().gearSize});
            } else {
                debugData.add({:label=>"FrontDerailleurStatus",:value=>null});
            }
            debugData.add({:break=>true});
            if(rearShift.getRearDerailleurStatus()!=null){
                debugData.add({:label=>"RDS.gearIndex",:value=>checkGearError(rearShift.getRearDerailleurStatus().gearIndex,AntPlus.REAR_GEAR_INVALID)});
                debugData.add({:label=>"RDS.gearMax",:value=>checkGearError(rearShift.getRearDerailleurStatus().gearMax,AntPlus.MAX_GEARS_INVALID)});
                debugData.add({:label=>"RDS.gearSize",:value=>rearShift.getRearDerailleurStatus().gearSize});
                debugData.add({:label=>"RDS.invalidInboardShiftCount",:value=>rearShift.getRearDerailleurStatus().invalidInboardShiftCount});
                debugData.add({:label=>"RDS.invalidOutboardShiftCount",:value=>rearShift.getRearDerailleurStatus().invalidOutboardShiftCount});
                debugData.add({:label=>"RDS.shiftFailureCount",:value=>rearShift.getRearDerailleurStatus().shiftFailureCount});
                if(rearShift.getBatteries().size()>0){
                    debugData.add({:break=>true});
                    for(var j=0;j<rearShift.getBatteries().size();j++){
                        var batt=(rearShift.getBatteries() as Array)[j];
                        debugData.add({:label=>"RDS."+batt.get(:identifier)+".batteryStatus",:value=>RearShifting.getBatteryStatusString(batt.get(:batteryStatus))+"["+batt.get(:batteryStatus)+"]"});
                        debugData.add({:label=>"RDS."+batt.get(:identifier)+".batteryVoltage",:value=>batt.get(:batteryVoltage)});
                        debugData.add({:label=>"RDS."+batt.get(:identifier)+".operatingTime",:value=>batt.get(:operatingTime)});
                    }
                }
            } else {
                debugData.add({:label=>"RearDerailleurStatus",:value=>null});
            }
        }

    }
    private function checkGearError(gear as Number or Null,checkGear as Number or Null) as String {
        if(gear==null){
            return "<null>";
        } else if(gear==checkGear){
            return "Invalid["+gear+"]";
        }
        return gear.toString();
    }
    var battIcon=new BatteryIcon({:font=>WatchUi.loadResource(Rez.Fonts.BatteryMedium),:justification=>Graphics.TEXT_JUSTIFY_RIGHT});
    var battFont=Graphics.FONT_XTINY;
    public function onUpdate(dc as Dc) as Void {
        SlavicsSimpleDataField.onUpdate(dc);
        if(screen==FIELD){
            onUpdateField(dc);
        } else {
            if(!propDebugMode){
                onUpdateFullScreen(dc);
            } else {
                onUpdateDebugMode(dc);
            }
        }
    }
    public function onUpdateFullScreen(dc as Dc) as Void {
        System.println("GearIndexView.onUpdateFullScreen()");
        gearStatistic.draw(dc,valueArea.locX,valueArea.locY,valueArea.width,valueArea.height);
    }
    public function onUpdateDebugMode(dc as Dc) as Void {
        System.println("GearIndexView.onUpdateDebugMode()");
        var yLine=1;
        for(var i=0;i<debugData.size();i++){
            var dict=(debugData as Array)[i] as Dictionary;
            if(dict.get(:break)!=null){
                dc.setPenWidth(2);
                dc.setColor(colorMode.getFieldColor(:label),Graphics.COLOR_TRANSPARENT);
                dc.drawLine(2,yLine+1,dc.getWidth()-2,yLine+1);
                //yLine+=Graphics.getFontDescent(Graphics.FONT_TINY);
                yLine+=3;
                continue;
            }
            var label=dict.get(:label)+": ";
            var td=dc.getTextDimensions(label,Graphics.FONT_TINY);
            dc.setColor(colorMode.getFieldColor(:label),Graphics.COLOR_TRANSPARENT);
            dc.drawText(1,yLine,Graphics.FONT_TINY,label,Graphics.TEXT_JUSTIFY_LEFT);
            var value=dict.get(:value);
            if(value==null){
                //dc.setColor(colorMode.getFieldColor(:label),Graphics.COLOR_TRANSPARENT);
                value="<null>";
            } else {
                dc.setColor(colorMode.getFieldColor(:value),Graphics.COLOR_TRANSPARENT);
            }
            dc.drawText(1+td[0],yLine,Graphics.FONT_TINY,value,Graphics.TEXT_JUSTIFY_LEFT);
            yLine+=td[1];
        }
        
    }
    public function onUpdateField(dc as Dc) as Void {
        System.println("GearIndexView.onUpdateField()");
        
        if(versionTest!=null){
            dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
            dc.drawText(1,1,Graphics.FONT_XTINY,versionTest,Graphics.TEXT_JUSTIFY_LEFT);
        }

        if(batteries.size()>0){
            // Draw batteries
            var bLocX=dc.getWidth()-rim;
            var bLocY=dc.getHeight()-rim-Graphics.getFontHeight(battIcon.getFont());
            battIcon.locY=dc.getHeight()-rim-Graphics.getFontAscent(battIcon.getFont());
            battIcon.setNightMode(System.getDeviceSettings().isNightModeEnabled);
            for(var i=0;i<batteries.size();i++){
                var bd=(batteries as Array<RearShifting.BatteryData>)[i] as RearShifting.BatteryData;
                // Vertically
                if(bd.get(:batteryStatus)>0) {

                    battIcon.locX=bLocX;
                    battIcon.locY=bLocY;
                    battIcon.setStatus(bd.get(:batteryStatus));
                    battIcon.draw(dc);

                    dc.setColor(colorMode.getFieldColor(:label),Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                        bLocX-battIcon.getWidth(dc)-2,
                        bLocY+(Graphics.getFontHeight(battIcon.getFont())-Graphics.getFontHeight(battFont)),
                        battFont,bd.get(:name),Graphics.TEXT_JUSTIFY_RIGHT);

                    bLocY-=Graphics.getFontHeight(battIcon.getFont())+3;
                }
            }
        }
    }

    function onTimerReset() {
        System.println("GearIndexView.onTimerReset");
        totalShiftsNum=0;
    	if(gearFIT!=null){
            gearFIT.onTimerReset();
        }
    }
    
    function onTimerPause() {
        System.println("GearIndexView.onTimerPause");
        if(gearFIT!=null){
    	    gearFIT.onTimerPause();
        }
    }
    
    function onTimerResume() {
        System.println("GearIndexView.onTimerResume");
        if(gearFIT!=null){
    	    gearFIT.onTimerResume();
        }
    }
    
    function onTimerStart() {
        System.println("GearIndexView.onTimerStart");
        if(gearFIT!=null){
    	    gearFIT.onTimerStart();
        }
    }
    
    function onTimerStop() {
        System.println("GearIndexView.onTimerStop");
        if(gearFIT!=null){
    	    gearFIT.onTimerStop();
            gearStatistic.print();
        }
    }
}
/***
XTINY edge840  11  8 3
XTINY edge1050 21 15 6

TINY  edge840  14 10 4
TINY  edge1050 28 20 8

edge840
#   HH  AA DD Name
0.  11   8  3 FONT_XTINY
1.  14  10  4 FONT_TINY
2.  17  12  5 FONT_SMALL
3.  19  14  5 FONT_MEDIUM
4.  31  22  9 FONT_LARGE
5.  35  28  7 FONT_NUMBER_MILD
6.  42  33  9 FONT_NUMBER_MEDIUM
7.  55  43 12 FONT_NUMBER_HOT
8.  67  53 14 FONT_NUMBER_THAI_HOT

edge1050
#   HH  AA DD Name
0.  21  15  6 FONT_XTINY
1.  28  20  8 FONT_TINY
2.  33  24  9 FONT_SMALL
3.  38  27 11 FONT_MEDIUM
4.  61  44 17 FONT_LARGE
5.  71  56 15 FONT_NUMBER_MILD
6.  82  65 17 FONT_NUMBER_MEDIUM
7. 109  86 23 FONT_NUMBER_HOT
8. 136 108 28 FONT_NUMBER_THAI_HOT

1/5 FONT_MEDIUM,FONT_NUMBER_HOT



/***/