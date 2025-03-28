ArrayList<PShape> niveauxShapes = new ArrayList<PShape>();
int NIVEAUACTUEL =0;

char[][][] labyrinthes;
char[][][][] sides;
float posX, posY, posZ, dirX, dirY;
float oldDirX, oldDirY;
float oldPosX, oldPosY, oldPosZ;
float hauteur = 10; // Hauteur caméra
int anim = 0;
int animMode = 0; // 0 = pas d'animation, 1 = animation de translation, 2 = animation de rotation
int niveauActuel = 0; // Niveau actuel du joueur (0 = base, 1 = milieu, 2 = sommet)
boolean estExterieur = false; // Si le joueur est à l'extérieur ou pas.

// Textures
PImage textureStone;
PImage textureSable;
PImage textureStoneJaune;
PImage textureCiel;

float time = 0;

void setup() { 
  frameRate(20);
  randomSeed(2);
  size(1000, 1000, P3D);
  
  // Chargement des textures
  textureStone = loadImage("stone.jpg");
  if (textureStone == null) {
    System.out.println("La texture n'existe pas");
  }
  
  textureStoneJaune = createTextureJaune(textureStone);
  textureSable = createTextureSable();
  

  textureCiel = loadImage("360.png");

  
  textureMode(NORMAL);
  
  // Initialisaton Momie
  mummyGroup = createMummy();

  
  // Initialisation des labyrinthes pour chaque niveau
  labyrinthes = new char[NIVEAUX][][];
  sides = new char[NIVEAUX][][][];
  
  for (int niveau = 0; niveau < NIVEAUX; niveau++) {
    labyrinthes[niveau] = new char[LAB_SIZES[niveau]][LAB_SIZES[niveau]];
    sides[niveau] = new char[LAB_SIZES[niveau]][LAB_SIZES[niveau]][4];
    genererLabyrinthe(niveau);
  }
  
  // Chargement des niveaux
  for (int niveau = 0; niveau < NIVEAUX; niveau++) {
    niveauxShapes.add(genererShapeNiveau(niveau));
  }

  
  // Initialisation des variables de position et direction (jai repris ça de mon labyrinthe de base)
  posX = 1.4;
  posY = 1.0;
  posZ = HAUTEURS_NIVEAUX[0];
  dirX = 0;
  dirY = 1;
  oldDirX = dirX;
  oldDirY = dirY;
  oldPosX = posX;
  oldPosY = posY;
  oldPosZ = posZ;
  initMummyPosition();
  // Génération du sol désertique
  genererSolDesertique();
}

void draw() {
  float camX, camY, camZ, lookX, lookY, lookZ;
  
  if (anim > 0) {
    float ratio = float(anim) / 20.0;
    
    if (animMode == 1) {
      float easeRatio = easeInOutQuad(1.0 - ratio);
      
      camX = oldPosX*20 * (1-easeRatio) + posX*20 * easeRatio;
      camY = oldPosY*20 * (1-easeRatio) + posY*20 * easeRatio;
      camZ = oldPosZ * (1-easeRatio) + posZ * easeRatio + hauteur + sin(PI * easeRatio) * 2;
      
      lookX = camX + dirX*20;
      lookY = camY + dirY*20;
      lookZ = camZ - hauteur;
    } 
    else if (animMode == 2) {
      camX = posX*20;
      camY = posY*20;
      camZ = posZ + hauteur;
      
      float interpDirX = oldDirX * ratio + dirX * (1-ratio);
      float interpDirY = oldDirY * ratio + dirY * (1-ratio);
      
      float longueur = sqrt(interpDirX*interpDirX + interpDirY*interpDirY);
      interpDirX /= longueur;
      interpDirY /= longueur;
      
      lookX = posX*20 + interpDirX*20;
      lookY = posY*20 + interpDirY*20;
      lookZ = posZ;
    }
    else {
      camX = posX*20;
      camY = posY*20;
      camZ = posZ + hauteur;
      lookX = posX*20 + dirX*20;
      lookY = posY*20 + dirY*20;
      lookZ = posZ;
    }
  } 
  else {
    camX = posX*20;
    camY = posY*20;
    camZ = posZ + hauteur;
    lookX = posX*20 + dirX*20;
    lookY = posY*20 + dirY*20;
    lookZ = posZ;
  }
  
  background(100, 0, 255); // Fond bleu ciel
  
  camera(
    camX, camY, camZ,
    camX + dirX*20, camY + dirY*20, camZ,
    0, 0, -1
  );
  
  // Dessiner le ciel uniquement si on est à l'extérieur
  if (estExterieur) {
    renderCielAlternatif();
  }
  
  // Mise à jour du temps pour les shaders
  time += 0.05;
  
  if (anim > 0) {
    anim--;
  }
  
  gestionDeplacements();
  
  updateMummy();
  
  perspective(PI/3.0, float(width)/float(height), 1, 1000);
  
  estExterieur = checkSiExterieur();
  
  resetShader();
  noTint();
  
  
  configLights();
  
  gestionRenderSol();
  
  renderPyramide();
  
  renderMummy();
  
  // On réinitialise la teinte pour les éléments suivants
  noTint();
  
  // Afficher les indications pour les escaliers
  gererEscaliers();
  
  drawMiniMap();
}

// Pour la pyramide complète
void renderPyramide() {
  shape(niveauxShapes.get(NIVEAUACTUEL));
  renderPyramideLisseExterieure();
}

void configLights() {
    // Configuration de l'éclairage selon la position du joueur
  if (estExterieur) {
    // Éclairage extérieur (clair)
    directionalLight(200, 200, 200, 0.5, 0.5, -1);
  } else {
    // Éclairage intérieur (sombre mais suffisant pour voir les murs)

    pointLight(200, 200, 250, posX*2, posY*2, posZ + hauteur + 5);
    lightFalloff(1.0, 0.1, 0.01);
  }
}

// Petite fonction d'accélération pour des animations moins saccadées.
float easeInOutQuad(float t) {
  return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;
}
