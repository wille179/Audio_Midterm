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
    String voiceOut = "";
    boolean playVoice = social_level[env_context] != 1 && interrupt_level[env_context]>=notification.getPriorityLevel();;
    switch (notification.getType()) {
      //0=Tweet 1=Email 2=TextMessage 3=PhoneCall 4=VoiceMail
      case Tweet:
        debugOutput += "Tweet from ";
        if (playVoice && ttsVoice!=null && !ttsVoice.isDeleted() && !ttsVoice.isPaused()) {
          tweetList.add(notification);
        }
        if (arrive_sounds[0]!=null && receive[env_context][0]) {
          arrive_sounds[0].setPosition(0);
          arrive_sounds[0].pause(false);
        }
        break;
      case Email:
        debugOutput += "Email from ";
        if (playVoice && ttsVoice!=null && !ttsVoice.isDeleted() && !ttsVoice.isPaused()) {
          emailList.add(notification);
        }
        if (arrive_sounds[1]!=null && receive[env_context][1]) {
          arrive_sounds[1].setPosition(0);
          arrive_sounds[1].pause(false);
        }
        break;
      case VoiceMail:
        debugOutput += "Voicemail from ";
        if (playVoice && ttsVoice!=null && !ttsVoice.isDeleted() && !ttsVoice.isPaused()) {
          vmList.add(notification);
        }
        if (vm_arrive_gain[10] != null && receive[env_context][4]) {
          vm_arrive_gain[10].pause(false);
        }
        break;
      case MissedCall:
        debugOutput += "Missed call from ";
        if (playVoice && ttsVoice!=null && !ttsVoice.isDeleted() && !ttsVoice.isPaused()) {
         callList.add(notification);
        }
        if (arrive_sounds[3]!=null && receive[env_context][3]) {
          arrive_sounds[3].setPosition(0);
          arrive_sounds[3].pause(false);
        }
        break;
      case TextMessage:
        debugOutput += "Text from ";
        if (playVoice && ttsVoice!=null && !ttsVoice.isDeleted() && !ttsVoice.isPaused()) {
          textList.add(notification);
        }
        if (arrive_sounds[2]!=null && receive[env_context][2]) {
          arrive_sounds[2].setPosition(0);
          arrive_sounds[2].pause(false);
        }
        break;
    }
    debugOutput += notification.getSender();
    voiceOut = debugOutput;
    debugOutput += ", " + notification.getMessage() + "\npriority=" +notification.getPriorityLevel();
    lastMessage = debugOutput;
    if (ttsMaker != null && playVoice && (ttsVoice==null || ttsVoice.isDeleted() || ttsVoice.isPaused())) {
      speech(voiceOut);
    }
    println(debugOutput);
  }
}

void speech(String words) { 
  String ttsFilePath = ttsMaker.createTTSWavFile(words);
  try {
  ttsVoice = getSamplePlayer(ttsFilePath, true); 
  ac.out.addInput(ttsVoice);
  ttsVoice.setToLoopStart();
  ttsVoice.start();
  } catch (Exception e) {
    println("Could not say: " + words);
  }
}