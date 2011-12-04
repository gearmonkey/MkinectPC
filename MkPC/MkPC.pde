/**
 * MkPC. 
 * 
 * a virtual MPC, currently just uses mouse_hover
 * Sometimes, it can be tickled off the screen.
 */


import beads.*;
import SimpleOpenNI.*;


//launchpad bits
import themidibus.*;
import com.rngtng.launchpad.*;
Launchpad launchpad;

AudioContext ac;
SamplePlayer player1, player2, player3, player4, player5;
Static start1, end1, start2, end2;

SimpleOpenNI  context;
MoveDetect md, md1;//, md2, md3, md4;

color fore = color(255, 102, 204);
color back = color(0,0,0);
boolean drawMovement = true;
int audioBuffer = 1000;

public void launchpadGridPressed(int x, int y) {
  println("GridButton pressed at: " + x + ", " + y);
  launchpad.changeGrid(x, y, LColor.YELLOW_HIGH);
  if (x==0  && y==0){
    player1.reTrigger();
  }else if (x==1 && y==0){
    player2.reTrigger();
  }
}

public void launchpadGridReleased(int x, int y) {
  println("GridButton released at: " + x + ", " + y);
  if ((x==0 || x==1) && (y==0)){
    launchpad.changeGrid(x, y, LColor.RED_HIGH);
  }else{
    launchpad.changeGrid(x, y, LColor.OFF);
  }
}

void setup() {
  size(800, 600);
  
  launchpad = new Launchpad(this);
  launchpad.changeGrid(0, 0, LColor.RED_HIGH);
  launchpad.changeGrid(1, 0, LColor.RED_HIGH);
  
  context = new SimpleOpenNI(this);
  md = new MoveDetect();
  md1 = new MoveDetect();
//  md2 = new MoveDetect();
//  md3 = new MoveDetect();
//  md4 = new MoveDetect();
  
  // enable depthMap generation 
  context.enableDepth();
  
  // enable skeleton generation for all joints
  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
 
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
  
  size(context.depthWidth(), context.depthHeight());
  
  ac = new AudioContext();
//  String audioFile1 = selectInput("this will play with 'space'...");
  String audioFile1 = "/Users/bfields/Documents/Processing/MkPC/data/25649__walter-odington__subby-kick.wav";
  SampleManager.setBufferingRegime(Sample.Regime.newStreamingRegime(audioBuffer));
  player1 = new SamplePlayer(ac, SampleManager.sample(audioFile1));
  player1.setKillOnEnd(false);
//  start1 = new Static(ac,70000);
//  end1 = new Static(ac,75000);
//  player1.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
//  player1.setLoopStart(start1);
//  player1.setLoopEnd(end1);
  
  Gain g1 = new Gain(ac, 2, 0.7);
  g1.addInput(player1);
  ac.out.addInput(g1);
  
//  String audioFile2 = selectInput("this will play with 'a'...");
  String audioFile2 = "/Users/bfields/Documents/Processing/MkPC/data/439__tictacshutup__prac-snare-2.wav";
  player2 = new SamplePlayer(ac, SampleManager.sample(audioFile2));
  player2.setKillOnEnd(false);
//  start2 = new Static(ac,80000);
//  end2 = new Static(ac,85000);
//  player1.setLoopType(SamplePlayer.LoopType.NO_LOOP_FORWARDS);
//  player2.setLoopStart(start2);
//  player2.setLoopEnd(end2);
  
  
  Gain g2 = new Gain(ac, 2, 0.7);
  g2.addInput(player2);
  ac.out.addInput(g2);
  
//  String audioFile3 = selectInput("this will play with 's'...");
//  player3 = new SamplePlayer(ac, SampleManager.sample(audioFile3));
//  player3.setKillOnEnd(false);
//  
//  Gain g3 = new Gain(ac, 2, 0.7);
//  g3.addInput(player3);
//  ac.out.addInput(g3);
//  
//  String audioFile4 = selectInput("this will play with 'd'...");
//  player4 = new SamplePlayer(ac, SampleManager.sample(audioFile4));
//  player4.setKillOnEnd(false);
//  
//  Gain g4 = new Gain(ac, 2, 0.7);
//  g4.addInput(player4);
//  ac.out.addInput(g4);
//  
//  String audioFile5 = selectInput("this will play with 'f'...");
//  player5 = new SamplePlayer(ac, SampleManager.sample(audioFile5));
//  player5.setKillOnEnd(false);
//  
//  Gain g5 = new Gain(ac, 2, 0.9);
//  g5.addInput(player5);
//  ac.out.addInput(g5);
  
  ac.start();
}


void keyPressed(){
  /*color temp = fore;
  fore = back;
  back = temp;*/
  //player.reset();
  switch (key){
    case ' ':{
    player1.setLoopStart(player1.getLoopStartUGen());
    player1.setLoopEnd(player1.getLoopEndUGen());
    player2.setLoopStart(player2.getLoopStartUGen());
    player2.setLoopEnd(player2.getLoopEndUGen());
    break;
    }case 'a':{
    player1.reTrigger();
    break;
    }case 's':{
    player2.reTrigger();
    break;
    }
//    }case 'd':{
//    player4.reTrigger();
//    break;
//    }case 'f':{
//    player5.reTrigger();
//    break;
//    }
  }
}

void draw() {
    // update the cam
  context.update();
  
  // draw depthImageMap
  imageMode(CENTER);
  image(context.depthImage(),width/2,height/2);
  
  // draw the skeleton if it's available
  if(context.isTrackingSkeleton(1))
    drawSkeleton(1);
  
  loadPixels();
  //set the background
  //Arrays.fill(pixels, back);
  //scan across the pixels
  for(int i = 0; i < width; i++) {
    //for each pixel work out where in the current audio buffer we are
    int buffIndex = i * ac.getBufferSize() / width;
    //then work out the pixel height of the audio data at that point
    int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * height / 2);
    //draw into Processing's convenient 1-D array of pixels
    pixels[vOffset * height + i] = fore;
  }
  updatePixels();
  
  checkMovement(md, SimpleOpenNI.SKEL_LEFT_HAND, color(255,255,255), player1);
  checkMovement(md1, SimpleOpenNI.SKEL_RIGHT_HAND, color(120,120,255), player2);
//  checkMovement(md2, SimpleOpenNI.SKEL_LEFT_FOOT, color(120,255,255), player3);
//  checkMovement(md3, SimpleOpenNI.SKEL_RIGHT_FOOT, color(120,255,120), player4);
//  checkMovement(md4, SimpleOpenNI.SKEL_RIGHT_HIP, color(255,120,120), player5);

}



void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  stroke(2);
  strokeWeight(2);
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}


void checkMovement(MoveDetect detector, int joint, color mvColor, SamplePlayer player)
{
    // calculate new joint movement function sample
  detector.jointMovementFunction(1, joint);
  
  if (drawMovement)
  {  // plot the movement function
    detector.plotMovementFunction(mvColor);
  }
  if (detector.swipeStart == 1)
  {
    player.reTrigger();
    println("ONSET START:::::" + millis());
  }
  else if (detector.onsetState == 1)
  {
    println("Hand Jerked!");
  }
  else if (detector.swipeEnd == 1)
  {       
     println("ONSET END:::::" + millis());
  }
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  
  context.startPoseDetection("Psi",userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId); 
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi",userId);
  }
}

void onStartPose(String pose,int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");
  
  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
 
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}
