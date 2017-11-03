//<import statements here>

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "ExampleData_1.json";
String eventDataJSON2 = "ExampleData_2.json";

NotificationServer server;
ArrayList<Notification> notifications;

Example example;

void setup() {
  
  //START NotificationServer setup
  server = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  example = new Example();
  server.addListener(example);
  
  //loading the event stream, which also starts the timer serving events
  server.loadEventStream(eventDataJSON1);
  
  //END NotificationServer setup
  
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()  
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  }
    
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class Example implements NotificationListener {
  
  public Example() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println("<Example> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + "millis.");
    
    String debugOutput = "";
    switch (notification.getType()) {
      case Tweet:
        debugOutput += "New tweet from ";
        break;
      case Email:
        debugOutput += "New email from ";
        break;
      case VoiceMail:
        debugOutput += "New voicemail from ";
        break;
      case MissedCall:
        debugOutput += "Missed call from ";
        break;
      case TextMessage:
        debugOutput += "New message from ";
        break;
    }
    debugOutput += notification.getSender() + ", " + notification.getMessage();
    
    println(debugOutput);
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}