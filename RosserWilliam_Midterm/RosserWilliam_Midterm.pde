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
Gain master_gain;
Glide master_glide;
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
  
  master_glide = new Glide(ac,0.75,25);
  master_gain = new Gain(ac,1,master_glide);
  master_gain.addInput(env_gain);
  heartbeatSound = getSamplePlayer("heartbeat.wav");
  heartbeatSound.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  master_gain.addInput(heartbeatSound);
  
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
}

void Workout() {
  env_context = 0;
  env_sounds[0].pause(false);
  env_sounds[1].pause(true);
  env_sounds[2].pause(true);
  env_sounds[3].pause(true);
}

void Walking() {
  env_context = 1;
  env_sounds[0].pause(true);
  env_sounds[1].pause(false);
  env_sounds[2].pause(true);
  env_sounds[3].pause(true);
}

void Socializing() {
  env_context = 2;
  env_sounds[0].pause(true);
  env_sounds[1].pause(true);
  env_sounds[2].pause(false);
  env_sounds[3].pause(true);
}

void Presenting() {
  env_context = 3; 
  env_sounds[0].pause(true);
  env_sounds[1].pause(true);
  env_sounds[2].pause(true);
  env_sounds[3].pause(false);
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