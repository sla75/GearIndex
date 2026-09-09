import Toybox.Activity;
import Toybox.AntPlus;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;
import LogMonkey;

class GearIndexView extends SlavicsSimpleDataField {

    private var derailleur=new Derailleur() as Derailleur;
    private var batteries=[] as Array<MyDevice.BatteryData>;

    //private const INVALID_SHIFTS=[:shiftFailureCount,:invalidInboardShiftCount,:invalidOutboardShiftCount] as Array<Symbol>;
    private const RD_totalShifts_unit=Application.loadResource(Rez.Strings.RD_totalShifts_unit);

    private enum {
        PROPERTY_FITFILESAVING="property_fitFileSaving",
        PROPERTY_VERSION="property_version",
        PROPERTY_MAINVALUE="property_mainValue",
        PROPERTY_MAINVALUEUNIT="property_mainValueUnit",
        PROPERTY_SHOWADDITIONALVALUES="property_showAdditionalValues",
        PROPERTY_DEBUGMODE="property_debugMode",
        //PROPERTY_NUMBEROFSHIFTS="property_numberOfShifts",
    }
    private enum {
        MAINVALUE_INDEX=1,
        MAINVALUE_TEETH=2,
    }
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
    private var versionTest=null as String;
    private var lastIndex=-1 as Number;
    private var colorMode as ColorMode;
    private var debugMode=false as Boolean;
    private var propertyMainValue=MAINVALUE_INDEX as Number;
    private var gearFIT as GearFitContributions or Null;
    private var gearStatistic as GearStatistic;
    private var screen=null as Screen;
    private var debugData=[] as Array<Dictionary>;
    private var units={:mainValue=>null,:subValue=>null} as Dictionary<String>;

    enum Screen {
        FULL,FIELD
    }

