PImage createTextureJaune(PImage original) {
  PImage result = original.copy();
  result.loadPixels();
  
  for (int i = 0; i < result.pixels.length; i++) {
    color c = result.pixels[i];
    float r = red(c);
    float g = green(c);
    float b = blue(c);
    
    // Augmenter les composantes rouge et verte pour rendre la texture plus jaune
    r = min(255, r * 1.2);
    g = min(255, g * 1.1);
    b = min(255, b * 0.7); // Réduire le bleu
    
    result.pixels[i] = color(r, g, b);
  }
  
  result.updatePixels();
  return result;
}

void renderPyramideLisseExterieure(int hauteurSommet, int nbCases, int nbUnites, boolean onBouche) {
  // Taille de base : la pyramide la plus large fait 21 cases × 20 unités = 420
  float baseSize = nbCases * nbUnites;
  // On place le sommet à 300 en Z
  float apexZ = hauteurSommet;
                                      
  pushMatrix();
  noStroke();

textureWrap(REPEAT);
  float t = -apexZ / (20 - apexZ);
  
  
  // Face 1 (devant toit)
    beginShape(TRIANGLES);
      fill(255);
      vertex((baseSize/2) * ((apexZ - 60) / (apexZ - 20)),         (baseSize/2) * ((apexZ - 60) / (apexZ - 20)),        apexZ-40, 0,  0);
      vertex(baseSize - (baseSize/2) * ((apexZ - 60) / (apexZ - 20)),  (baseSize/2) * ((apexZ - 60) / (apexZ - 20)),        apexZ-40, 20,  0);
      vertex(baseSize/2, baseSize/2, apexZ+1,10,  20);
    endShape();
  

    // Face 1 (devant)
    beginShape(TRIANGLES);
      texture(textureStoneJaune);
      // On mappe la texture comme on veut (u,v). Ici, simple.
      vertex(0,        0,        20, 0,  0);
      vertex(baseSize, 0,        20, 20,  0);
      vertex(baseSize/2, baseSize/2, apexZ,10,  20);
    endShape();
    
    //truc pour l'entrée etc..
    // Entrée droite (quad)
    beginShape(QUADS);
      texture(textureStoneJaune);
      vertex(baseSize, 0, 20, 0, 0);             // haut gauche
      vertex(40, 0, 20, 18, 0);                   // haut droite
      vertex(40, -15, 0, 18, 1.2);                 // bas droite
      vertex(baseSize+15, -15, 0, 0, 1.2);        // bas gauche
    endShape();
  
    // Côté droit (triangle)
    beginShape(TRIANGLES);
      texture(textureStoneJaune);
      vertex(40, 0, 20, 0, 0);                    // sommet haut
      vertex(40, -15, 0, 0, 1);                 // bas gauche
      vertex(40, 0, 0, 0.8, 1);                    // bas droite
    endShape();
  
    // Entrée gauche (quad)
     beginShape(QUADS);
      texture(textureStoneJaune);
      vertex(20, 0, 20, 0, 0);                   // haut gauche
      vertex(0, 0, 20, 1.2, 0);                     // haut droite
      vertex(-15, -15, 0, 1.2, 1.2);                 // bas droite
      vertex(20, -15, 0,0, 1.2);                 // bas gauche
    endShape();
  
    // Côté gauche (triangle)
     beginShape(TRIANGLES);
      texture(textureStoneJaune);
      vertex(20, 0, 20, 0, 0);                    // sommet haut
      vertex(20, 0, 0, 0.8, 1);                    // bas droite
      vertex(20, -15, 0, 0, 1);                 // bas gauche
    endShape();
    
  // Porte avant
  if(onBouche) {
    beginShape(QUADS);
    texture(textureStoneJaune);
    vertex(20, 0, 20, 0, 0);  
    vertex(40, 0, 20, 1, 0);   
    vertex(40, -15, 0, 1, 1); 
    vertex(20, -15, 0, 0, 1); 
    endShape(QUADS);
  }
  else {
    beginShape(QUADS);
    texture(texturePorte);
    vertex(20, 0, 20, 0, 0);  
    vertex(40, 0, 20, 1, 0);   
    vertex(40, 0, 0, 1, 1); 
    vertex(20, 0, 0, 0, 1); 
    endShape(QUADS);
  }



  // Face 2 (arrière)
  beginShape(TRIANGLES);
    texture(textureStoneJaune);
    //vertex(baseSize, 0,     20,     0,   0);
    //vertex(baseSize, baseSize, 20, 20,   0);
    
    vertex(baseSize/2 * (1+t), baseSize/2 * (1+t), 0, 0, 0);
    vertex(baseSize/2 * (1-t), baseSize/2 * (1+t), 0, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ, 10, 20); 
  endShape();
  
  // Face 2 (arrière toit)
  beginShape(TRIANGLES);
    fill(255);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),  (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),        apexZ-40, 0, 0);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),  baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ+1, 10, 20);
  endShape();

  
  
    // Face 3 (droite)
    beginShape(TRIANGLES);
      texture(textureStoneJaune);
      vertex(baseSize, 0,     20,     0,   0);
      vertex(baseSize, baseSize, 20, 20,   0);
      vertex(baseSize/2, baseSize/2, apexZ, 10, 20);
    endShape();
    
    //truc pour l'entrée etc..
    // Entrée droite (quad)
    beginShape(QUADS);
      texture(textureStoneJaune);
      vertex(baseSize, baseSize     , 20, 0, 0);             // haut gauche
      vertex(baseSize, baseSize-20, 20, 1.2, 0);                   // haut droite
      vertex(baseSize+15, baseSize-20, 0, 1.2, 1.2);                 // bas droite
      vertex(baseSize+15, baseSize+15, 0, 0, 1.2);        // bas gauche
    endShape();
    
    // Côté droit (triangle)
    beginShape(TRIANGLES);
      texture(textureStoneJaune);
      vertex(baseSize, baseSize-20,   20, 0, 0);                    // sommet haut
      vertex(baseSize+15, baseSize-20, 0, 0, 1);                  // bas gauche
      vertex(baseSize, baseSize-20,    0, 1, 1);                    // bas droite
    endShape();
    
    // Entrée gauche (quad)
    beginShape(QUADS);
      texture(textureStoneJaune);
      vertex(baseSize, baseSize-40, 20, 18, 0);                   // haut gauche
      vertex(baseSize, 0, 20, 0, 0);               // haut droite
      vertex(baseSize+15, -15, 0, 0, 1.2);        // bas droite
      vertex(baseSize+15, baseSize-40, 0, 18, 1.2);                 // bas gauche
    endShape();
    
    // Côté gauche (triangle)
    beginShape(TRIANGLES);
      texture(textureStoneJaune);
      vertex(baseSize, baseSize-40, 20, 0, 0);                    // sommet haut
      vertex(baseSize+15, baseSize-40, 0, 0, 1);                   // bas droite
      vertex(baseSize, baseSize-40, 0, 1, 1);                    // bas gauche
    endShape();
    
   // Porte droite
   if(onBouche) {
    beginShape(QUADS);
    texture(textureStoneJaune);
    vertex(baseSize, baseSize-20, 20, 0, 0);  
    vertex(baseSize, baseSize-40,   20, 0, 1);   
    vertex(baseSize+15, baseSize-40, 0, 0, 1); 
    vertex(baseSize+15, baseSize-20, 0, 0, 0);             
    endShape(QUADS);
   }
   else {
    beginShape(QUADS);
    texture(texturePorte);
    vertex(baseSize, baseSize-40, 20, 0, 0);  
    vertex(baseSize, baseSize-20,   20, 1, 0);   
    vertex(baseSize, baseSize-20,   0, 1, 1); 
    vertex(baseSize, baseSize-40, 0, 0, 1); 
    endShape(QUADS);
   }

  // Face 3 (droite toit)
  beginShape(TRIANGLES);
    fill(255);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),  baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 0, 0);
    vertex((baseSize/2) * ((apexZ - 60)/(apexZ - 20)),         baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ+1, 10, 20);
  endShape();


  // Face 4 (gauche)
  beginShape(TRIANGLES);
    texture(textureStoneJaune);
    vertex(baseSize/2 * (1-t), baseSize/2 * (1+t), 0, 0, 0);  
    vertex(baseSize/2 * (1-t), baseSize/2 * (1-t), 0, 20, 0);  
    vertex(baseSize/2, baseSize/2, apexZ, 10, 20);
  endShape();


  
 // Face 4 (gauche toit)
  beginShape(TRIANGLES);
    fill(255);
    vertex((baseSize/2) * ((apexZ - 60)/(apexZ - 20)),         baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 0, 0);
    vertex((baseSize/2) * ((apexZ - 60)/(apexZ - 20)),         (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),        apexZ-40, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ+1, 10, 20);
  endShape();

  popMatrix();
}
