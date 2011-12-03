/**
 * MkPC. 
 * 
 * a virtual MPC, currently just uses mouse_hover
 * Sometimes, it can be tickled off the screen.
 */


import beads.*;

AudioContext ac;
SamplePlayer player;

color fore = color(255, 102, 204);
color back = color(0,0,0);

void setup() {
  size(800, 600);
  ac = new AudioContext();
  String audioFile = selectInput();
  player = new SamplePlayer(ac, SampleManager.sample(audioFile));
  player.setKillOnEnd(false);
  
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  ac.start();
}


void mouseClicked(){
  /*color temp = fore;
  fore = back;
  back = temp;*/
  //player.reset();
  player.reTrigger();
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
