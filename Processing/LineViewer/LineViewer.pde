/* LineViewer --- scrolling window display for Arduino line scan image sensor 2010-08-01 */

import processing.serial.*;

final int LINELEN = 128;
final int SCROLLHT = 128;
PImage img;
Serial duino;
boolean Synced = false;

void setup ()
{
  println ("<START>");
  println (Serial.list());
  println ("<END>");

  // Open serial port to Arduino at 115200 baud
  duino = new Serial (this, Serial.list()[2], 115200);
  
  // Window is same width as sensor, but long enough to scroll
  size (LINELEN, SCROLLHT);
  
  // Image is same size as window
  img = createImage (LINELEN, SCROLLHT, RGB);
  
  // Initialise image to a shade of blue
  img.loadPixels ();
  
  for (int i = 0; i < img.pixels.length; i++) {
    img.pixels[i] = color (0, 90, 102); 
  }
  
  img.updatePixels ();
  
  // Choose image update rate
  frameRate (30);
}

void draw ()
{
  int i;
  int ch;
  int nbufs;
  int b;
  int maxi;
  int maxpx;
  byte[] inbuf = new byte[LINELEN + 1];
  
  // Synchronise
  if (Synced) {
    nbufs = duino.available () / (LINELEN + 1);
  }
  else {
    do {
      while (duino.available () == 0)
        ;
        
      ch = duino.read ();
      
    } while (ch != 0);
    nbufs = 0;
    Synced = true;
  }
  
  // print (nbufs);
  // print (", ");

  // Load the image pixels in preparation for next frame(s)
  img.loadPixels ();
  
  for (b = 0; b < nbufs; b++) {
    // Scroll the old image data down the window
    for (i = img.pixels.length - LINELEN - 1; i >= 0; i--) {
      img.pixels[i + LINELEN] = img.pixels[i];
    }
    // Read 128 pixels from image sensor, via Arduino
    duino.readBytes (inbuf);
    
    // Check we're still in sync
    if (inbuf[128] != 0) {
      print ("UNSYNC ");
      Synced = false;
    }
    
    maxi = 0;
    maxpx = 0;
    
    // Transfer incoming pixels to image  
    for (i = 0; i < LINELEN; i++) {
      ch = inbuf[i];
      if (ch < 0)
        ch += 256;
      
      if (ch > maxpx) {
        maxi = i;
        maxpx = ch;
      }
      
      img.pixels[i] = color (ch, ch, ch);
    }
    
    img.pixels[maxi] = color (0, 255, 0);
  }

  // We're done updating the image, so re-display it
  img.updatePixels ();
  image (img, 0, 0);
}

