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
float[] env_gain_volume = new float[4];
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
int jsonNum = 1;

void setup() {
  size(700,700);
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
  //Setup Env sounds.
  //Setup env gain.
  //Setup env gain volumes.
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
  heartbeat = !heartbeat;
}

void Json1() {
  jsonNum = 1;
}

void Json2() {
  jsonNum = 2;
}

void Json3() {
  jsonNum = 3;
}