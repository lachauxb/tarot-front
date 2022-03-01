/// Generalized observer provides flutter app a way to intimate state changes
/// to the subscriber widgets, this way we can propagate changes across widgets
enum ObserverState {
  INIT,
  LIST_REFRESHED,
  STORY_UPDATED,
  STORYGROUP_ASK_REFRESH,
  NOTIFICATION_UPDATE
}

abstract class StateListener {
  void onStateChanged(ObserverState state); // override this method to notify observers on a specific ObserverState
}

// Singleton reusable class
class StateProvider {

  List<StateListener> observers;

  static final StateProvider _instance = new StateProvider.internal();
  factory StateProvider() => _instance;

  StateProvider.internal() {
    observers = new List<StateListener>();
    initState();
  }

  void initState() async {
    notify(ObserverState.INIT); // notifying all observers on the INIT state only (will not notify observers on LIST_REFRESHED for example)
  }

  void subscribe(StateListener listener) {
    observers.add(listener);
  }

  void dispose(StateListener listener) {
    observers.remove(listener);
  }

  void notify(dynamic state) {
    observers.forEach((StateListener obj) => obj.onStateChanged(state));
  }

}