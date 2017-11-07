//William Rosser

import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

ControlP5 p5;
AudioContext ac;

/*
  0 = Working out
    Environment = moderate/loud gym sounds
    Interruptibility = High
    Social Environment = Free
  1 = Walking
    Environment = moderate/loud outdoor environment
    Interruptability = Moderately high
    Social = Free
  2 = Socializing
    Environment = moderate/loud indoor environemnt
    Interruptability = Moderately low
    Social Environment = Occupied
  3 = Presenting
    Environment = Quiet, speach+classroom
    Interruptability = Very Low
    Social Environment = Wholly occupied
*/
int env_context = 0;
String[] env_context_label = {"Working Out","Walking","Socializing","Presenting"};
SamplePlayer[] env_sounds = new SamplePlayer[4];
Gain env_gain;
Glide env_glide;
int[] interrupt_level = {4,3,2,1};
int[] social_level = {3,3,2,1};
SamplePlayer[] arrive_sounds = new SamplePlayer[4];
Gain[] arrive_gain = new Gain[4];
WavePlayer[] vm_arrive = new WavePlayer[10];
Gain[] vm_arrive_gain = new Gain[11]; //11 = master vm gain (for pausing.)
int vm_arrive_framecount = 0;

/*
recieve[context][messageType]:
Context = {Tweet, Email, TextMessage, PhoneCall, VoiceMail}
*/
boolean[][] receive = {{true,true,true,true,true},
                        {true,true,true,true,true},
                        {false,false,true,true,false},
                        {false,false,false,true,false}};
boolean heartbeat = true;
SamplePlayer heartbeatSound;
Gain heartbeatGain;
Gain master_gain;
Glide master_glide;
TextToSpeechMaker ttsMaker;
SamplePlayer ttsVoice = null;

int jsonNum = 1;
String eventDataJSON1 = "ExampleData_1.json";
String eventDataJSON2 = "ExampleData_2.json";
String eventDataJSON3 = "ExampleData_3.json";
Listener listener;
NotificationServer server;

