class HandleGesture {

  static void handleSwipeGesture(double startX,
      double endX,
      double threshold,
      bool isIndividualEvents,
      Function(bool) setIndividualEvents) {
// Calculate the difference in positions
    double deltaX = endX - startX;

// Check if the swipe distance exceeds the threshold
    if (deltaX.abs() > threshold) {
// Change the value of isIndividual based on the direction of the swipe
      if (deltaX > 0 && !isIndividualEvents) {
        setIndividualEvents(true);
      } else if (deltaX < 0 && isIndividualEvents) {
        setIndividualEvents(false);
      }
    }
  }
}