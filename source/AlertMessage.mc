import Toybox.Activity;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Attention;

/***
    manifest.xml
        <iq:permissions>
            <iq:uses-permission id="DataFieldAlert"/>

    function onUpdate(dc as Dc) as Void {
        ...
        View.onUpdate(dc);
        ...
            showAlert(new AlertMessage("Alert message");
/***/

(:showalert)
class AlertMessage extends WatchUi.DataFieldAlert {

    private var alertText as String;
    private const FONT=Graphics.FONT_LARGE;
    private const FONT_LABEL=Graphics.FONT_SMALL;
    private const TEXT_LABEL=WatchUi.loadResource($.Rez.Strings.AppName);
    private const RADIUS=Graphics.getFontDescent(FONT);
    private const OUTLINE=4 as Number;
    private var w2=0 as Number;
    private var h2=0 as Number;

    public function initialize(message as String) {
        DataFieldAlert.initialize();
        alertText = message;
    }

    function onLayout(dc as Dc) as Void {
        w2=dc.getWidth() / 2;
        h2=dc.getHeight() / 3;
    }
    
    public function onUpdate(dc as Dc) as Void {
        
        var fdsc2=2*RADIUS;

        var sizeLabel=dc.getTextDimensions(TEXT_LABEL,FONT_LABEL);
        var sizeText=dc.getTextDimensions(alertText,FONT);
        

        var wt=(sizeText[0]>sizeLabel[0]?sizeText[0]:sizeLabel[0])+fdsc2;
        var ht=sizeLabel[1]+sizeText[1]+fdsc2;

        var tx=w2-wt/2;
        var ty=h2-ht/2;

        // Background
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(tx,ty,wt,ht,RADIUS);

        // Outline
        dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(tx+OUTLINE,ty+OUTLINE,wt-2*OUTLINE+1,ht-2*OUTLINE+1,RADIUS-OUTLINE);

        // Label
        dc.drawText(w2, h2-sizeText[1]/2 , FONT_LABEL, 
        TEXT_LABEL, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        // Message
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w2, h2+sizeLabel[1], FONT, 
        alertText, Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);

        if (Attention has :ToneProfile) {
            Attention.playTone(Attention.TONE_ALERT_HI);
        }
    }
}