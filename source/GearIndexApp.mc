import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class GearIndexApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        Properties.setValue("property_version",Application.loadResource(Rez.Strings.version));
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }
    var view=null as GearIndexView;
    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        view=new GearIndexView();
        return [ view ];
        //return [ new SlavicsGearRearSimpleView() ];
    }

    function onSettingsChanged() { // triggered by settings change in GCM
        System.println("GearIndexApp.onSettingsChanged()");
        view.onSettingsChanged();
        WatchUi.requestUpdate();   // update the view to reflect changes
    }

}

function getApp() as GearIndexApp {
    return Application.getApp() as GearIndexApp;
}