    function initialize() {
        LogMonkey.Debug.logMessage("GearIndexView.initialize()","");
        SlavicsSimpleDataField.initialize();
        gearFIT = new GearFitContributions(self);
        var pos=Application.loadResource(Rez.Strings.AppName).find("Test") as Number or Null;
        if(pos!=null){
            versionTest=Application.loadResource(Rez.Strings.version);
        }
        self.setTextLabel(Application.loadResource(Rez.Strings.label));
        Properties.setValue(PROPERTY_VERSION,Application.loadResource(Rez.Strings.version));
        //Properties.setValue(PROPERTY_SHOWTEETH,Properties.getValue(PROPERTY_SHOWTEETH)==null?true:Properties.getValue(PROPERTY_SHOWTEETH) as Boolean);
        Properties.setValue(PROPERTY_MAINVALUE,Properties.getValue(PROPERTY_MAINVALUE)==null?propertyMainValue:Properties.getValue(PROPERTY_MAINVALUE) as Number);
        Properties.setValue(PROPERTY_MAINVALUEUNIT,Properties.getValue(PROPERTY_MAINVALUEUNIT)==null?false:Properties.getValue(PROPERTY_MAINVALUEUNIT) as Boolean);

        Properties.setValue(PROPERTY_DEBUGMODE,Properties.getValue(PROPERTY_DEBUGMODE)==null?debugMode:Properties.getValue(PROPERTY_DEBUGMODE) as Boolean);
        //Properties.setValue(PROPERTY_NUMBEROFSHIFTS,Properties.getValue(PROPERTY_NUMBEROFSHIFTS)==null?true:Properties.getValue(PROPERTY_NUMBEROFSHIFTS) as Boolean);
        Properties.setValue(PROPERTY_SHOWADDITIONALVALUES,Properties.getValue(PROPERTY_SHOWADDITIONALVALUES)==null?5:Properties.getValue(PROPERTY_SHOWADDITIONALVALUES) as Number);
        Properties.setValue(PROPERTY_FITFILESAVING,Properties.getValue(PROPERTY_FITFILESAVING)==null?true:Properties.getValue(PROPERTY_FITFILESAVING) as Boolean);
        colorMode=new ColorMode();
        gearStatistic=new GearStatistic(GearStatistic.POWER,colorMode);
        initializeDebugProperties();
        onSettingsChanged();
    }
    (:debug)
    public function initializeDebugProperties() as Void {
        Properties.setValue(PROPERTY_SHOWADDITIONALVALUES,2);
        Properties.setValue(PROPERTY_MAINVALUE,MAINVALUE_INDEX);
        Properties.setValue(PROPERTY_MAINVALUEUNIT,false);
    }
    (:release)
    public function initializeDebugProperties() as Void {
    }
    public function onSettingsChanged() as Void {
        LogMonkey.Debug.logMessage("GearIndexView.onSettingsChanged()","");
        //info(:topLeft).setVisible(Properties.getValue(PROPERTY_SHOWTEETH) as Boolean);
        //info(:bottomLeft).setVisible(Properties.getValue(PROPERTY_NUMBEROFSHIFTS) as Boolean);
        var showAdditionalValues=Properties.getValue(PROPERTY_SHOWADDITIONALVALUES) as Number;
        LogMonkey.Debug.logVariable("GearIndexView.onSettingsChanged()","PROPERTY_SHOWADDITIONALVALUES",showAdditionalValues);
        visibleAdditionalValues(showAdditionalValues);
        if(showAdditionalValues==0){
            setTimer(null);
        } else {
            setTimer(showAdditionalValues);
        }
        debugMode=Properties.getValue(PROPERTY_DEBUGMODE) as Boolean;

        if(Application.loadResource(Rez.Strings.AppName).equals("GearIndexDev")){
            LogMonkey.Debug.logMessage("GearIndexView.onSettingsChanged()","Rez.Strings.AppName="+Application.loadResource(Rez.Strings.AppName)+" REVERSE debugMode="+debugMode);
        }
        gearFIT.handleSettingUpdate(Properties.getValue(PROPERTY_FITFILESAVING) as Boolean);

        propertyMainValue=Properties.getValue(PROPERTY_MAINVALUE) as Number;
        
        if(Properties.getValue(PROPERTY_MAINVALUEUNIT) as Boolean){
            units.put(:mainValue,propertyMainValue!=MAINVALUE_INDEX?Application.loadResource(Rez.Strings.unitTeeths):Application.loadResource(Rez.Strings.unitIndex));
        } else {
            units.put(:mainValue,null);
        }
        units.put(:subValue,propertyMainValue==MAINVALUE_INDEX?Application.loadResource(Rez.Strings.unitTeeths):Application.loadResource(Rez.Strings.unitIndex));

        LogMonkey.Debug.logVariable("GearIndexView.onSettingsChanged()","units",units);
        LogMonkey.Debug.logVariable("GearIndexView.onSettingsChanged()","PROPERTY_DEBUGMODE",debugMode);
        colorMode.handleSettingUpdate();
        lastIndex=-1;
    }

