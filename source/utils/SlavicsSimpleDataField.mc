import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import LogMonkey;

class SlavicsSimpleDataField extends WatchUi.DataField {
    private const LABELHEIGHT=0.25f as Numeric;
    public const FONTS=[
            Graphics.FONT_NUMBER_THAI_HOT,
            Graphics.FONT_NUMBER_HOT,
            Graphics.FONT_NUMBER_MEDIUM,
            Graphics.FONT_NUMBER_MILD,
            Graphics.FONT_LARGE,
            Graphics.FONT_MEDIUM,
            Graphics.FONT_SMALL,
            Graphics.FONT_TINY,
            Graphics.FONT_XTINY,
        ] as Array<Graphics.FontType>;

    protected var labelArea as TextArea = new WatchUi.TextArea({
            :text=>"",
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>FONTS.slice(4,null),
            :justification => Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER,
        });
    protected var valueArea as TextArea = new WatchUi.TextArea({
            :text=>"",
            :color=>Graphics.COLOR_DK_BLUE,
            :font=>FONTS,
            :justification => Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER,
        });
    protected var labels as Dictionary<Symbol, Text or MyText> = {
        :topLeft=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_MEDIUM,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
            :visibility=>false
        }),
        :topRight=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_MEDIUM,
            :justification=>Graphics.TEXT_JUSTIFY_RIGHT,
            :visibility=>false
        }),
        :bottomLeft=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_MEDIUM,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
            :visibility=>false
        }),
        :bottomRight=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_MEDIUM,
            :justification=>Graphics.TEXT_JUSTIFY_RIGHT,
            :visibility=>false
        })
    };
    private var timer as SlavicsSimpleDataField.Timer or Null;

    public var rim as Number=0;
    public var labelLine as Number=0;
    public var colors as Dictionary<Symbol,Graphics.ColorValue> = {:background=>Graphics.COLOR_WHITE,:label=>Graphics.COLOR_DK_GRAY,:value=>Graphics.COLOR_BLACK};
    //protected var textLabel="Label" as String;
    //protected var textValue="Value" as String;

    function initialize() {
        //LogMonkey.Debug.logMessage("SlavicsSimpleDataField.initialize()","");
        DataField.initialize();
    }

    function onLayout(dc as Dc) as Void {
        //LogMonkey.Debug.logMessage("SlavicsSimpleDataField.onLayout()",dc.getWidth()+"x"+dc.getHeight());
        rim=(dc.getHeight()*0.02f).toNumber();
        labelLine=(dc.getHeight()*LABELHEIGHT).toNumber();

        labelArea.locX=rim;
        labelArea.locY=rim;
        labelArea.width=dc.getWidth()-2*rim;
        labelArea.height=labelLine*1.333f;
        labelArea.setJustification(Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        valueArea.locX=0;
        valueArea.locY=labelLine;
        valueArea.width=dc.getWidth();
        valueArea.height=dc.getHeight()-labelLine*0.667f;
        valueArea.setJustification(Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        var t=getText(:topLeft) as Text;
        t.locX=self.rim;
        t.locY=self.labelLine;
        t.setJustification(Graphics.TEXT_JUSTIFY_LEFT);

        t=getText(:topRight) as Text;
        t.locX=dc.getWidth()-self.rim;
        t.locY=self.labelLine;
        t.setJustification(Graphics.TEXT_JUSTIFY_RIGHT);

        t=getText(:bottomLeft);
        t.locX=self.rim;
        t.locY=dc.getHeight()-self.rim-Graphics.getFontAscent(Graphics.FONT_SMALL);
        t.setJustification(Graphics.TEXT_JUSTIFY_LEFT);
        
        t=getText(:bottomRight);
        t.locX=dc.getWidth()-self.rim;
        t.locY=dc.getHeight()-self.rim-Graphics.getFontAscent(Graphics.FONT_SMALL);
        t.setJustification(Graphics.TEXT_JUSTIFY_RIGHT);
    }
    public function setTimer(duration as Number or Null) as Void {
        LogMonkey.Debug.logVariable("SlavicsSimpleDataField.setTimer()","duration",duration);
        if(duration==null||duration==0){
            self.timer=null;
        } else {
            self.timer=new SlavicsSimpleDataField.Timer(duration);
        }
    }
    public function getText(name as Symbol) as Text {
        return labels.get(name) as Text;
    }
    public function setTextInfo(name as Symbol,text as String or Null) as Void{
        getText(name).setText(text!=null?text:"");
        if(timer!=null){
            timer.start();
        }
    }
    public function setTextLabel(text as String or Null) as Void{
        labelArea.setText(text!=null?text:"");
    }

    public function setValue(text as String or Null) as Void{
        valueArea.setText(text!=null?text:"");
    }
    (:typecheck(false))
    public function setColors(colors as Dictionary<Symbol,Graphics.ColorValue>){
        self.colors=colors;
        valueArea.setColor(colors.get(:value));
        labelArea.setColor(colors.get(:label));
        getText(:topLeft).setColor(colors.get(:label));
        getText(:topRight).setColor(colors.get(:label));
        getText(:bottomLeft).setColor(colors.get(:label));
        getText(:bottomRight).setColor(colors.get(:label));
    }
    /***
    public function compute(info as Activity.Info) as Void {
        valueArea.setColor(nightMode?Graphics.COLOR_WHITE:Graphics.COLOR_BLACK);
        labelArea.setColor(nightMode?Graphics.COLOR_LT_GRAY:Graphics.COLOR_DK_GRAY);
    }
    /***/

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    
    public function onUpdate(dc as Dc) as Void {
        LogMonkey.Debug.logMessage("SlavicsSimpleDataField.onUpdate()",timer!=null?timer.toString():"");
        dc.setColor(Graphics.COLOR_TRANSPARENT,colors.get(:background) as Graphics.ColorValue);
        dc.clear();
        valueArea.draw(dc);
        labelArea.draw(dc);
        if(timer==null||!timer.isExpired()){
            LogMonkey.Debug.logMessage("SlavicsSimpleDataField.onUpdate()","draw topbottomleftright");
            getText(:topLeft).draw(dc);
            getText(:topRight).draw(dc);
            getText(:bottomLeft).draw(dc);
            getText(:bottomRight).draw(dc);
        }
        onUpdateAfter(dc);
    }
    (:release)
    private function onUpdateAfter(dc as Dc) as Void {
    }
    (:debug)
    private function onUpdateAfter(dc as Dc) as Void {
        //dc.setColor(Graphics.COLOR_TRANSPARENT, System.getDeviceSettings().isNightModeEnabled?Graphics.COLOR_BLACK:Graphics.COLOR_WHITE);
        //dc.clear();
        //valueArea.draw(dc);
        //labelArea.draw(dc);

        dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(labelArea.locX,labelArea.locY,labelArea.width,labelArea.height);
        dc.drawLine(labelArea.locX,labelArea.locY+labelArea.height/2,labelArea.locX+labelArea.width,labelArea.locY+labelArea.height/2);

        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(valueArea.locX,valueArea.locY,valueArea.width,valueArea.height);
        dc.drawLine(valueArea.locX,valueArea.locY+valueArea.height/2,valueArea.locX+valueArea.width,valueArea.locY+valueArea.height/2);
    }
    
    class MyText extends WatchUi.Text{
        private var myFont as Graphics.FontType;
        (:typecheck(false))
        function initialize(options) {
            Text.initialize(options);
            myFont=options.get(:font)==null?Graphics.FONT_TINY:options.get(:font) as Graphics.FontType;
            Text.setFont(myFont);
        }
        function setFont(font as Graphics.FontType) as Void {
            myFont=font;
            Text.setFont(font);
        }
        function getFont() as Graphics.FontType {
            return myFont;
        }
    }

    class Timer {
        private var timeValue as Number=0;
        private var defaultDuration as Number;
        private var expired as Boolean=true;
        
        function initialize(durationSec as Number){
            defaultDuration=durationSec;
        }

        function start() as Void {
            timeValue=Time.now().value()+defaultDuration;
            //LogMonkey.Debug.logMessage("SlavicsSimpleDataField.Timer","START timeValue="+timeValue+"("+Time.now().value()+"+"+defaultDuration+")");
            expired=false;
        }

        function isExpired() as Boolean{
            //LogMonkey.Debug.logVariable("SlavicsSimpleDataField.isExpired()","Time.now().value()",Time.now().value());
            if(expired){
                return true;
            }
            //LogMonkey.Debug.logMessage("SlavicsSimpleDataField.isExpired()",expiration+" diff="+(Time.now().value()-timeValue));
            if(Time.now().value()>timeValue){
                expired=true;
                //LogMonkey.Debug.logVariable("SlavicsSimpleDataField.Timer","STOP expiration",expiration);
            }
            return expired;
        }

        function toString() as String{
            return "Timer("+defaultDuration.toString()+"s) expired="+expired.toString();
        }
    }
}