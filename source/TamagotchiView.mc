import Toybox.Graphics;
import Toybox.WatchUi;

class TamagotchiView extends WatchUi.View {

    private var petHappyBitmap as BitmapResource?;
    private var petHungryBitmap as BitmapResource?;
    private var petPlayBitmap as BitmapResource?;
    private var petSadBitmap as BitmapResource?;
    private var petSleepingBitmap as BitmapResource?;
    private var petEating1 as BitmapResource?;
    private var petEating2 as BitmapResource?;
    private var petEating3 as BitmapResource?;
    private var font18;
    private var app = getApp();

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        petHappyBitmap = WatchUi.loadResource(Rez.Drawables.petHappy) as BitmapResource;
        petHungryBitmap = WatchUi.loadResource(Rez.Drawables.petHungry) as BitmapResource;
        petPlayBitmap = WatchUi.loadResource(Rez.Drawables.petPlay) as BitmapResource;
        petSadBitmap = WatchUi.loadResource(Rez.Drawables.petSad) as BitmapResource;
        petSleepingBitmap = WatchUi.loadResource(Rez.Drawables.petSleeping) as BitmapResource;
        font18 = WatchUi.loadResource(Rez.Fonts.Font18) as BitmapResource;

        petEating1 = WatchUi.loadResource(Rez.Drawables.petEating1) as BitmapResource;
        petEating2 = WatchUi.loadResource(Rez.Drawables.petEating2) as BitmapResource;
        petEating3 = WatchUi.loadResource(Rez.Drawables.petEating3) as BitmapResource;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var w = dc.getWidth();
        var h = dc.getHeight();

        petDraw(dc, w, h);
        actionMenu(dc, w, h);
        hungerStatView(dc);
        energyStatView(dc);
        happinessStatView(dc);

    }

    function petDraw(dc as Dc, w, h) as Void {
        var currentBitmap = getPetStateBitmap();
        dc.drawBitmap(w * 0.32, h * 0.4, currentBitmap);
    }

    // Determine which bitmap to display based on pet's current stats
    private function getPetStateBitmap() as BitmapResource {
        var hunger = app.getHunger();
        var energy = app.getEnergy();
        var happiness = app.getHappiness();

        // Priority order: Sleeping > Hungry > Sad > Play > Happy

        // Sleeping: Pet is very tired
        if (energy < 20) {
            return petSleepingBitmap;
        }

        // Hungry: Pet is very hungry
        if (hunger < 30) {
            return petHungryBitmap;
        }

        // Sad: Pet is very unhappy
        if (happiness < 20) {
            return petSadBitmap;
        }

        // Play: Pet has energy and is happy
        if (energy > 60 && happiness > 40) {
            return petPlayBitmap;
        }

        // Happy: Default state when all stats are decent
        return petHappyBitmap;
    }

    function actionMenu(dc as Dc, w, h) as Void {
      var indexAction = getApp().getIndexAction();
      var menuItems = ["Feed", "Play", "Sleep"];
      var positions = [0.25, 0.50, 0.75];

      for (var i = 0; i < menuItems.size(); i++) {
          var xPos = w * positions[i];
          var yPos = h * 0.85;

          // Draw highlight rectangle for selected item
          if (indexAction == i) {
              dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
              dc.fillRectangle(xPos - 20, yPos - 10, 40, 20);
              dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
          } else {
              dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          }

          // Draw text
          dc.drawText(
              xPos,
              yPos,
              font18,
              menuItems[i],
              Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
          );
      }

      if (indexAction >= 0 && indexAction <= 2) {
          WatchUi.requestUpdate();
      }
    }

    function hungerStatView(dc as Dc) as Void {
        var hungerView = View.findDrawableById("Hunger") as Text;

        var iconIds = ["HungerIcon1", "HungerIcon2", "HungerIcon3", "HungerIcon4", "HungerIcon5"];
        var hunger = app.getHunger();
        hungerView.setText("Hunger:");
        
        updateStatView(hunger, iconIds, Graphics.COLOR_RED, 33);
    }

    function energyStatView(dc as Dc) as Void {
        var energyView = View.findDrawableById("Energy") as Text;

        var iconIds = ["EnergyIcon1", "EnergyIcon2", "EnergyIcon3", "EnergyIcon4", "EnergyIcon5"];
        
        energyView.setText("Energy:");

        var energy = app.getEnergy();

        updateStatView(energy, iconIds, Graphics.COLOR_YELLOW, 34);
    }

    function happinessStatView(dc as Dc) as Void {
        var happinessView = View.findDrawableById("Happiness") as Text;
        happinessView.setText("Happiness:");

        var iconIds = ["HappinessIcon1", "HappinessIcon2", "HappinessIcon3", "HappinessIcon4", "HappinessIcon5"];

        var happiness = app.getHappiness();

        updateStatView(happiness, iconIds, Graphics.COLOR_GREEN, 35);
    }

    private function updateStatView(state, iconIds, activeColor, charNum) as Void {
        
        var thresholds = [0, 20, 40, 60, 80];

        for (var i = 0; i < iconIds.size(); i++) {
            var icon = View.findDrawableById(iconIds[i]) as Text;

            if (state >= thresholds[i]) {
                icon.setColor(activeColor);
            }
            else {
                icon.setColor(Graphics.COLOR_WHITE);
            }

            icon.setText(charNum.toChar().toString());
        }

    }

    function feedingAnimation(dc as Dc) as Void {
        
    }

    

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
