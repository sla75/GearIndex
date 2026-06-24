import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

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

    protected var labelArea = new WatchUi.TextArea({
            :text=>"",
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>FONTS.slice(4,null),
            :justification => Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER,
        }) as TextArea;
    protected var valueArea=new WatchUi.TextArea({
            :text=>"",
            :color=>Graphics.COLOR_DK_BLUE,
            :font=>FONTS,
            :justification => Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER,
        }) as TextArea;
    protected var labels={
        :topLeft=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
            :visibility=>false
        }),
        :topRight=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_RIGHT,
            :visibility=>false
        }),
        :bottomLeft=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
            :visibility=>false
        }),
        :bottomRight=>new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_RIGHT,
            :visibility=>false
        })
    };

    protected var XtopLeftLabel=new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
            :visibility=>false
        });
    protected var XtopRightLabel=new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_RIGHT,
            :visibility=>false
        });
    protected var bottomLeftLabel=new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_LEFT,
            :visibility=>false
        });
    protected var bottomRightLabel=new Text({
            :color=>Graphics.COLOR_DK_GRAY,
            :font=>Graphics.FONT_SMALL,
            :justification=>Graphics.TEXT_JUSTIFY_RIGHT,
            :visibility=>false
        });
    
    public var rim=0 as Number;
    public var labelLine=0 as Number;
    public var colors={:background=>Graphics.COLOR_WHITE,:label=>Graphics.COLOR_DK_GRAY,:value=>Graphics.COLOR_BLACK} as Dictionary<Symbol,Graphics.ColorValue>;
    //protected var textLabel="Label" as String;
    //protected var textValue="Value" as String;
    private var brt=0 as Number;

    function initialize() {
        System.println("SlavicsSimpleDataField.initialize()");
        DataField.initialize();
    }

    function onLayout(dc as Dc) as Void {
        System.println("SlavicsSimpleDataField.onLayout() "+dc.getWidth()+"x"+dc.getHeight());
        rim=dc.getHeight()*0.02f;
        labelLine=dc.getHeight()*LABELHEIGHT;

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

        labels.get(:topLeft).locX=self.rim;
        labels.get(:topLeft).locY=self.labelLine;
        labels.get(:topLeft).setJustification(Graphics.TEXT_JUSTIFY_LEFT);

        labels.get(:topRight).locX=dc.getWidth()-self.rim;
        labels.get(:topRight).locY=self.labelLine;
        labels.get(:topRight).setJustification(Graphics.TEXT_JUSTIFY_RIGHT);

        bottomLeftLabel.locX=self.rim;
        bottomLeftLabel.locY=dc.getHeight()-self.rim-Graphics.getFontAscent(Graphics.FONT_SMALL);
        bottomLeftLabel.setJustification(Graphics.TEXT_JUSTIFY_LEFT);

        bottomRightLabel.locX=dc.getWidth()-self.rim;
        bottomRightLabel.locY=dc.getHeight()-self.rim-Graphics.getFontAscent(Graphics.FONT_SMALL);
        bottomRightLabel.setJustification(Graphics.TEXT_JUSTIFY_RIGHT);
    }

    public function setTextLabel(text as String or Null){
        //System.println("SlavicsSimpleDataField.setTextLabel('"+text+"')");
        labelArea.setText(text!=null?text:"");
    }

    public function setTextValue(text as String or Null){
        //System.println("SlavicsSimpleDataField.setTextValue('"+text+"')");
        valueArea.setText(text!=null?text:"");
    }
    
    public function setColors(colors as Dictionary<Symbol,Graphics.ColorValue>){
        self.colors=colors;
        valueArea.setColor(colors.get(:value));
        labelArea.setColor(colors.get(:label));

        topLeftLabel.setColor(colors.get(:label));
        topRightLabel.setColor(colors.get(:label));
        bottomLeftLabel.setColor(colors.get(:label));
        bottomRightLabel.setColor(colors.get(:label));
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
        //System.println("SlavicsSimpleDataField.onUpdate()");
        dc.setColor(Graphics.COLOR_TRANSPARENT,colors.get(:background));
        dc.clear();
        valueArea.draw(dc);
        labelArea.draw(dc);
        topLeftLabel.draw(dc);
        topRightLabel.draw(dc);
        bottomLeftLabel.draw(dc);
        bottomRightLabel.draw(dc);
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
        private var timer=null as SlavicsSimpleDataField.Timer;
        function initialize(options as Dictionary){
            Text.initialize(options);
        }
        function setTimer(durationSec as Number) as Void{
            timer=new SlavicsSimpleDataField.Timer(durationSec);
        }
        function clearTimer() as Void{
            timer=null;
        }
        function onUpdate(dc) as Void{
            if(timer!=null){
                if(timer.isExpiration()){
                    self.setVisible(false);
                } else {
                    self.setVisible(true);
                }
            }
            Text.onUpdate(dc);
        }
    }
    class Timer {
        private var timeValue as Time.Moment;
        private var expiration=false as Boolean;
        
        function initialize(durationSec as Number){
            timeValue=new Time.Moment(Time.today().value()+durationSec);
        }

        function isExpiration() as Boolean{
            if(expiration){
                return true;
            }
            if((new Time.Moment(Time.today().value())).greaterThan(timeValue)){
                expiration=true;
            }
            return expiration;
        }
    }
}