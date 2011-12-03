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
SamplePlayer player1, player2;

SimpleOpenNI  context;
MoveDetect md, md1, md2, md3;

color fore = color(255, 102, 204);
color back = color(0,0,0);
boolean drawMovement = true;

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
  String audioFile1 = selectInput("this will play with 'space'...");
  player1 = new SamplePlayer(ac, SampleManager.sample(audioFile1));
  player1.setKillOnEnd(false);
  
  Gain g1 = new Gain(ac, 2, 0.4);
  g1.addInput(player1);
  ac.out.addInput(g1);
  
  String audioFile2 = selectInput("this will play with 'a'...");
  player2 = new SamplePlayer(ac, SampleManager.sample(audioFile2));
  player2.setKillOnEnd(false);
  
  Gain g2 = new Gain(ac, 2, 0.4);
  g2.addInput(player2);
  ac.out.addInput(g2);
  
  ac.start();
}


void keyPressed(){
  /*color temp = fore;
  fore = back;
  back = temp;*/
  //player.reset();
  switch (key){
    case ' ':{
    player1.reTrigger();
    break;
    }case 'a':{
    player2.reTrigger();
    break;
    }
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
  
  
  // calculate new joint movement function sample
  md.jointMovementFunction(1, SimpleOpenNI.SKEL_LEFT_HAND);
  
  if (drawMovement)
  {  // plot the movement function
    md.plotMovementFunction();
  }
  if (md.swipeStart == 1)
  {
    player1.reTrigger();
    println("ONSET START:::::" + millis());
  }
  else if (md.onsetState == 1)
  {
    println("Hand Jerked!");
  }
  else if (md.swipeEnd == 1)
  {       
     println("ONSET END:::::" + millis());
  }
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
