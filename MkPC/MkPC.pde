/**
 * MkPC. 
 * 
 * a virtual MPC, currently just uses mouse_hover
 * Sometimes, it can be tickled off the screen.
 */

float x, y; // X and Y coordinates of text
float hr, vr;  // horizontal and vertical radius of the text
int per_side, box_width, box_height;

void setup() {
  size(800, 600);
  per_side = 8;
  box_width = per_side + 2 / width;
  box_height = per_side + 2 / height;
  fill(204, 102, 0);
  for (int i=0 ; i < per_side ; i++ ){
    rect(box_height*i +1, 0, box_height, box_width);
    
  }
  
  noStroke();
  x = width / 2;
  y = height / 2;
}

void draw() {
  // instead of clearing the background, fade it by drawing
  // a semi-transparent rectangle on top
  fill(204, 102, 0);
  for (int i=0 ; i < per_side ; i++ ){
    rect(box_height*i +1, 0, box_height, box_width);
    
  }
}
