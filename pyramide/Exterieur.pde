float[][] hauteursSol;
// Le terrain  l'extérieur
int TAILLE_DESERT = 150;

// Shader pour simuler les grains de sable volant dans le vent
PShader sandstormShader;

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

void initSandstormShader() {
  sandstormShader = loadShader("sandstormFragment.glsl", "sandstormVertex.glsl");
  
  // Initialisation des paramètres du shader
  sandstormShader.set("resolution", float(width), float(height));
  sandstormShader.set("windDirection", 0.8, 0.2); // Direction du vent (x, y)
  sandstormShader.set("windStrength", 1.5); // Force du vent (augmentée)
}

// Fonction pour mettre à jour les paramètres du shader de tempête de sable
void updateSandstormShader() {
  // Mise à jour du temps pour l'animation
  sandstormShader.set("time", time);
  
  // Variation de la force du vent avec le temps pour un effet plus naturel
  // Amplitude augmentée pour des pics plus intenses
  float windVariation = sin(time * 0.1) * 1.0 + 1.2; // Valeur de base plus élevée avec forte amplitude
  
  // Assurer que la force du vent tombe à presque zéro à certains moments
  // pour que le sable disparaisse complètement
  if (sin(time * 0.1) < -0.8) {
    windVariation = 0.2; // Force minimale qui fait disparaître l'effet
  }
  
  sandstormShader.set("windStrength", windVariation);
  
  // Variation légère de la direction du vent
  float windDirX = 0.8 + sin(time * 2) * 0.01;
  float windDirY = 0.2 + cos(time * 2) * 0.15;
  sandstormShader.set("windDirection", windDirX, windDirY);
}



void genererSolDesertique() {
  hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];
  
  for (int i = 0; i < TAILLE_DESERT; i++) {
    for (int j = 0; j < TAILLE_DESERT; j++) {
      // On utilise ici du 'bruit' pour moduler la hauteur
      hauteursSol[i][j] = map(noise(i/14.0, j/14.0), 0, 1, -8, 8);
    }
  }
}

void renderCiel() {
  pushMatrix();
  
  // Désactiver la profondeur pour dessiner en arrière-plan
  hint(DISABLE_DEPTH_TEST);
  
  // Désactiver l'éclairage
  noLights();
  
  // S'assurer qu'aucune teinte n'est appliquée
  noTint();
  
  float skySize = 2000;
  int detail = 24; // Niveau de détail de la sphère
  
  // Utiliser le mode de texture NORMAL
  textureMode(NORMAL);
  
  // Désactiver les contours
  noStroke();
  
  // Dessiner la sphère manuellement avec des triangles
  beginShape(TRIANGLES);
  texture(textureCiel);
  
  // Générer les sommets de la sphère avec les coordonnées UV appropriées
  for (int i = 0; i < detail; i++) {
    float lat1 = map(i, 0, detail, 0, PI);
    float lat2 = map(i + 1, 0, detail, 0, PI);
    
    for (int j = 0; j < detail; j++) {
      float lon1 = map(j, 0, detail, 0, TWO_PI);
      float lon2 = map(j + 1, 0, detail, 0, TWO_PI);
      
      // Coordonnées UV
      float u1 = map(lon1, 0, TWO_PI, 0, 1);
      float u2 = map(lon2, 0, TWO_PI, 0, 1);
      float v1 = map(lat1, 0, PI, 0, 1);
      float v2 = map(lat2, 0, PI, 0, 1);
      
      // Premier triangle
      vertex(skySize * sin(lat1) * cos(lon1), skySize * sin(lat1) * sin(lon1), skySize * cos(lat1), u1, v1);
      vertex(skySize * sin(lat2) * cos(lon1), skySize * sin(lat2) * sin(lon1), skySize * cos(lat2), u1, v2);
      vertex(skySize * sin(lat2) * cos(lon2), skySize * sin(lat2) * sin(lon2), skySize * cos(lat2), u2, v2);
      
      // Deuxième triangle
      vertex(skySize * sin(lat1) * cos(lon1), skySize * sin(lat1) * sin(lon1), skySize * cos(lat1), u1, v1);
      vertex(skySize * sin(lat2) * cos(lon2), skySize * sin(lat2) * sin(lon2), skySize * cos(lat2), u2, v2);
      vertex(skySize * sin(lat1) * cos(lon2), skySize * sin(lat1) * sin(lon2), skySize * cos(lat1), u2, v1);
    }
  }
  
  endShape();
  
  // Réactiver la profondeur
  hint(ENABLE_DEPTH_TEST);
  
  popMatrix();
}

// Fonction pour appliquer l'effet de tempête de sable
void applySandstormEffect() {
  // Mettre à jour les paramètres du shader
  updateSandstormShader();
  
  // Appliquer le shader comme filtre post-traitement
  filter(sandstormShader);
}

void renderSolDesertique(boolean light) {
  pushMatrix();
  // Positionner le sol en dessous de la pyramide
  translate(-TAILLE_DESERT*10, -TAILLE_DESERT*10, -5);
  if( light ){
    directionalLight(240, 175, 44, 0.5, 0.5, -1);
  }
  // Dessiner la grille de quads avec hauteur modulée (pour obtenir un effet un peu vague)
  for (int i = 0; i < TAILLE_DESERT-1; i++) {
    for (int j = 0; j < TAILLE_DESERT-1; j++) {
      beginShape(QUADS);
      texture(textureSable);
      vertex(i*20, j*20, hauteursSol[i][j], 0, 0);
      vertex((i+1)*20, j*20, hauteursSol[i+1][j], 1, 0);
      vertex((i+1)*20, (j+1)*20, hauteursSol[i+1][j+1], 1, 1);
      vertex(i*20, (j+1)*20, hauteursSol[i][j+1], 0, 1);
      
      endShape();
    }
  }
  popMatrix();
}

void gestionRenderSol() {
  if (estExterieur) {
    genererSolDesertique();
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