void setup() {
  size(700,700);
  
  server = new NotificationServer();
  listener = new Listener();
  server.addListener(listener);
  server.loadEventStream(eventDataJSON1);
  ttsMaker = new TextToSpeechMaker();
  ac = new AudioContext();
  p5 = new ControlP5(this);
  
  p5.addButton("Workout").setPosition(30,30).setSize(70,50).activateBy(ControlP5.RELEASE);
  p5.addButton("Walking").setPosition(120,30).setSize(70,50).activateBy(ControlP5.RELEASE);
  p5.addButton("Socializing").setPosition(210,30).setSize(70,50).activateBy(ControlP5.RELEASE);
  p5.addButton("Presenting").setPosition(300,30).setSize(70,50).activateBy(ControlP5.RELEASE);
  
  p5.addButton("ToggleTwitter").setPosition(200,115).setSize(70,30).activateBy(ControlP5.RELEASE).setLabel("Twitter");
  p5.addButton("ToggleEmail").setPosition(280,115).setSize(70,30).activateBy(ControlP5.RELEASE).setLabel("Emails");
  p5.addButton("ToggleTxt").setPosition(200,155).setSize(70,30).activateBy(ControlP5.RELEASE).setLabel("Text Messages");
  p5.addButton("TogglePhone").setPosition(280,155).setSize(70,30).activateBy(ControlP5.RELEASE).setLabel("Phone Calls");
  p5.addButton("ToggleVoice").setPosition(200,195).setSize(70,30).activateBy(ControlP5.RELEASE).setLabel("Voice Messages");
  
  p5.addButton("ToggleHeartbeat").setPosition(500,30).setSize(80,50).activateBy(ControlP5.RELEASE).setLabel("Toggle Heartbeat");
  
  p5.addButton("Json1").setPosition(30, 260).setSize(50,30).activateBy(ControlP5.RELEASE).setLabel("DATA 1");
  p5.addButton("Json2").setPosition(90, 260).setSize(50,30).activateBy(ControlP5.RELEASE).setLabel("DATA 2");
  p5.addButton("Json3").setPosition(150, 260).setSize(50,30).activateBy(ControlP5.RELEASE).setLabel("DATA 3");
  
  p5.addSlider("MasterVolume").setPosition(400,30).setSize(20,225).setRange(0,100).setValue(75).setLabel("Master\nVolume");
  //EnvVolume
  p5.addSlider("EnvVolume").setPosition(440,30).setSize(20,225).setRange(0,100).setValue(100).setLabel("Environment\nVolume");
  
  master_glide = new Glide(ac,0.75,25);
  master_gain = new Gain(ac,1,master_glide);
  
  env_glide = new Glide(ac,1.0,25);
  env_gain = new Gain(ac,1,env_glide);
  //Setup Env sounds.
  env_sounds[0] = getSamplePlayer("gym.wav");
  env_sounds[1] = getSamplePlayer("walk.wav");
  env_sounds[1].pause(true);
  env_sounds[2] = getSamplePlayer("social.wav");
  env_sounds[2].pause(true);
  env_sounds[3] = getSamplePlayer("present.wav");
  env_sounds[3].pause(true);
  for (int i=0;i<4;i++) {
    env_gain.addInput(env_sounds[i]);
    env_sounds[i].setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  }
  //0=Tweet 1=Email 2=TextMessage 3=PhoneCall 4=VoiceMail
  arrive_sounds[0] = getSamplePlayer("tweet.wav");
  arrive_sounds[0].pause(true);
  arrive_gain[0] = new Gain(ac,1,0.08);
  arrive_gain[0].addInput(arrive_sounds[0]);
  master_gain.addInput(arrive_gain[0]);
  
  arrive_sounds[1] = getSamplePlayer("email_woosh.wav");
  arrive_sounds[1].pause(true);
  arrive_gain[1] = new Gain(ac,1,0.4);
  arrive_gain[1].addInput(arrive_sounds[1]);
  master_gain.addInput(arrive_gain[1]);
  
  arrive_sounds[2] = getSamplePlayer("text_ding.wav");
  arrive_gain[2] = new Gain(ac,1,0.4);
  arrive_gain[2].addInput(arrive_sounds[2]);
  arrive_sounds[2].pause(true);
  master_gain.addInput(arrive_gain[2]);
  
  arrive_sounds[3] = getSamplePlayer("phone.wav");
  arrive_sounds[3].pause(true);
  arrive_gain[3] = new Gain(ac,1,0.15);
  arrive_gain[3].addInput(arrive_sounds[3]);
  master_gain.addInput(arrive_gain[3]);
  
  int vm_a_freq = 330;
  vm_arrive_gain[10] = new Gain(ac,1,.02);
  for (int i = 0; i<10; i++) {
    vm_arrive[i] = new WavePlayer(ac, vm_a_freq*(i+1),Buffer.SINE);
    vm_arrive_gain[i] = new Gain(ac,1,1.0/(i+1));
    vm_arrive_gain[i].addInput(vm_arrive[i]);
    vm_arrive_gain[10].addInput(vm_arrive_gain[i]);
  }
  vm_arrive_gain[10].pause(true);
  master_gain.addInput(vm_arrive_gain[10]);
  
  
  
  master_gain.addInput(env_gain);
  heartbeatSound = getSamplePlayer("heartbeat.wav");
  heartbeatSound.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  heartbeatGain = new Gain(ac, 1, 1);
  heartbeatGain.addInput(heartbeatSound);
  master_gain.addInput(heartbeatGain);
  
  ac.out.addInput(master_gain);
  ac.start();
}

