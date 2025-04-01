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
  
  textureCiel = loadImage("ciel.png");
  
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
    renderCiel();
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
  
  noLights(); // sinon les lumières vont affecter la minimap.
  drawMiniMap();
}

// Pour la pyramide complète
void renderPyramide() {
  // Pyramide d'origine (existante)
  pushMatrix();
  shape(niveauxShapes.get(NIVEAUACTUEL));
  renderPyramideLisseExterieure(300, 21, 20);
  popMatrix();

  // Deuxième pyramide (à gauche)
  pushMatrix();
  translate(470, -229, 0);
  renderPyramideLisseExterieure(220, 18, 17);
  popMatrix();
}

void configLights() {
  // Configuration de l'éclairage selon la position du joueur
  if (estExterieur) {
    // Éclairage extérieur (clair mais légèrement réduit)
    directionalLight(180, 180, 180, 0.5, 0.5, -1);
    
    // Ajout d'une lumière ambiante faible pour éviter le noir complet dans les zones d'ombre
    ambientLight(40, 40, 50);
  } else {
    // Éclairage intérieur (très sombre avec effet de lampe torche)
    
    // Paramètres ajustables pour la lampe torche
    float spotMainIntensity = 170;          // Intensité de la lampe torche principale (0-255)
    float spotSecondaryIntensity = 110;      // Intensité de la lampe torche secondaire (0-255)
    float spotMainAngle = PI/2;             // Angle du cône principal (en radians, PI/4 = 45°)
    float spotSecondaryAngle = PI/2.5;      // Angle du cône secondaire (en radians)
    float spotMainConcentration = 8;        // Concentration du faisceau principal (1-128)
    float spotSecondaryConcentration = 2;   // Concentration du faisceau secondaire (1-128)
    float falloffConstant = 0.0;            // Atténuation constante (0-1)
    float falloffLinear = 0.048;             // Atténuation linéaire (0-1)
    float falloffQuadratic = 0.0001;         // Atténuation quadratique (0-1)
    
    // Paramètres de falloff pour une atténuation réaliste de la lumière avec la distance
    lightFalloff(falloffConstant, falloffLinear, falloffQuadratic);
    
    // Effet de lampe torche principale - spotlight dans la direction du regard
    spotLight(
      spotMainIntensity, spotMainIntensity, spotMainIntensity * 1.13,  // couleur
      posX*20, posY*20, posZ + hauteur - 2,                           // position légèrement devant la caméra
      dirX, dirY, -0.2,                                               // direction (légèrement vers le bas)
      spotMainAngle,                                                  // angle du cône
      spotMainConcentration                                           // concentration
    );
    
    // Lumière secondaire plus large et plus faible pour éclairer légèrement les environs
    spotLight(
      spotSecondaryIntensity, spotSecondaryIntensity, spotSecondaryIntensity * 1.2,  // couleur
      posX*20, posY*20, posZ + hauteur,                                             // position à la caméra
      dirX, dirY, -0.2,                                                             // direction (ici légèrement inclinée vers le bas)
      spotSecondaryAngle,                                                           // angle plus large
      spotSecondaryConcentration                                                    // concentration faible
    );
  }
}

// PAS UTILISÉE ENCORE : J'ai fait ça, je me suis dit que ça pouvait être utile pour vérifier si c'était proche de l'extérieur.
// Fonction pour déterminer si le joueur est proche d'une entrée/sortie
// pour préserver les couleurs de l'extérieur visibles depuis l'intérieur
boolean estProcheEntreeSortie() {
  // Vérifier si le joueur est proche d'une entrée/sortie
  int cellX = int(posX - DECALAGES[niveauActuel]);
  int cellY = int(posY - DECALAGES[niveauActuel]);
  
  // Distance maximale à laquelle la lumière extérieure est visible
  float distanceMax = 3.0;
  
  // Vérifier les cellules voisines pour trouver une sortie vers l'extérieur
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      int checkX = cellX + i;
      int checkY = cellY + j;
      
      // Vérifier si la cellule est en dehors des limites du labyrinthe (donc extérieur)
      if (checkX < 0 || checkX >= LAB_SIZES[niveauActuel] || 
          checkY < 0 || checkY >= LAB_SIZES[niveauActuel]) {
        
        // Calculer la distance entre le joueur et cette cellule
        float distance = sqrt(i*i + j*j);
        
        // Si la distance est inférieure à la distance maximale, le joueur est proche d'une sortie
        if (distance < distanceMax) {
          return true;
        }
      }
    }
  }
  
  return false;
}

// Petite fonction d'accélération pour des animations moins saccadées.
float easeInOutQuad(float t) {
  return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;
}
