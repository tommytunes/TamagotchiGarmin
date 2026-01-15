import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.Time;

class TamagotchiApp extends Application.AppBase {

    private var hunger = 100;
    private var energy = 100;
    private var happiness = 100;

    private var indexAction = 0;

    private var shouldStartFeedAnimation = false;
    private var shouldStartPlayAnimation = false;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        var lastExitTime = Storage.getValue("lastExitTime");

        if (lastExitTime == null) {
            System.println("First launch - using defaults");
            return;
        }

        var savedHunger = Storage.getValue("hunger");
        var savedEnergy = Storage.getValue("energy");
        var savedHappiness = Storage.getValue("happiness");

        if (savedHunger == null) { savedHunger = 100; }
        if (savedEnergy == null) { savedEnergy = 100; }
        if (savedHappiness == null) { savedHappiness = 100; }

        var currentTime = Time.now();
        var elapsedSeconds = currentTime.value() - lastExitTime;

        decayTime(elapsedSeconds, savedHunger, savedEnergy, savedHappiness);

        System.println("Stats after decay: H=" + hunger + " E=" + energy + " Hp=" + happiness);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        var currentTime = Time.now();
        var timestamp = currentTime.value();

        Storage.setValue("lastExitTime", timestamp);
        Storage.setValue("hunger", hunger);
        Storage.setValue("energy", energy);
        Storage.setValue("happiness", happiness);

        System.println("State saved - H=" + hunger + " E=" + energy + " Hp=" + happiness);
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new TamagotchiView(), new TamagotchiDelegate() ];
    }

    function incIndexAction() as Void {
        indexAction++;
        indexAction %= 3;
        System.println(indexAction); 
    }

    function getIndexAction() as Number {
        return indexAction;
    }

    function feed() as Void {
        hunger += 20;
        hunger = statMinMax(hunger);

        happiness += 5;
        happiness = statMinMax(happiness);

        energy -= 5;
        energy = statMinMax(energy);
    }

    function play() as Void {
        hunger -= 10;
        hunger = statMinMax(hunger);

        happiness += 20;
        happiness = statMinMax(happiness);

        energy -= 20;
        energy = statMinMax(energy);
    }

    function sleep() as Void {
        hunger -= 10;
        hunger = statMinMax(hunger);

        happiness -= 5;
        happiness = statMinMax(happiness);

        energy += 40;
        energy = statMinMax(energy);
    }

    function statMinMax(stat as Number) as Number {
        if (stat < 0) {
            return 0;
        }
        else if (stat > 100) {
            return 100;
        }
        return stat;
    }

    function getHunger() as Number {
        return hunger;
    }

    function getEnergy() as Number {
        return energy;
    }

    function getHappiness() as Number {
        return happiness;
    }

    function decayTime(elapsedSeconds as Number, savedHunger as Number,
                       savedEnergy as Number, savedHappiness as Number) as Void {

        var HUNGER_DECAY_PER_HOUR = 5;
        var ENERGY_DECAY_PER_HOUR = 3;
        var HAPPINESS_DECAY_PER_HOUR = 4;
        var MAX_DECAY_SECONDS = 86400;

        if (elapsedSeconds < 0) {
            System.println("Warning: Negative elapsed time, skipping decay");
            hunger = savedHunger;
            energy = savedEnergy;
            happiness = savedHappiness;
            return;
        }

        if (elapsedSeconds > MAX_DECAY_SECONDS) {
            elapsedSeconds = MAX_DECAY_SECONDS;
        }

        var elapsedHours = elapsedSeconds.toFloat() / 3600.0;
        var hungerDecay = Math.floor(elapsedHours * HUNGER_DECAY_PER_HOUR).toNumber();
        var energyDecay = Math.floor(elapsedHours * ENERGY_DECAY_PER_HOUR).toNumber();
        var happinessDecay = Math.floor(elapsedHours * HAPPINESS_DECAY_PER_HOUR).toNumber();

        hunger = statMinMax(savedHunger - hungerDecay);
        energy = statMinMax(savedEnergy - energyDecay);
        happiness = statMinMax(savedHappiness - happinessDecay);
    }

    // Request animation start (called by delegate)
    function startFeedAnimation() as Void {
        shouldStartFeedAnimation = true;
    }

    // Request play animation start (called by delegate)
    function startPlayAnimation() as Void {
        shouldStartPlayAnimation = true;
    }

    // Check and clear animation flag (called by view)
    function checkAndClearAnimationFlag() as Boolean {
        var result = shouldStartFeedAnimation;
        shouldStartFeedAnimation = false;
        return result;
    }

    // Check and clear play animation flag (called by view)
    function checkAndClearPlayAnimationFlag() as Boolean {
        var result = shouldStartPlayAnimation;
        shouldStartPlayAnimation = false;
        return result;
    }

}

function getApp() as TamagotchiApp {
    return Application.getApp() as TamagotchiApp;
}