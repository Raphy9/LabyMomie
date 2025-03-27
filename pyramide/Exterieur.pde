float[][] hauteursSol;
// Le terrain  l'extérieur
int TAILLE_DESERT = 100;

PImage createTextureCiel() {
  PImage result = createImage(512, 512, RGB);
  result.loadPixels();
  
  for (int y = 0; y < result.height; y++) {
    for (int x = 0; x < result.width; x++) {
      // Dégradé de bleu du haut (plus clair) vers le bas (plus foncé)
      float blueValue = map(y, 0, result.height, 230, 130);
      float greenValue = map(y, 0, result.height, 180, 130);
      float redValue = map(y, 0, result.height, 150, 100);
      
      // Ajouter des nuages avec du bruit de Perlin
      float cloudNoise = noise(x * 0.01, y * 0.01) * 80;
      if (cloudNoise > 50) {
        float cloudIntensity = map(cloudNoise, 50, 80, 0, 1);
        redValue = lerp(redValue, 255, cloudIntensity);
        greenValue = lerp(greenValue, 255, cloudIntensity);
        blueValue = lerp(blueValue, 255, cloudIntensity);
      }
      
      result.pixels[y * result.width + x] = color(redValue, greenValue, blueValue);
    }
  }
  
  result.updatePixels();
  return result;
}

void genererSolDesertique() {
  hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];
  
  for (int i = 0; i < TAILLE_DESERT; i++) {
    for (int j = 0; j < TAILLE_DESERT; j++) {
      // On utilise ici du 'bruit' pour moduler la hauteur
      hauteursSol[i][j] = map(noise(i/10.0, j/10.0), 0, 1, -2, 2);
    }
  }
}

PImage createTextureSable() {
  PImage result = createImage(256, 256, RGB);
  result.loadPixels();
  for (int y = 0; y < result.height; y++) {
    for (int x = 0; x < result.width; x++) {
      float r = 240 + random(-70, 15);
      float g = 210 + random(-70, 15);
      float b = 130 + random(-20, 15);
      
      // On ajoute du bruit pour la texture granuleuse
      float n = noise(x * 0.05, y * 0.05) * 30;
      
      result.pixels[y * result.width + x] = color(
        constrain(r - n, 200, 255),
        constrain(g - n, 170, 230),
        constrain(b - n, 80, 150)
      );
    }
  }
  
  result.updatePixels();
  return result;
}

void renderCiel() {
  pushMatrix();
  
  // On désactive la profondeur pour dessiner le ciel en arrière-plan
  hint(DISABLE_DEPTH_TEST);
  
  // On dessine un cube très grand autour de la scène
  float skySize = 2000;
  noStroke();
  
  // Dessiner le ciel avec la texture
  beginShape(QUADS);
  texture(textureCiel);
  
  // Face avant
  vertex(-skySize, -skySize, -skySize, 0, 0);
  vertex(skySize, -skySize, -skySize, 1, 0);
  vertex(skySize, -skySize, skySize, 1, 1);
  vertex(-skySize, -skySize, skySize, 0, 1);
  
  // Face arrière
  vertex(-skySize, skySize, -skySize, 0, 0);
  vertex(skySize, skySize, -skySize, 1, 0);
  vertex(skySize, skySize, skySize, 1, 1);
  vertex(-skySize, skySize, skySize, 0, 1);
  
  // Face gauche
  vertex(-skySize, -skySize, -skySize, 0, 0);
  vertex(-skySize, skySize, -skySize, 1, 0);
  vertex(-skySize, skySize, skySize, 1, 1);
  vertex(-skySize, -skySize, skySize, 0, 1);
  
  // Face droite
  vertex(skySize, -skySize, -skySize, 0, 0);
  vertex(skySize, skySize, -skySize, 1, 0);
  vertex(skySize, skySize, skySize, 1, 1);
  vertex(skySize, -skySize, skySize, 0, 1);
  
  // Face supérieure (ciel)
  vertex(-skySize, -skySize, skySize, 0, 0);
  vertex(skySize, -skySize, skySize, 1, 0);
  vertex(skySize, skySize, skySize, 1, 1);
  vertex(-skySize, skySize, skySize, 0, 1);
  
  endShape();
  
  hint(ENABLE_DEPTH_TEST);
  
  popMatrix();
}

void renderSolDesertique(boolean light) {
  pushMatrix();
  // Positionner le sol en dessous de la pyramide
  translate(-TAILLE_DESERT*10, -TAILLE_DESERT*10, -5);
  if( light ){
    directionalLight(240, 175, 44, 0.5, 0.5, -1);
  }
   //resetShader();   // sinon ça fait un sol vert bizarre 
  pushMatrix();
  fill(255, 251, 0); // même couleur que pour les murs extérieurs.
  popMatrix();
  // Appliquer la texture de sable
  texture(textureSable);
  
  // Dessiner la grille de quads avec hauteur modulée (pour obtenir un effet un peu vague)
  for (int i = 0; i < TAILLE_DESERT-1; i++) {
    for (int j = 0; j < TAILLE_DESERT-1; j++) {
      beginShape(QUADS);
      texture(textureSable);
      vertex(i*20, j*20, hauteursSol[i][j], i/float(TAILLE_DESERT), j/float(TAILLE_DESERT));
      vertex((i+1)*20, j*20, hauteursSol[i+1][j], (i+1)/float(TAILLE_DESERT), j/float(TAILLE_DESERT));
      vertex((i+1)*20, (j+1)*20, hauteursSol[i+1][j+1], (i+1)/float(TAILLE_DESERT), (j+1)/float(TAILLE_DESERT));
      vertex(i*20, (j+1)*20, hauteursSol[i][j+1], i/float(TAILLE_DESERT), (j+1)/float(TAILLE_DESERT));
      
      endShape();
    }
  }
  popMatrix();
}

void gestionRenderSol() {
  if (estExterieur) {
    renderSolDesertique(true);
  } else {
    renderSolDesertique(false);
  }
}

// Fonction pour vérifier si le joueur est à l'extérieur de la pyramide
boolean checkSiExterieur() {
  int labSize = LAB_SIZES[niveauActuel];
  int decalage = DECALAGES[niveauActuel];
  
  // Si le joueur est en dehors des limites du labyrinthe actuel
  if (posX < decalage || posX >= labSize + decalage || 
      posY < decalage || posY >= labSize + decalage) {
    return true;
  }
  
  return false;
}