    function onLayout(dc as Dc) as Void {
        //LogMonkey.Debug.logMessage("GearIndexView.onLayout()",dc.getWidth()+"x"+dc.getHeight());
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

            //info(:topLeft).setVisible(false);
            //info(:bottomLeft).setVisible(false);
            visibleAdditionalValues(false);
        } else {
            screen=FIELD;
            //info(:topLeft).setVisible(Properties.getValue(PROPERTY_SHOWTEETH) as Boolean);
            //info(:bottomLeft).setVisible(Properties.getValue(PROPERTY_NUMBEROFSHIFTS) as Boolean);
            visibleAdditionalValues(Properties.getValue(PROPERTY_SHOWADDITIONALVALUES) as Number);
        }
        LogMonkey.Debug.logMessage("GearIndexView.onLayout()",dc.getWidth()+"x"+dc.getHeight()+" "+(screen==FULL?"FullScreen":""));
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
    function visibleAdditionalValues(showAdditionalValues as Number or Boolean or Null) as Void{
        switch(showAdditionalValues){
            case instanceof Number:
                break;
            case instanceof Boolean:
                showAdditionalValues=showAdditionalValues?0:-1;
                break;
            default:
                showAdditionalValues=-1;
        }
        if(showAdditionalValues==-1){
            info(:topLeft).setVisible(false);
            info(:bottomLeft).setVisible(false);
        } else {
            info(:topLeft).setVisible(true);
            info(:bottomLeft).setVisible(true);
        }
    }
    /***
    function onShow() {
        System.println("SlavicsGearRearView.onShow()");
        SlavicsSimpleDataField.onShow();
        self.setTextLabel(label);
    }
    /***/
    //private var invalidBoardShiftCount=0 as Number;
    function compute(info as Activity.Info) as Void {
        SlavicsSimpleDataField.compute(info);
        derailleur.compute();
        gearStatistic.compute(info,derailleur);

        colorMode.compute();
        SlavicsSimpleDataField.setColors(colorMode.getColors());


        batteries=derailleur.getBatteries() as Array<MyDevice.BatteryData>;
        var rds=derailleur.getRearStatus() as AntPlus.DerailleurStatus;
        
        if(rds!=null){
            
            if(rds.gearIndex!=null&&rds.gearIndex!=AntPlus.REAR_GEAR_INVALID){

                if(rds.gearIndex!=lastIndex){
                    valueArea.setColor(colorMode.getFieldColor(:valueChange));

                    if(derailleur.getFrontStatus()!=null){
                        gearFIT.setRatio(derailleur.getFrontStatus().gearSize,rds.gearSize);
                    }
                    if(lastIndex>=0){
                        gearFIT.changeIndex(rds.gearIndex-lastIndex);
                        setTextInfo(:bottomLeft,gearFIT.getTotalShifts().toString()+RD_totalShifts_unit);
                    }

                    // Show Main Value
                    if(propertyMainValue==MAINVALUE_INDEX){
                        // Main value INDEX
                        LogMonkey.Debug.logMessage("GearIndex.compute()","MainValue=INDEX "+propertyMainValue);
                        setValue((rds.gearIndex+1).toString()+(units.get(:mainValue)==null?"":units.get(:mainValue)));
                        setTextInfo(:topLeft,rds.gearSize+units.get(:subValue));
                    } else {
                        // Main value TEETH
                        LogMonkey.Debug.logMessage("GearIndex.compute()","MainValue=TEETH "+propertyMainValue);
                        setValue(rds.gearSize+(units.get(:mainValue)==null?"":units.get(:mainValue)));
                        setTextInfo(:topLeft,(rds.gearIndex+1)+units.get(:subValue));                        
                    }
                    
                    if (Attention has :playTone) {
                        if(rds.gearIndex==rds.gearMax-1){
                            LogMonkey.Debug.logMessage("GearIndex.compute()","ALERT onChange Hi");
                            Attention.playTone(Attention.TONE_ALERT_HI);
                        } else if (rds.gearIndex==0) {
                            LogMonkey.Debug.logMessage("GearIndex.compute()","ALERT onChange Lo");
                            Attention.playTone(Attention.TONE_ALERT_LO);
                        }
                    }
                    /***
                    if(rds.gearIndex==0||rds.gearIndex==rds.gearMax-1){
                        showToast("Max change "+(rds.gearIndex+1)+" !", {:icon=>Rez.Drawables.warningToastIcon});
                    }
                    /***/
                } else if(rds.gearIndex==0||rds.gearIndex==rds.gearMax-1){
                    valueArea.setColor(colorMode.getFieldColor(:valueEdge));
                }
                LogMonkey.Debug.logMessage("GearIndex.compute()","gearIndex="+(rds.gearIndex+1)+(rds.gearIndex!=lastIndex?" / "+(lastIndex+1):""));
                lastIndex=rds.gearIndex;
            } else {
                valueArea.setColor(colorMode.getFieldColor(:valueChange));
                setValue(derailleur.getDeviceStateAsString());
                info(:topLeft).setText(derailleur.getState().state.toString());
                lastIndex=-1;
            }
        } else {
            valueArea.setColor(Graphics.COLOR_ORANGE);
            setValue(derailleur.getDeviceStateAsString());
            info(:topLeft).setText(derailleur.getState().state.toString());
            lastIndex=-1;
        }

        if(debugMode){
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
            debugData.add({:label=>"info.elapsedDistance",:value=>info.elapsedDistance});
            debugData.add({:label=>"info.distanceToDestination",:value=>info.distanceToDestination});
            debugData.add({:label=>"info.nameOfNextPoint",:value=>info.nameOfNextPoint});
            debugData.add({:label=>"info.distanceToNextPoint",:value=>info.distanceToNextPoint});
            debugData.add({:break=>true});
            /***/
            if(derailleur.getDevice()!=null){
                if(derailleur.getDevice().getManufacturerInfo(null)!=null){
                    debugData.add({:label=>"device.manufacturerId",:value=>derailleur.getDevice().getManufacturerInfo(null).manufacturerId});
                    debugData.add({:label=>"device.modelNumber",:value=>derailleur.getDevice().getManufacturerInfo(null).modelNumber});
                } else {
                    debugData.add({:label=>"device.getManufacturerInfo()",:value=>"[null]"});    
                }
            } else {
                debugData.add({:label=>"device",:value=>"[null]"});
            }
            
            debugData.add({:break=>true});
            /***/
            debugData.add({:label=>"device.state",:value=>derailleur.getDeviceStateAsString()+"["+derailleur.getState().state+"]"});
            debugData.add({:label=>"info.rearDerailleurIndex",:value=>info.rearDerailleurIndex});
            if(info.rearDerailleurIndex!=null){
                debugData.add({:label=>"info.rearDerailleurSize",:value=>info.rearDerailleurSize});
                debugData.add({:label=>"info.rearDerailleurMax",:value=>info.rearDerailleurMax});
            }
            if(derailleur.getFrontStatus()!=null){
                debugData.add({:label=>"FDS.gearIndex",:value=>getGearString(derailleur.getFrontStatus().gearIndex,AntPlus.FRONT_GEAR_INVALID)});
                debugData.add({:label=>"FDS.gearMax",:value=>getGearString(derailleur.getFrontStatus().gearMax,AntPlus.MAX_GEARS_INVALID)});
                debugData.add({:label=>"FDS.gearSize",:value=>derailleur.getFrontStatus().gearSize});
            } else {
                debugData.add({:label=>"FrontDerailleurStatus",:value=>null});
            }
            debugData.add({:break=>true});
            if(derailleur.getRearStatus()!=null){
                debugData.add({:label=>"RDS.gearIndex",:value=>getGearString(derailleur.getRearStatus().gearIndex,AntPlus.REAR_GEAR_INVALID)});
                debugData.add({:label=>"RDS.gearMax",:value=>getGearString(derailleur.getRearStatus().gearMax,AntPlus.MAX_GEARS_INVALID)});
                debugData.add({:label=>"RDS.gearSize",:value=>derailleur.getRearStatus().gearSize});
                debugData.add({:label=>"RDS.invalidInboardShiftCount",:value=>derailleur.getRearStatus().invalidInboardShiftCount});
                debugData.add({:label=>"RDS.invalidOutboardShiftCount",:value=>derailleur.getRearStatus().invalidOutboardShiftCount});
                debugData.add({:label=>"RDS.shiftFailureCount",:value=>derailleur.getRearStatus().shiftFailureCount});
                if(derailleur.getBatteries().size()>0){
                    debugData.add({:break=>true});
                    for(var j=0;j<derailleur.getBatteries().size();j++){
                        var batt=(derailleur.getBatteries() as Array)[j];
                        var voltage=batt.get(:voltage)==null?"[null]":batt.get(:voltage).format("%.2f")+"V";
                        debugData.add({:label=>"RDS."+batt.get(:identifier)+".status .voltage",:value=>batt.get(:status)==null?null:Derailleur.getBatteryStatusString(batt.get(:status))+"["+batt.get(:status)+"] "+voltage});
                        //debugData.add({:label=>"RDS."+batt.get(:identifier)+".operatingTime",:value=>batt.get(:operatingTime)});
                        if(derailleur.getDevice().getManufacturerInfo(batt.get(:identifier))!=null){
                            debugData.add({:label=>"device.manufacturerId",:value=>derailleur.getDevice().getManufacturerInfo(batt.get(:identifier)).manufacturerId});
                            debugData.add({:label=>"device.modelNumber",:value=>derailleur.getDevice().getManufacturerInfo(batt.get(:identifier)).modelNumber});
                        }
                    }
                }
            } else {
                debugData.add({:label=>"RearDerailleurStatus",:value=>null});
            }
        }

    }
    private function getGearString(gear as Number or Null,checkGear as Number or Null) as String {
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
            if(debugMode){
                onUpdateDebugMode(dc);
            } else {
                onUpdateFullScreen(dc);                
            }
        }
        //View.onUpdate(dc);
    }
    public function onUpdateFullScreen(dc as Dc) as Void {
        LogMonkey.Debug.logMessage("GearIndexView.onUpdateFullScreen()","");
        gearStatistic.draw(dc,valueArea.locX,valueArea.locY+Graphics.getFontHeight(Graphics.FONT_NUMBER_THAI_HOT)/2,valueArea.width,valueArea.height);
    }
    public function onUpdateDebugMode(dc as Dc) as Void {
        LogMonkey.Debug.logMessage("GearIndexView.onUpdateDebugMode()","");
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
        LogMonkey.Debug.logMessage("GearIndexView.onUpdateField()","");
        
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
                var bd=(batteries as Array<MyDevice.BatteryData>)[i] as MyDevice.BatteryData;
                // Vertically
                if(bd.get(:status)!=null&&bd.get(:status)>0) {

                    battIcon.locX=bLocX;
                    battIcon.locY=bLocY;
                    battIcon.setStatus(bd.get(:status));
                    battIcon.draw(dc);

                    dc.setColor(colorMode.getFieldColor(:label),Graphics.COLOR_TRANSPARENT);
                    dc.drawText(
                            bLocX-battIcon.getWidth(dc)-2,
                            bLocY+(Graphics.getFontHeight(battIcon.getFont())-Graphics.getFontHeight(battFont)),
                            battFont,derailleur.getBatteryName(bd.get(:identifier)),
                            Graphics.TEXT_JUSTIFY_RIGHT
                        );
                    bLocY-=Graphics.getFontHeight(battIcon.getFont())+3;
                }
            }
        }
    }

    function onTimerReset() {
        LogMonkey.Debug.logMessage("GearIndexView.onTimerReset()","");
        gearFIT.onTimerReset();
    }
    
    function onTimerPause() {
        LogMonkey.Debug.logMessage("GearIndexView.onTimerPause()","");
  	    gearFIT.onTimerPause();
    }
    
    function onTimerResume() {
        LogMonkey.Debug.logMessage("GearIndexView.onTimerResume()","");
  	    gearFIT.onTimerResume();
    }
    
    function onTimerStart() {
        LogMonkey.Debug.logMessage("GearIndexView.onTimerStart()","");
   	    gearFIT.onTimerStart();
    }
    
    function onTimerStop() {
        LogMonkey.Debug.logMessage("GearIndexView.onTimerStop()","");
   	    gearFIT.onTimerStop();
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