void draw() {
  background(0);
  text("Context: " + env_context_label[env_context],30,20);
  text("Alerts:",30,110);
  text("Toggle Alerts:",200,110);
  text("Twitter: " + ((receive[env_context][0])?"Recieving":"Ignoring"),30,130);
  text("Emails: " + ((receive[env_context][1])?"Recieving":"Ignoring"),30,150);
  text("Text Messages: " + ((receive[env_context][2])?"Recieving":"Ignoring"),30,170);
  text("Phone Calls: " + ((receive[env_context][3])?"Recieving":"Ignoring"),30,190);
  text("Voice Mails: " + ((receive[env_context][4])?"Recieving":"Ignoring"),30,210);
  
  text("Heartbeat: " + ((heartbeat)?"Active":"Muted"),590,55);
  
  text("Json loaded: ExampleData_"+jsonNum+".json",30,250);
  
  text("Latest Message:\n"+lastMessage,30,320);
  if (!vm_arrive_gain[10].isPaused()) {
    if (vm_arrive_framecount < 20) {
      vm_arrive_framecount++;
    } else {
      vm_arrive_gain[10].pause(true);
      vm_arrive_framecount = 0;
    }
  }
  //ArrayList<Notification> tweetList = new ArrayList<Notification>();
  //ArrayList<Notification> emailList = new ArrayList<Notification>();
  //ArrayList<Notification> textList = new ArrayList<Notification>();
  //ArrayList<Notification> callList = new ArrayList<Notification>();
  //ArrayList<Notification> vmList = new ArrayList<Notification>();
  if (ttsMaker != null && (ttsVoice==null || ttsVoice.isDeleted() || ttsVoice.isPaused())) {
    String s = "";
    Notification notification = null;
   if (callList.size() != 0) {
      if (callList.size() > 1) {
        s += callList.size() + " missed calls.";
        callList.clear();
      } else {
        notification = callList.remove(0);
        s += "Missed Call from " + notification.getSender();;
      }
   } else if (tweetList.size() != 0) {
      if (tweetList.size() > 1) {
        s += tweetList.size() + " tweets.";
        tweetList.clear();
      } else {
        notification = tweetList.remove(0);
        s += "Tweet from " + notification.getSender();;
      }
    } else if (emailList.size() != 0) {
      if (emailList.size() > 1) {
        s += emailList.size() + " emails.";
        emailList.clear();
      } else {
        notification = emailList.remove(0);
        s += "Email from " + notification.getSender();;
      }
    } else if (textList.size() != 0) {
      if (textList.size() > 1) {
        s += textList.size() + " texts.";
        textList.clear();
      } else {
        notification = textList.remove(0);
        s += "Text from " + notification.getSender();;
      }
    } else if (vmList.size() != 0) {
      if (vmList.size() > 1) {
        s += vmList.size() + " voice mails.";
        vmList.clear();
      } else {
        notification = vmList.remove(0);
        s += "Voice mail from " + notification.getSender();;
      }
    }
    if (s != "" ) {
      speech(s);
    }
  }
}

void Workout() {
  env_context = 0;
  env_sounds[0].pause(false);
  env_sounds[1].pause(true);
  env_sounds[2].pause(true);
  env_sounds[3].pause(true);
  heartbeatGain.setGain(1);
}

void Walking() {
  env_context = 1;
  env_sounds[0].pause(true);
  env_sounds[1].pause(false);
  env_sounds[2].pause(true);
  env_sounds[3].pause(true);
  heartbeatGain.setGain(1);
}

void Socializing() {
  env_context = 2;
  env_sounds[0].pause(true);
  env_sounds[1].pause(true);
  env_sounds[2].pause(false);
  env_sounds[3].pause(true);
  heartbeatGain.setGain(0.5);
}

void Presenting() {
  env_context = 3; 
  env_sounds[0].pause(true);
  env_sounds[1].pause(true);
  env_sounds[2].pause(true);
  env_sounds[3].pause(false);
  heartbeatGain.setGain(0.1);
}

void ToggleTwitter() {
  receive[env_context][0] = !receive[env_context][0];
}

void ToggleEmail() {
  receive[env_context][1] = !receive[env_context][1];
}

void ToggleTxt() {
  receive[env_context][2] = !receive[env_context][2];
}

void TogglePhone() {
  receive[env_context][3] = !receive[env_context][3];
}

void ToggleVoice() {
  receive[env_context][4] = !receive[env_context][4];
}

void ToggleHeartbeat() {
  heartbeatSound.pause(heartbeat);
  heartbeat = !heartbeat;
}

void MasterVolume(float vol) {
  master_glide.setValue(vol/100.0);
}

void EnvVolume(float vol) {
  env_glide.setValue(vol/100.0);
}

void Json1() {
  jsonNum = 1;
  server.stopEventStream(); //always call this before loading a new stream
  server.loadEventStream(eventDataJSON1);
  println("**** New event stream loaded: " + eventDataJSON1 + " ****");
  tweetList = new ArrayList<Notification>();
  emailList = new ArrayList<Notification>();
  textList = new ArrayList<Notification>();
  callList = new ArrayList<Notification>();
  vmList = new ArrayList<Notification>();
}

void Json2() {
  jsonNum = 2;
  server.stopEventStream(); //always call this before loading a new stream
  server.loadEventStream(eventDataJSON2);
  println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  tweetList = new ArrayList<Notification>();
  emailList = new ArrayList<Notification>();
  textList = new ArrayList<Notification>();
  callList = new ArrayList<Notification>();
  vmList = new ArrayList<Notification>();
}

void Json3() {
  jsonNum = 3;
  server.stopEventStream(); //always call this before loading a new stream
  server.loadEventStream(eventDataJSON3);
  println("**** New event stream loaded: " + eventDataJSON3 + " ****");
  tweetList = new ArrayList<Notification>();
  emailList = new ArrayList<Notification>();
  textList = new ArrayList<Notification>();
  callList = new ArrayList<Notification>();
  vmList = new ArrayList<Notification>();
}