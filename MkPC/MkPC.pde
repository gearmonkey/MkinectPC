/**
 * MkPC. 
 * 
 * a virtual MPC, currently just uses mouse_hover
 * Sometimes, it can be tickled off the screen.
 */


import beads.*;

//launchpad bits
import themidibus.*;
import com.rngtng.launchpad.*;
Launchpad launchpad;

AudioContext ac;
SamplePlayer player1, player2;

color fore = color(255, 102, 204);
color back = color(0,0,0);

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
  if (key==' '){
    player1.reTrigger();
  }
  else if(key=='a'){
    player2.reTrigger();
  }
}

void draw() {
  loadPixels();
  //set the background
  Arrays.fill(pixels, back);
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
}
