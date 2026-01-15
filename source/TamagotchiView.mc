import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;

class TamagotchiView extends WatchUi.View {

    private var petHappyBitmap as BitmapResource?;
    private var petHungryBitmap as BitmapResource?;
    private var petPlayBitmap as BitmapResource?;
    private var petSadBitmap as BitmapResource?;
    private var petSleepingBitmap as BitmapResource?;
    private var petEating1 as BitmapResource?;
    private var petEating2 as BitmapResource?;
    private var petEating3 as BitmapResource?;

    private var petPlaying1 as BitmapResource?;
    private var petPlaying2 as BitmapResource?;
    private var petPlaying3 as BitmapResource?;

    private var font18;
    private var app = getApp();

    // Animation state
    private var isAnimating = false;
    private var currentFrame = 0;
    private var framesDisplayed = 0;
    private var animTimer;
    private var animationFrames;

    // Animation configuration
    private const FRAME_DURATION_MS = 150;  // ~6.7 FPS
    private const TOTAL_FRAMES = 9;         // 3 frames × 3 cycles

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

        petPlaying1 = WatchUi.loadResource(Rez.Drawables.petPlaying1) as BitmapResource;
        petPlaying2 = WatchUi.loadResource(Rez.Drawables.petPlaying2) as BitmapResource;
        petPlaying3 = WatchUi.loadResource(Rez.Drawables.petPlaying3) as BitmapResource;

        animationFrames = [petEating1, petEating2, petEating3];
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        if (app.checkAndClearAnimationFlag()) {
            feedingAnimation();
        }

        if (app.checkAndClearPlayAnimationFlag()) {
            playingAnimation();
        }

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
        var currentBitmap;

        if (isAnimating && animationFrames != null) {
            currentBitmap = animationFrames[currentFrame];
        } else {
            currentBitmap = getPetStateBitmap();
        }

        dc.drawBitmap(w * 0.32, h * 0.4, currentBitmap);
    }

    // Determine which bitmap to display based on pet's current stats
    private function getPetStateBitmap() as BitmapResource {
        var hunger = app.getHunger();
        var energy = app.getEnergy();
        var happiness = app.getHappiness();

        // Priority order: Sleeping > Hungry > Sad > Play > Happy

        if (energy < 20) {
            return petSleepingBitmap;
        }

        if (hunger < 30) {
            return petHungryBitmap;
        }

        if (happiness < 20) {
            return petSadBitmap;
        }

        if (energy > 60 && happiness > 40) {
            return petPlayBitmap;
        }

        return petHappyBitmap;
    }

    function actionMenu(dc as Dc, w, h) as Void {
      var indexAction = getApp().getIndexAction();
      var menuItems = ["Feed", "Play", "Sleep"];
      var positions = [0.25, 0.50, 0.75];

      for (var i = 0; i < menuItems.size(); i++) {
          var xPos = w * positions[i];
          var yPos = h * 0.85;

          if (indexAction == i) {
              dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
              dc.fillRectangle(xPos - 20, yPos - 10, 40, 20);
              dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
          } else {
              dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
          }

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

    function feedingAnimation() as Void {
        if (isAnimating) {
            return;
        }

        animationFrames = [petEating1, petEating2, petEating3];

        isAnimating = true;
        currentFrame = 0;
        framesDisplayed = 0;

        animTimer = new Timer.Timer();
        animTimer.start(method(:onAnimationFrame), FRAME_DURATION_MS, true);

        WatchUi.requestUpdate();
    }

    function playingAnimation() as Void {
        if (isAnimating) {
            return;
        }

        animationFrames = [petPlaying1, petPlaying2, petPlaying3];

        isAnimating = true;
        currentFrame = 0;
        framesDisplayed = 0;

        animTimer = new Timer.Timer();
        animTimer.start(method(:onAnimationFrame), FRAME_DURATION_MS, true);

        WatchUi.requestUpdate();
    }

    // Timer callback - executed every FRAME_DURATION_MS
    function onAnimationFrame() as Void {
        if (!isAnimating) {
            return;
        }

        currentFrame = (currentFrame + 1) % animationFrames.size();
        framesDisplayed++;

        WatchUi.requestUpdate();

        if (framesDisplayed >= TOTAL_FRAMES) {
            stopAnimation();
        }
    }

    // Stop animation and return to normal state
    private function stopAnimation() as Void {
        if (animTimer != null) {
            animTimer.stop();
            animTimer = null;
        }

        isAnimating = false;
        currentFrame = 0;
        framesDisplayed = 0;

        WatchUi.requestUpdate();
    }



    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if (animTimer != null) {
            animTimer.stop();
            animTimer = null;
        }
        isAnimating = false;
    }

}
