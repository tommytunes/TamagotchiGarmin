import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TamagotchiMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :item_1) {
            System.exit();
        }
    }
}