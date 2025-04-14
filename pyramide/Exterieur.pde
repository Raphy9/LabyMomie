// ======= Variables ========
float[][] hauteursSol;
int TAILLE_DESERT = 350;
PShader sandstormShader;

// ============= Boolean Exterieur ===================
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

// ==================================== Ciel ==================================

// ==== Initialise la texture de ciel ====
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

// ===== Effectue le rendu du ciel ======= 
void renderCiel() {
  pushMatrix();

  hint(DISABLE_DEPTH_TEST);

  noLights();

  noTint();

  float skySize = 2000;
  int detail = 24;

  textureMode(NORMAL);

  noStroke();

  // On dessine la sphère 'manuellement'
  beginShape(TRIANGLES);
  texture(textureCiel);

  // On génère les sommets de la sphère avec les coordonnées UV appropriées
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

  hint(ENABLE_DEPTH_TEST);

  popMatrix();
}

// ============================= Shader de tempete de sable ==========================

// ==== Initialise le shader de tempete de sable ====
void initSandstormShader() {
  sandstormShader = loadShader("sandstormFragment.glsl", "sandstormVertex.glsl");

  // Initialisation des paramètres du shader
  sandstormShader.set("resolution", float(width), float(height));
  sandstormShader.set("windDirection", 0.8, 0.2);
  sandstormShader.set("windStrength", 1.5);
}

// ==== Update le shader de tempete de sable ====
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

// ==== Applique le shader de tempete de sable ====
void applySandstormEffect() {
  updateSandstormShader();

  filter(sandstormShader);
}

// ============================= Sol Desertique et Terrain =====================

// ==== Gere les rendus du sol desertique ====
void gestionRenderSol() {
  if (estExterieur) {
    genererSolDesertique();
    renderSolDesertique(true);
  }
}

// ==== Effectue le rendu du sol desertique ====
void renderSolDesertique(boolean light) {
  pushMatrix();
  // Positionner le sol en dessous de la pyramide
  translate(-TAILLE_DESERT*10, -TAILLE_DESERT*10, -5);
  if ( light ) {
    directionalLight(244, 164, 96, 1.5, 0.5, -1);
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

// ==== Genere le sol désertique ====
void genererSolDesertique() {
  hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];

  for (int i = 0; i < TAILLE_DESERT; i++) {
    for (int j = 0; j < TAILLE_DESERT; j++) {
      // On utilise ici du 'bruit' pour moduler la hauteur
      hauteursSol[i][j] = map(noise(i/40.0, j/40.0), 0, 1, -26, 26);
    }
  }
}

// ==== Donne la hauteur du terrain à une position donnée ====
float getTerrainHeight(float x, float y) {
  // On convertit les coordonnées du joueur en indices pour le tableau hauteursSol
  // On doit tenir compte du décalage du terrain (-TAILLE_DESERT*10, -TAILLE_DESERT*10)
  // et de l'échelle (20 unités par case)

  int i = int((x * 20 + TAILLE_DESERT * 10) / 20);
  int j = int((y * 20 + TAILLE_DESERT * 10) / 20);

  // On vérifie que les indices sont valides.
  if (i < 0) i = 0;
  if (i >= TAILLE_DESERT - 1) i = TAILLE_DESERT - 2;
  if (j < 0) j = 0;
  if (j >= TAILLE_DESERT - 1) j = TAILLE_DESERT - 2;

  float fracX = ((x * 20 + TAILLE_DESERT * 10) / 20) - i;
  float fracY = ((y * 20 + TAILLE_DESERT * 10) / 20) - j;

  // On réalise une interpolation pour obtenir une hauteur lisse
  float h1 = hauteursSol[i][j];
  float h2 = hauteursSol[i+1][j];
  float h3 = hauteursSol[i][j+1];
  float h4 = hauteursSol[i+1][j+1];

  // Interpolation en x pour les deux paires de points
  float hA = lerp(h1, h2, fracX);
  float hB = lerp(h3, h4, fracX);

  // Interpolation en y entre les résultats précédents
  float height = lerp(hA, hB, fracY);

  return height;
}
