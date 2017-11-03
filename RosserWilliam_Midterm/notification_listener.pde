//0=Tweet 1=Email 2=TextMessage 3=PhoneCall 4=VoiceMail
ArrayList<Notification> tweetList = new ArrayList<Notification>();
ArrayList<Notification> emailList = new ArrayList<Notification>();
ArrayList<Notification> textList = new ArrayList<Notification>();
ArrayList<Notification> callList = new ArrayList<Notification>();
ArrayList<Notification> vmList = new ArrayList<Notification>();
int totalNotifications = 0;
String lastMessage = "";

interface NotificationListener {
  void notificationReceived(Notification notification);
}


class Listener implements NotificationListener {
  
  public Listener() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    println(notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + "millis.");
    totalNotifications++;
    String debugOutput = "";
    switch (notification.getType()) {
      case Tweet:
        debugOutput += "New tweet from ";
        tweetList.add(notification);
        break;
      case Email:
        debugOutput += "New email from ";
        emailList.add(notification);
        break;
      case VoiceMail:
        debugOutput += "New voicemail from ";
        vmList.add(notification);
        break;
      case MissedCall:
        debugOutput += "Missed call from ";
        callList.add(notification);
        break;
      case TextMessage:
        debugOutput += "New message from ";
        textList.add(notification);
        break;
    }
    debugOutput += notification.getSender() + ", " + notification.getMessage();
    lastMessage = debugOutput;
    
    println(debugOutput);
  }
}