import Toybox.Lang;
import Toybox.WatchUi;

class TamagotchiDelegate extends WatchUi.BehaviorDelegate {

    private var app = getApp();

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new TamagotchiMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() as Boolean {
        app.incIndexAction();
        return true;
    }

    function onSelect() as Boolean {
        var indexAction = app.getIndexAction();

        if (indexAction == 0) {
            app.feed();  // Update stats first
            app.startFeedAnimation();  // Request animation start
            WatchUi.requestUpdate();  // Trigger view update to check flag
        }

        else if (indexAction == 1) {
            app.play();
            WatchUi.requestUpdate();
        }

        else if (indexAction == 2) {
            app.sleep();
            WatchUi.requestUpdate();
        }

        return true;
    }

}