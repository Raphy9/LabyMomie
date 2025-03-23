//==============REGLAGES MOMIE======================
PShape mummyGroup;  // Le groupe global de la momie

// Paramètres généraux (corps, tête, etc.)
int numBands   = 5;       // Nombre de bandes spirales
float angleStep = 0.8;    // Incrément d'angle par anneau
float bandOffset = 5.0;   // Décalage en angle pour l'épaisseur des bandes
float stepHeight = 3.0;   // Écart vertical entre les anneaux (hauteur)
float rGlobal = 30.0;     // Rayon de base

// Système de particules
ArrayList<Particle> particles = new ArrayList<Particle>();

// Animation Momie
float armAnim = 0;

// Variables pour la position et le déplacement de la momie
float mummyPosX = 3.0;  // Position X initiale de la momie dans le labyrinthe (en réalité cette valeur n'est jamais utilisée mais permet de la placer à l'entrée du labyrinthe)
float mummyPosY = 3.0;  // Position Y initiale de la momie dans le labyrinthe (même remarque qu'en haut)
float mummyPosZ = 0.0;   // Position Z initiale de la momie (niveau 0 de la pyramide)
float mummyDirX = 1.0;   // Direction X initiale de la momie
float mummyDirY = 0.0;   // Direction Y initiale de la momie
int mummyNiveau = 0;     // Niveau actuel de la momie dans la pyramide
float mummySpeed = 0.08; // Vitesse de déplacement de la momie
int mummyMoveTimer = 0;  // Compteur pour changer de direction
int mummyMoveInterval = 40; // Intervalle pour changer de direction
//=====================================================

// Quelques constantes de réglages pour les étages de la pyramide
final int NIVEAUX = 10;
final int[] LAB_SIZES = {21, 19, 17, 15, 13, 11, 9, 7, 5, 3};
// Attention, un mur fait 20 unités de hauteur !
final float[] HAUTEURS_NIVEAUX = {0, 20, 40, 60, 80, 100, 120, 140, 160, 180};
final float HAUTEUR_SOMMET = 200;
final int[] DECALAGES = {0,1,2,3,4,5,6,7,8,9};


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

// Le terrain  l'extérieur
int TAILLE_DESERT = 100;
float[][] hauteursSol;

// Textures
PImage textureStone;
PImage textureSable;
PImage textureStoneJaune;
PImage textureCiel;

// Shaders
PShader shaderInterieur;
PShader shaderExterieur;
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
  textureCiel = createTextureCiel();
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

// Pour générer un labyrinthe pour un niveau spécifique (un mix du TP et quelques updates en plus mais je n'ai pas trop testé comme ça marchait pour les étages)
void genererLabyrinthe(int niveau) {
  int labSize = LAB_SIZES[niveau];
  
  int todig = 0;
  for (int j=0; j<labSize; j++) {
    for (int i=0; i<labSize; i++) {
      sides[niveau][j][i][0] = 0;
      sides[niveau][j][i][1] = 0;
      sides[niveau][j][i][2] = 0;
      sides[niveau][j][i][3] = 0;
      if (j%2==1 && i%2==1) {
        labyrinthes[niveau][j][i] = '.';
        todig++;
      } else
        labyrinthes[niveau][j][i] = '#';
    }
  }
  
  int gx = 1;
  int gy = 1;
  while (todig > 0) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4));
    if      (alea==0 && gx>1)          gx -= 2;
    else if (alea==1 && gy>1)          gy -= 2;
    else if (alea==2 && gx<labSize-2)  gx += 2;
    else if (alea==3 && gy<labSize-2)  gy += 2;

    if (labyrinthes[niveau][gy][gx] == '.') {
      todig--;
      labyrinthes[niveau][gy][gx] = ' ';
      labyrinthes[niveau][(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }

  // Entrée et sortie du labyrinthe
  // Entrée et sortie du labyrinthe (uniquement pour le niveau 0)
  if (niveau == 0) {
    // On ouvre l'entrée sur la face extérieure
    labyrinthes[niveau][0][1] = ' '; 
    // On ouvre aussi la « sortie » 
    labyrinthes[niveau][labSize - 2][labSize - 1] = ' ';
  } else {
    // Pour les niveaux supérieurs, on bouche l'emplacement qui servait d'entrée
    labyrinthes[niveau][0][1] = '#'; 
    // éventuellement on laisse la « sortie » du côté que tu veux
    // labyrinthes[niveau][labSize - 2][labSize - 1] = ' ';
  }

  // On positionne des escaliers (à côté de la sortie)
  if (niveau < NIVEAUX - 1) {
    labyrinthes[niveau][labSize-2][labSize-2] = 'E'; // Escalier montant
  }
  if (niveau > 0) {
    labyrinthes[niveau][1][1] = 'D'; // Escalier descendant
  }

  // Calcul des côtés des couloirs
  for (int j=1; j<labSize-1; j++) {
    for (int i=1; i<labSize-1; i++) {
      if (labyrinthes[niveau][j][i]==' ' || labyrinthes[niveau][j][i]=='E' || labyrinthes[niveau][j][i]=='D') {
        if (labyrinthes[niveau][j-1][i]=='#' && 
            (labyrinthes[niveau][j+1][i]==' ' || labyrinthes[niveau][j+1][i]=='E' || labyrinthes[niveau][j+1][i]=='D') &&
            labyrinthes[niveau][j][i-1]=='#' && labyrinthes[niveau][j][i+1]=='#')
          sides[niveau][j-1][i][0] = 1;// c'est un bout de couloir vers le haut 
        if ((labyrinthes[niveau][j-1][i]==' ' || labyrinthes[niveau][j-1][i]=='E' || labyrinthes[niveau][j-1][i]=='D') && 
            labyrinthes[niveau][j+1][i]=='#' &&
            labyrinthes[niveau][j][i-1]=='#' && labyrinthes[niveau][j][i+1]=='#')
          sides[niveau][j+1][i][3] = 1;// c'est un bout de couloir vers le bas 
        if (labyrinthes[niveau][j-1][i]=='#' && labyrinthes[niveau][j+1][i]=='#' &&
            (labyrinthes[niveau][j][i-1]==' ' || labyrinthes[niveau][j][i-1]=='E' || labyrinthes[niveau][j][i-1]=='D') && 
            labyrinthes[niveau][j][i+1]=='#')
          sides[niveau][j][i+1][1] = 1;// c'est un bout de couloir vers la droite
        if (labyrinthes[niveau][j-1][i]=='#' && labyrinthes[niveau][j+1][i]=='#' &&
            labyrinthes[niveau][j][i-1]=='#' && 
            (labyrinthes[niveau][j][i+1]==' ' || labyrinthes[niveau][j][i+1]=='E' || labyrinthes[niveau][j][i+1]=='D'))
          sides[niveau][j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
      }
    }
  }
}

// Fonction pour générer le sol désertique
void genererSolDesertique() {
  hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];
  
  for (int i = 0; i < TAILLE_DESERT; i++) {
    for (int j = 0; j < TAILLE_DESERT; j++) {
      // On utilise ici du 'bruit' pour moduler la hauteur
      hauteursSol[i][j] = map(noise(i/10.0, j/10.0), 0, 1, -2, 2);
    }
  }
}

// Fonction qui crée une texture jaunie sur la texture pierre de base.
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

// Fonction pour créer une texture de sable... je ne sais pas pourquoi ça apparaît en vert...
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

void draw() {
  background(100, 150, 255); // Fond bleu ciel
  
  // Mise à jour du temps pour les shaders
  time += 0.05;
  
  if (anim > 0) {
    anim--;
  }
  
  updateMummy();
  
  perspective(PI/3.0, float(width)/float(height), 1, 1000);
  
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
  
  camera(
    camX, camY, camZ,
    camX + dirX*20, camY + dirY*20, camZ, // On règle l'axe pour pouvoir conserver regarder perpendiculairement au corps de la momie (et pour les tests c'est mieux...)
    0, 0, -1
  );
  
  estExterieur = checkSiExterieur();
  
  resetShader();
  noTint();
  
  // Dessiner le ciel uniquement si on est à l'extérieur
  if (estExterieur) {
    renderCiel();
  }
  
  // Configuration de l'éclairage selon la position du joueur
  if (estExterieur) {
    // Éclairage extérieur (clair)
    directionalLight(200, 200, 200, 0.5, 0.5, -1);
  } else {
    // Éclairage intérieur (sombre mais suffisant pour voir les murs)
    ambientLight(50, 50, 60);
    pointLight(200, 200, 250, posX*20, posY*20, posZ + hauteur + 5);
    lightFalloff(1.0, 0.1, 0.01);
  }
  
  // Rendu du sol désertique uniquement si on est à l'extérieur
  if (estExterieur) {
    renderSolDesertique(true);
 } else {renderSolDesertique(false);}
  renderPyramide();
  
  // Rendu des escaliers entre les niveaux
  for (int niveau = 0; niveau < NIVEAUX - 1; niveau++) {
    renderEscalier(niveau);
  }

  renderMummy();
  
  // On réinitialise la teinte pour les éléments suivants
  noTint();
  
  // Afficher les indications pour les escaliers
  gererEscaliers();
  
  drawMiniMap();
 
  
}

// Fonction pour mettre à jour la position de la momie de manière autonome
void updateMummy() {
  // Mise à jour du timer pour changer de direction
  mummyMoveTimer++;
  if (mummyMoveTimer >= mummyMoveInterval) {
    // Changer de direction aléatoirement
    float angle = random(TWO_PI);
    mummyDirX = cos(angle);
    mummyDirY = sin(angle);
    mummyMoveTimer = 0;
  }
  
  // On calcule la nouvelle position potentielle
  float newMummyPosX = mummyPosX + mummyDirX * mummySpeed;
  float newMummyPosY = mummyPosY + mummyDirY * mummySpeed;
  
  // Vérification des collisions avec les murs
  int cellX = int(newMummyPosX - DECALAGES[mummyNiveau]);
  int cellY = int(newMummyPosY - DECALAGES[mummyNiveau]);
  
  // Variable permettant de connaître si la nouvelle position est valide (dans les limites et pas un mur)
  boolean canMove = true;
  
  // Vérifier si la position est dans les limites du labyrinthe
  if (cellX < 0 || cellX >= LAB_SIZES[mummyNiveau] || 
      cellY < 0 || cellY >= LAB_SIZES[mummyNiveau]) {
    canMove = false;
  } 
  // On vérifie si la position est un mur
  else if (labyrinthes[mummyNiveau][cellY][cellX] == '#') {
    canMove = false;
  } 
  // On vérifie si la position mènerait à l'extérieur (entrée/sortie du labyrinthe)
  else if (cellX == 0 || cellX == LAB_SIZES[mummyNiveau]-1 || 
           cellY == 0 || cellY == LAB_SIZES[mummyNiveau]-1) {
    // Si c'est une entrée ou sortie,on ne permet à la momie de s'y déplacer
    if (labyrinthes[mummyNiveau][cellY][cellX] == ' ' && 
        ((cellX == 0) || (cellX == LAB_SIZES[mummyNiveau]-1) || 
         (cellY == 0) || (cellY == LAB_SIZES[mummyNiveau]-1))) {
      canMove = false;
    }
  }
  else {
    // Vérification plus précise pour éviter de traverser les murs
    float margin = 0.3; // Marge pour éviter de traverser les murs
    
    // Vérifier les cellules adjacentes
    if (newMummyPosX - (cellX + DECALAGES[mummyNiveau]) < margin && 
        cellX > 0 && labyrinthes[mummyNiveau][cellY][cellX-1] == '#') 
      canMove = false;
    
    if ((cellX + 1 + DECALAGES[mummyNiveau]) - newMummyPosX < margin && 
        cellX < LAB_SIZES[mummyNiveau]-1 && labyrinthes[mummyNiveau][cellY][cellX+1] == '#') 
      canMove = false;
    
    if (newMummyPosY - (cellY + DECALAGES[mummyNiveau]) < margin && 
        cellY > 0 && labyrinthes[mummyNiveau][cellY-1][cellX] == '#') 
      canMove = false;
    
    if ((cellY + 1 + DECALAGES[mummyNiveau]) - newMummyPosY < margin && 
        cellY < LAB_SIZES[mummyNiveau]-1 && labyrinthes[mummyNiveau][cellY+1][cellX] == '#') 
      canMove = false;
  }
  
  // Mettre à jour la position si possible
  if (canMove) {
    mummyPosX = newMummyPosX;
    mummyPosY = newMummyPosY;
  } else {
    // Si collision, on change de direction immédiatement
    float angle = random(TWO_PI);
    mummyDirX = cos(angle);
    mummyDirY = sin(angle);
    mummyMoveTimer = 0;
  }
  
  // Si la momie est à l'extérieur alors on la replace à l'intérieur.
  if (checkIfMummyOutside()) {
    initMummyPosition();
  }
}

void initMummyPosition() {
  // On essaie plusieurs positions jusqu'à en trouver une valide.
  for (int i = 6; i < LAB_SIZES[0] - 1; i++) {
    for (int j = 6; j < LAB_SIZES[0] - 1; j++) {
      float testX = i + DECALAGES[0] + 0.5;
      float testY = j + DECALAGES[0] + 0.5;
      
      if (isValidMummyPosition(testX, testY, 0)) {
        mummyPosX = testX;
        mummyPosY = testY;
        mummyNiveau = 0;
        return;
      }
    }
  }
  
  /*
  // Si aucune position valide n'est trouvée, on pourrait utiliser une position par défaut. Bon si on fait ça, ça va mettre la momie au début du labyrinthe...
  mummyPosX = 3.0;
  mummyPosY = 3.0;
  mummyNiveau = 0;
  */
}

boolean isValidMummyPosition(float x, float y, int niveau) {
  int cellX = int(x - DECALAGES[niveau]);
  int cellY = int(y - DECALAGES[niveau]);
  
  // On commence par vérifier si la position est dans les limites du labyrinthe
  if (cellX < 0 || cellX >= LAB_SIZES[niveau] || 
      cellY < 0 || cellY >= LAB_SIZES[niveau]) {
    return false;
  } 
  
  // On vérifie si la position est un mur
  if (labyrinthes[niveau][cellY][cellX] == '#') {
    return false;
  }
  
  // On vérifie si la position est sur une entrée/sortie du labyrinthe
  if ((cellX == 0 || cellX == LAB_SIZES[niveau]-1 || 
       cellY == 0 || cellY == LAB_SIZES[niveau]-1) && 
      labyrinthes[niveau][cellY][cellX] == ' ') {
    return false;
  }
  
  // On vérifie pour finir les cellules adjacentes pour s'assurer qu'il y a de l'espace pour se déplacer
  int spaceCount = 0;
  if (cellX > 0 && labyrinthes[niveau][cellY][cellX-1] != '#') spaceCount++;
  if (cellX < LAB_SIZES[niveau]-1 && labyrinthes[niveau][cellY][cellX+1] != '#') spaceCount++;
  if (cellY > 0 && labyrinthes[niveau][cellY-1][cellX] != '#') spaceCount++;
  if (cellY < LAB_SIZES[niveau]-1 && labyrinthes[niveau][cellY+1][cellX] != '#') spaceCount++;
  
  // La position est valide si elle a au moins 2 espaces adjacents pour se déplacer
  return spaceCount >= 2;
}

boolean checkIfMummyOutside() {
  int cellX = int(mummyPosX - DECALAGES[mummyNiveau]);
  int cellY = int(mummyPosY - DECALAGES[mummyNiveau]);
  
  // On vérifie si la position est en dehors des limites du labyrinthe
  if (cellX < 0 || cellX >= LAB_SIZES[mummyNiveau] || 
      cellY < 0 || cellY >= LAB_SIZES[mummyNiveau]) {
    return true;
  }
  
  // On vérifie si la momie est sur une entrée/sortie du labyrinthe
  if ((cellX == 0 || cellX == LAB_SIZES[mummyNiveau]-1 || 
       cellY == 0 || cellY == LAB_SIZES[mummyNiveau]-1) && 
      labyrinthes[mummyNiveau][cellY][cellX] == ' ') {
    return true;
  }
  
  return false;
}

void renderMummy() {
  rotateX(-PI/2);
  // Ne générer la momie que si elle est à l'intérieur du labyrinthe !
  if (checkIfMummyOutside()) {
    return;
  }
  
  pushMatrix();
  
  // Utiliser la position de la momie dans le labyrinthe
  // On convertit les coordonnées du labyrinthe en coordonnées 3D
  float mummyWorldX = (mummyPosX) * 20; // 20 unités par cellule
  float mummyWorldY = (mummyPosY) * 20;
  float mummyWorldZ = HAUTEURS_NIVEAUX[mummyNiveau] + 0; // Hauteur du niveau + décalage
  
  translate(mummyWorldX, mummyWorldZ, mummyWorldY);
  
  // Permet d'orienter la momie dans la direction de son déplacement
  float angle = atan2(mummyDirY, mummyDirX);
  rotateY(PI/2 - angle);
  
  // Ajuster l'échelle pour réduire la taille de la momie
  scale(0.065);

  
  // Animation des bras
  armAnim = (sin(frameCount * 0.05) + 1) / 2;
  
  // Dessin du corps
  shape(mummyGroup.getChild("bodyGroup"));
  shape(mummyGroup.getChild("headGroup"));
  shape(mummyGroup.getChild("eyesGroup"));
  
  // Bras animés
  pushMatrix();
  rotateY(radians(armAnim * 70));
  shape(mummyGroup.getChild("armsGroup").getChild("leftArm"));
  popMatrix();
  
  pushMatrix();
  rotateY(radians(-armAnim * 70));
  shape(mummyGroup.getChild("armsGroup").getChild("rightArm"));
  popMatrix();
  
  popMatrix();
  
  // Particules autour de la momie
  pushMatrix();
  translate(mummyWorldX, mummyWorldZ, mummyWorldY);
  //updateParticles();
  //displayParticles();
  popMatrix();
}


// Fonction pour dessiner le ciel (skybox)
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

// Fonction pour rendre le sol désertique
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

// Pour la pyramide complète
void renderPyramide() {
  // Rendu des niveaux de la pyramide
  for (int niveau = 0; niveau < NIVEAUX; niveau++) {
    renderNiveauPyramide(niveau);
  }
  
  // Rendu du sommet lisse de la pyramide
  renderPyramideLisseExterieure();
}

// Fonction pour rendre un niveau de la pyramide
void renderNiveauPyramide(int niveau) {
  int labSize = LAB_SIZES[niveau];
  float hauteurNiveau = HAUTEURS_NIVEAUX[niveau];
  int decalage = DECALAGES[niveau];
  
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      pushMatrix();
      
      // Pour l'effet pyramidal
      translate((i+decalage)*20, (j+decalage)*20, hauteurNiveau);
      
      if (labyrinthes[niveau][j][i] == '#') {
        // On utilise la texture jaune pour l'extérieur de la pyramide et l'entrée... mais je ne comprends pas pourquoi un bloc de mur à l'entrée est vert... haha il est jaune mainteannt mdr
        boolean estExterieur = (i == 0 || i == labSize-1 || j == 0 || j == labSize-1);
        
        
        // On dessine les murs
        // Mur Nord (face avant)
        if (j == 0 || labyrinthes[niveau][j-1][i] != '#') {
          beginShape(QUADS);
          if (estExterieur || (j == 0 && i == 1)) {
            texture(textureStoneJaune);
          } else {
            texture(textureStone);
          }
          vertex(0, 0, 0, 0, 0);
          vertex(20, 0, 0, 1, 0);
          vertex(20, 0, 20, 1, 1);
          vertex(0, 0, 20, 0, 1);
          endShape();
        }
        
        // Mur Sud (face arrière)
        if (j == labSize-1 || labyrinthes[niveau][j+1][i] != '#') {
          beginShape(QUADS);
          // Pour gérer les couleurs de la texture en fonction de la position (sauf si tu veux mettre tout en jaune à l'intérieur...)
          if (estExterieur) {
            texture(textureStoneJaune);
          } else {
            texture(textureStone);
          }
          vertex(0, 20, 0, 0, 0);
          vertex(20, 20, 0, 1, 0);
          vertex(20, 20, 20, 1, 1);
          vertex(0, 20, 20, 0, 1);
          endShape();
        }
        
        // Mur Est (face droite)
        if (i == labSize-1 || labyrinthes[niveau][j][i+1] != '#') {
          beginShape(QUADS);
          if (estExterieur) {
            texture(textureStoneJaune);
          } else {
            texture(textureStone);
          }
          vertex(20, 0, 0, 0, 0);
          vertex(20, 20, 0, 1, 0);
          vertex(20, 20, 20, 1, 1);
          vertex(20, 0, 20, 0, 1);
          endShape();
        }
        
        // Mur Ouest (face gauche)
        if (i == 0 || labyrinthes[niveau][j][i-1] != '#') {
          beginShape(QUADS);
          if (estExterieur) {
            texture(textureStoneJaune);
          } else {
            texture(textureStone);
          }
          vertex(0, 0, 0, 0, 0);
          vertex(0, 20, 0, 1, 0);
          vertex(0, 20, 20, 1, 1);
          vertex(0, 0, 20, 0, 1);
          endShape();
        }
        
        // Plafond (face supérieure)
        beginShape(QUADS);
        texture(textureStone);
        vertex(0, 0, 20, 0, 0);
        vertex(20, 0, 20, 1, 0);
        vertex(20, 20, 20, 1, 1);
        vertex(0, 20, 20, 0, 1);
        endShape();
        
        // Sol (face inférieure)
        beginShape(QUADS);
        texture(textureStone);
        vertex(0, 0, 0, 0, 0);
        vertex(20, 0, 0, 1, 0);
        vertex(20, 20, 0, 1, 1);
        vertex(0, 20, 0, 0, 1);
        endShape();
      } 
      else if (labyrinthes[niveau][j][i] == ' ') {
        // Sol pour les cases vides - GRIS
        fill(50, 50, 50);
        noStroke();
        beginShape(QUADS);
        vertex(0, 0, 0, 0, 0);
        vertex(20, 0, 0, 1, 0);
        vertex(20, 20, 0, 1, 1);
        vertex(0, 20, 0, 0, 1);
        endShape();
        
        // Plafond pour les cases vides - GRIS
        fill(50, 50, 50);
        beginShape(QUADS);
        vertex(0, 0, 20, 0, 0);
        vertex(20, 0, 20, 1, 0);
        vertex(20, 20, 20, 1, 1);
        vertex(0, 20, 20, 0, 1);
        endShape();
      }
      else if (labyrinthes[niveau][j][i] == 'E' || labyrinthes[niveau][j][i] == 'D') {
        // Marqueur pour l'emplacement des escaliers
        if (labyrinthes[niveau][j][i] == 'E') {
          fill(0, 0, 255); // Bleu pour monter
        } else {
          fill(255, 0, 0); // Rouge pour descendre
        }
        noStroke();
        beginShape(QUADS);
        vertex(0, 0, 0, 0, 0);
        vertex(20, 0, 0, 1, 0);
        vertex(20, 20, 0, 1, 1);
        vertex(0, 20, 0, 0, 1);
        endShape();
      }
      
      popMatrix();
    }
  }
  /*
  // On dessine les bords en escalier pour l'extérieur de la pyramide
  if (niveau > 0) {
    int niveauPrecedent = niveau - 1;
    int labSizePrecedent = LAB_SIZES[niveauPrecedent];
    int decalagePrecedent = DECALAGES[niveauPrecedent];
    float hauteurPrecedente = HAUTEURS_NIVEAUX[niveauPrecedent];
    // Dessin des bords en escalier
    for (int j = 0; j < labSizePrecedent; j++) {
      for (int i = 0; i < labSizePrecedent; i++) {
        // Ne dessiner que les bords (cellules qui sont à l'extérieur du niveau actuel)
        if (i < decalage - decalagePrecedent || 
            i >= labSize + decalage - decalagePrecedent ||
            j < decalage - decalagePrecedent || 
            j >= labSize + decalage - decalagePrecedent) {
          
          if (labyrinthes[niveauPrecedent][j][i] == '#') {
            pushMatrix();
            translate((i+decalagePrecedent)*20, (j+decalagePrecedent)*20, hauteurPrecedente);
            
            // On utilise la texture jaune pour les bords
            texture(textureStoneJaune);
            
            // Dessiner le dessus du bloc (visible depuis l'extérieur)
            beginShape(QUADS);
            fill(224, 205, 169); // Permet d'éviter d'avoir un ton bleuâtre sur la moitié de la pyramide (lié au sol peut être)
            texture(textureStoneJaune);
            vertex(0, 0, 20, 0, 0);
            vertex(20, 0, 20, 1, 0);
            vertex(20, 20, 20, 1, 1);
            vertex(0, 20, 20, 0, 1);
            endShape();
            
            popMatrix();
          }
        }
      }
    }
  }
  */
}

void renderPyramideLisseExterieure() {
  // Taille de base : la pyramide la plus large fait 21 cases × 20 unités = 420
  float baseSize = 21 * 20;
  // On place le sommet à 200 en Z (comme HAUTEUR_SOMMET)
  float apexZ = 300;

  pushMatrix();
  noStroke();

textureWrap(REPEAT);
  // Face 1 (devant)
  beginShape(TRIANGLES);
    texture(textureStoneJaune);
    // On mappe la texture comme on veut (u,v). Ici, simple.
    vertex(0,        0,        20, 0,  0);
    vertex(baseSize, 0,        20, 20,  0);
    vertex(baseSize/2, baseSize/2, apexZ,10,  20);
  endShape();
  
  // Face 1 (devant)
  beginShape(TRIANGLES);
    fill(255);
    // On mappe la texture comme on veut (u,v). Ici, simple.
    vertex((baseSize/2) * ((apexZ - 60) / (apexZ - 20)),         (baseSize/2) * ((apexZ - 60) / (apexZ - 20)),        apexZ-40, 0,  0);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60) / (apexZ - 20)),  (baseSize/2) * ((apexZ - 60) / (apexZ - 20)),        apexZ-40, 20,  0);
    vertex(baseSize/2, baseSize/2, apexZ+1,10,  20);
  endShape();

  // Face 2 (droite)
  beginShape(TRIANGLES);
    texture(textureStoneJaune);
    vertex(baseSize, 0,     20,     0,   0);
    vertex(baseSize, baseSize, 20, 20,   0);
    vertex(baseSize/2, baseSize/2, apexZ, 10, 20);
  endShape();
  
  // Face 2 (droite)
  beginShape(TRIANGLES);
    fill(255);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),  (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),        apexZ-40, 0, 0);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),  baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ+1, 10, 20);
  endShape();

  // Face 3 (arrière)
  beginShape(TRIANGLES);
    texture(textureStoneJaune);
    vertex(baseSize, baseSize, 20, 0,   0);
    vertex(0,        baseSize, 20, 20,   0);
    vertex(baseSize/2, baseSize/2, apexZ, 10, 20);
  endShape();
  
  // Face 3 (arrière)
  beginShape(TRIANGLES);
    fill(255);
    vertex(baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),  baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 0, 0);
    vertex((baseSize/2) * ((apexZ - 60)/(apexZ - 20)),         baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ+1, 10, 20);
  endShape();

   // Face 4 (gauche)
  beginShape(TRIANGLES);
    texture(textureStoneJaune);
    vertex(0, baseSize, 20,     0,   0);
    vertex(0, 0,        20,     20,   0);
    vertex(baseSize/2, baseSize/2, apexZ, 10, 20);
  endShape();
  
  // Face 4 (gauche)
  beginShape(TRIANGLES);
    fill(255);
    vertex((baseSize/2) * ((apexZ - 60)/(apexZ - 20)),         baseSize - (baseSize/2) * ((apexZ - 60)/(apexZ - 20)), apexZ-40, 0, 0);
    vertex((baseSize/2) * ((apexZ - 60)/(apexZ - 20)),         (baseSize/2) * ((apexZ - 60)/(apexZ - 20)),        apexZ-40, 20, 0);
    vertex(baseSize/2, baseSize/2, apexZ+1, 10, 20);
  endShape();

  popMatrix();
}


// Fonction pour rendre le sommet lisse de la pyramide
void renderSommetPyramide() {
  pushMatrix();
  
  // Position du sommet
  int decalage = DECALAGES[NIVEAUX-1] + (LAB_SIZES[NIVEAUX-1] - 3) / 2;
  translate(decalage*20, decalage*20, HAUTEUR_SOMMET);
  
  // Utiliser la texture jaune pour le sommet
  texture(textureStoneJaune);
  
  // Dessiner le sommet lisse (pyramide)
  beginShape(TRIANGLES);
  texture(textureStoneJaune);
  
  // Base carrée
  vertex(0, 0, 0, 0, 0);
  vertex(60, 0, 0, 1, 0);
  vertex(60, 60, 0, 1, 1);
  
  vertex(0, 0, 0, 0, 0);
  vertex(60, 60, 0, 1, 1);
  vertex(0, 60, 0, 0, 1);
  
  // Faces triangulaires
  // Face avant
  vertex(0, 0, 0, 0, 0);
  vertex(60, 0, 0, 1, 0);
  vertex(30, 30, 20, 0.5, 0.5);
  
  // Face droite
  vertex(60, 0, 0, 0, 0);
  vertex(60, 60, 0, 1, 0);
  vertex(30, 30, 20, 0.5, 0.5);
  
  // Face arrière
  vertex(60, 60, 0, 0, 0);
  vertex(0, 60, 0, 1, 0);
  vertex(30, 30, 20, 0.5, 0.5);
  
  // Face gauche
  vertex(0, 60, 0, 0, 0);
  vertex(0, 0, 0, 1, 0);
  vertex(30, 30, 20, 0.5, 0.5);
  
  endShape();
  
  popMatrix();
}

void drawMiniMap() {
  // On réinitialise la caméra et la perspective pour l'affichage 2D
  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  
  // Propriétés de la minimap.
  int mapSize = 200;
  int mapX = 20;
  int mapY = 20;
  int cellSize = mapSize / LAB_SIZES[niveauActuel];
  
  // Background de la mini-carte
  fill(0, 0, 0, 150);
  rect(mapX-5, mapY-5, mapSize+10, mapSize+10);
  
  // Afficher le niveau actuel
  fill(255);
  text("Niveau: " + niveauActuel, mapX, mapY-10);
  
  // Dessiner le labyrinthe du niveau actuel
  for (int j=0; j<LAB_SIZES[niveauActuel]; j++) {
    for (int i=0; i<LAB_SIZES[niveauActuel]; i++) {
      if (labyrinthes[niveauActuel][j][i] == '#') {
        fill(100, 100, 100);
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
      }
      else if (labyrinthes[niveauActuel][j][i] == 'E') {
        fill(0, 0, 255);
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
      }
      else if (labyrinthes[niveauActuel][j][i] == 'D') {
        fill(255, 0, 0);
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
      }
    }
  }
  
  // On dessine ici la position du joueur
  fill(0, 255, 0);
  ellipse(mapX + (posX-DECALAGES[niveauActuel])*cellSize, mapY + (posY-DECALAGES[niveauActuel])*cellSize, cellSize, cellSize);
  
  // On dessine la direction du joueur
  stroke(255, 0, 0);
  line(mapX + (posX-DECALAGES[niveauActuel])*cellSize, mapY + (posY-DECALAGES[niveauActuel])*cellSize, 
       mapX + (posX-DECALAGES[niveauActuel] + dirX)*cellSize, mapY + (posY-DECALAGES[niveauActuel] + dirY)*cellSize);
  noStroke();
  
 // On dessine ici la position de la momie (en violet)
  if (mummyNiveau == niveauActuel) {
    fill(255, 0, 255); // Couleur violette pour la momie
    ellipse(mapX + (mummyPosX-DECALAGES[mummyNiveau])*cellSize, mapY + (mummyPosY-DECALAGES[mummyNiveau])*cellSize, cellSize*1.2, cellSize*1.2);
    
    // On dessine la direction de la momie
    stroke(255, 165, 0); // Orange pour la direction de la momie
    line(mapX + (mummyPosX-DECALAGES[mummyNiveau])*cellSize, mapY + (mummyPosY-DECALAGES[mummyNiveau])*cellSize, 
         mapX + (mummyPosX-DECALAGES[mummyNiveau] + mummyDirX)*cellSize, mapY + (mummyPosY-DECALAGES[mummyNiveau] + mummyDirY)*cellSize);
    noStroke();
  }
  
  hint(ENABLE_DEPTH_TEST);
}

// Petite fonction d'accélération pour des animations moins saccadées.
float easeInOutQuad(float t) {
  return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;
}

void keyPressed() {
  if (anim > 0) return;
  
  float newPosX = posX;
  float newPosY = posY;
  float newPosZ = posZ;
  
  // Déplacement vers l'avant (flèche haut)
  if (keyCode == 38) {
    oldPosX = posX;
    oldPosY = posY;
    oldPosZ = posZ;
    newPosX += dirX * 1;
    newPosY += dirY * 1;
    animMode = 1;
    anim = 20;
  }
  // Déplacement vers l'arrière (flèche bas)
  else if (keyCode == 40) {
    oldPosX = posX;
    oldPosY = posY;
    oldPosZ = posZ;
    newPosX -= dirX * 1;
    newPosY -= dirY * 1;
    animMode = 1;
    anim = 20;
  }
  // Rotation à gauche (flèche gauche) - keyCode 37
  else if (keyCode == 37) {
    oldDirX = dirX;
    oldDirY = dirY;
    
    float angle = -PI/8;
    float tempDirX = dirX;
    dirX = dirX * cos(angle) - dirY * sin(angle);
    dirY = tempDirX * sin(angle) + dirY * cos(angle);
    
    // On normalise le vecteur direction pour éviter les dérives potentielles
    float longueur = sqrt(dirX*dirX + dirY*dirY);
    dirX /= longueur;
    dirY /= longueur;
    
    animMode = 2;
    anim = 10;
  }
  // Rotation à droite (flèche droite) - keyCode 39
  else if (keyCode == 39) {
    // Sauvegarder l'ancienne direction
    oldDirX = dirX;
    oldDirY = dirY;
    
    float angle = PI/8;
    float tempDirX = dirX;
    dirX = dirX * cos(angle) - dirY * sin(angle);
    dirY = tempDirX * sin(angle) + dirY * cos(angle);
    
    float longueur = sqrt(dirX*dirX + dirY*dirY);
    dirX /= longueur;
    dirY /= longueur;
    
    animMode = 2;
    anim = 10;
  }
  // Monter (touche 'e')
  else if (key == 'e' || key == 'E') {
    // Vérifier si le joueur est sur un escalier montant
    int cellX = int(posX - DECALAGES[niveauActuel]);
    int cellY = int(posY - DECALAGES[niveauActuel]);
    
    if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] && 
        cellY >= 0 && cellY < LAB_SIZES[niveauActuel] &&
        labyrinthes[niveauActuel][cellY][cellX] == 'E' &&
        niveauActuel < NIVEAUX - 1) {
      
      // Monter d'un niveau avec animation
      animerMonteeDescente(niveauActuel + 1, 1 + DECALAGES[niveauActuel + 1], 1 + DECALAGES[niveauActuel + 1]);
    }
  }
  // Descendre (touche 'd')
  else if (key == 'd' || key == 'D') {
    // Vérifier si le joueur est sur un escalier descendant
    int cellX = int(posX - DECALAGES[niveauActuel]);
    int cellY = int(posY - DECALAGES[niveauActuel]);
    
    if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] && 
        cellY >= 0 && cellY < LAB_SIZES[niveauActuel] &&
        labyrinthes[niveauActuel][cellY][cellX] == 'D' &&
        niveauActuel > 0) {
      
      // Descendre d'un niveau avec animation
      animerMonteeDescente(niveauActuel - 1, (LAB_SIZES[niveauActuel - 1] - 2) + DECALAGES[niveauActuel - 1], 
                          (LAB_SIZES[niveauActuel - 1] - 2) + DECALAGES[niveauActuel - 1]);
    }
  }
  
  // Vérification de collision avec les murs avant de déplacer le joueur
  if (estExterieur) {
    // Si le joueur est à l'extérieur, pas de collision avec les murs
    posX = newPosX;
    posY = newPosY;
    posZ = newPosZ;
  } else {
    // Si le joueur est à l'intérieur, vérifier les collisions
    int cellX = int(newPosX - DECALAGES[niveauActuel]);
    int cellY = int(newPosY - DECALAGES[niveauActuel]);
    
    // Vérifier si la nouvelle position est valide (dans les limites et pas un mur)
    if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] && 
        cellY >= 0 && cellY < LAB_SIZES[niveauActuel]) {
      if (labyrinthes[niveauActuel][cellY][cellX] != '#') {
        boolean canMove = true;
        
        // Vérification plus précise pour éviter de traverser les murs
        float margin = 0.2; // Marge pour éviter de traverser les murs
        
        // Vérifier les cellules adjacentes
        if (newPosX - (cellX + DECALAGES[niveauActuel]) < margin && 
            cellX > 0 && labyrinthes[niveauActuel][cellY][cellX-1] == '#') 
          canMove = false;
        
        if ((cellX + 1 + DECALAGES[niveauActuel]) - newPosX < margin && 
            cellX < LAB_SIZES[niveauActuel]-1 && labyrinthes[niveauActuel][cellY][cellX+1] == '#') 
          canMove = false;
        
        if (newPosY - (cellY + DECALAGES[niveauActuel]) < margin && 
            cellY > 0 && labyrinthes[niveauActuel][cellY-1][cellX] == '#') 
          canMove = false;
        
        if ((cellY + 1 + DECALAGES[niveauActuel]) - newPosY < margin && 
            cellY < LAB_SIZES[niveauActuel]-1 && labyrinthes[niveauActuel][cellY+1][cellX] == '#') 
          canMove = false;
        
        if (canMove) {
          posX = newPosX;
          posY = newPosY;
          posZ = newPosZ;
        } else {
          anim = 0;
        }
      } else {
        anim = 0;
      }
    } else {
      // Le joueur sort du labyrinthe, il est maintenant à l'extérieur
      posX = newPosX;
      posY = newPosY;
      posZ = newPosZ;
    }
  }
}

//=====================FONCTION  MOMIE===================================
// ==========================================================
// Système de particules
// ==========================================================
void updateParticles() {
  // On ajoute quelques particules chaque frame
  for (int i = 0; i < 5; i++) {
    // On génère une position aléatoire sur une sphère autour du centre de la momie
    PVector spawn = PVector.random3D();
    spawn.mult(random(rGlobal * 0.8, rGlobal * 1.5));
    particles.add(new Particle(spawn));
  }
  
  // Mise à jour et suppression des particules trop vieilles
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}

void displayParticles() {
  // On affiche toutes les particules
  for (Particle p : particles) {
    p.display();
  }
}

// ==========================================================
// Classe Particle
// ==========================================================
class Particle {
  PVector pos;
  PVector vel;
  float lifespan;
  
  Particle(PVector pos) {
    this.pos = pos.copy();
    // Vélocité aléatoire pour donner un léger mouvement
    vel = PVector.random3D();
    vel.mult(random(0.5, 2));
    lifespan = 255;
  }
  
  void update() {
    pos.add(vel);
    lifespan -= 2;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    noStroke();
    fill(194, 167, 144, lifespan); // Couleur avec transparence
    sphere(2);
    popMatrix();
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}

PShape buildArm() {
  // Paramètres du bras
  int armSegments = 40;       // Nombre de segments le long du bras
  float armBase = 15;         // Rayon de départ (au niveau de l'épaule)
  float armTip = 10;          // Rayon à l'extrémité du bras
  float stepArm = 2.5;        // Écart entre les segments le long du bras
  
  PShape armGroup = createShape(GROUP);
  
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    PShape armBand = createShape();
    armBand.beginShape(QUAD_STRIP);
    armBand.noStroke();
    for (int i = 0; i <= armSegments; i++) {
      float t = map(i, 0, armSegments, 0, 1);
      float rArm = lerp(armBase, armTip, t);
      float angle = i * angleStep + globalOffset;
      float pos = i * stepArm;  // Position le long du bras
      
      float x1 = pos;
      float y1 = rArm * cos(angle);
      float z1 = rArm * sin(angle);
      
      float x2 = pos;
      float y2 = rArm * cos(angle + bandOffset);
      float z2 = rArm * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 200, 255);
      armBand.fill(c, c * 0.75, c * 0.5);
      
      armBand.vertex(x1, y1, z1);
      armBand.vertex(x2, y2, z2);
    }
    armBand.endShape();
    armGroup.addChild(armBand);
  }
  return armGroup;
}

PShape createMummy() {
  PShape mummyGroup = createShape(GROUP);
  mummyGroup.setName("mummyGroup");

  // Création du groupe global de la momie
  mummyGroup = createShape(GROUP);
  mummyGroup.setName("mummyGroup");
  
  // ==========================================================
  // 1) Construction du Corps (i de 0 à 64)
  // ==========================================================
  PShape bodyGroup = createShape(GROUP);
  bodyGroup.setName("bodyGroup");
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    PShape bandShape = createShape();
    bandShape.beginShape(QUAD_STRIP);
    bandShape.noStroke();
    for (int i = 0; i <= 64; i++) {
      float t = map(i, 0, 64, 0, 1);
      float r = rGlobal + 5 * sin(t * PI);
      float angle = i * angleStep + globalOffset;
      float y = i * stepHeight;
      
      float x1 = r * cos(angle);
      float z1 = r * sin(angle);
      float x2 = r * cos(angle + bandOffset);
      float z2 = r * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 200, 255);
      bandShape.fill(c, c * 0.75, c * 0.5);
      
      bandShape.vertex(x1, -y, z1);
      bandShape.vertex(x2, -y, z2);
    }
    bandShape.endShape();
    bodyGroup.addChild(bandShape);
  }
  mummyGroup.addChild(bodyGroup);
  
  // ==========================================================
  // 2) Construction de la Tête (i de 64 à 84)
  // ==========================================================
  PShape headGroup = createShape(GROUP);
  headGroup.setName("headGroup");
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    PShape bandShape = createShape();
    bandShape.beginShape(QUAD_STRIP);
    bandShape.noStroke();
    for (int i = 64; i <= 84; i++) {
      float tHead = map(i, 64, 84, 0, 1);
      float r = rGlobal + 0.25 * rGlobal - 5 * tHead;
      float angle = i * angleStep + globalOffset;
      float y = i * stepHeight;
      
      float x1 = r * cos(angle);
      float z1 = r * sin(angle);
      float x2 = r * cos(angle + bandOffset);
      float z2 = r * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 200, 255);
      bandShape.fill(c, c * 0.75, c * 0.5);
      
      bandShape.vertex(x1, -y, z1);
      bandShape.vertex(x2, -y, z2);
    }
    bandShape.endShape();
    headGroup.addChild(bandShape);
  }
  mummyGroup.addChild(headGroup);
  
  // ==========================================================
  // 3) Construction des Yeux
  // ==========================================================
  PShape eyesGroup = createShape(GROUP);
  eyesGroup.setName("eyesGroup");
  
  float iEye = 75;
  float tHead = map(iEye, 64, 84, 0, 1);
  float rEye = rGlobal + rGlobal * 0.11 - 5 * tHead;
  float yEye = iEye * stepHeight;
  float zOffset = 8;
    
  PShape leftEye = createShape(SPHERE, 3.5);
  leftEye.setName("leftEye");
  leftEye.setFill(color(0));
  leftEye.translate(rEye, -yEye, zOffset);
  eyesGroup.addChild(leftEye);
  
  PShape wLeftEye = createShape(SPHERE, 6);
  wLeftEye.setName("wLeftEye");
  wLeftEye.setFill(color(255));
  wLeftEye.translate(rEye-3, -yEye, zOffset);
  eyesGroup.addChild(wLeftEye);
  
  PShape rightEye = createShape(SPHERE, 3.5);
  rightEye.setName("rightEye");
  rightEye.setFill(color(0));
  rightEye.translate(rEye, -yEye, -zOffset);
  eyesGroup.addChild(rightEye);
  
  PShape wRightEye = createShape(SPHERE, 6);
  wRightEye.setName("wRightEye");
  wRightEye.setFill(color(255));
  wRightEye.translate(rEye-3, -yEye, -zOffset);
  eyesGroup.addChild(wRightEye);
  
  mummyGroup.addChild(eyesGroup);
  
  // ==========================================================
  // 4) Construction des Bras
  // ==========================================================
  PShape armsGroup = createShape(GROUP);
  armsGroup.setName("armsGroup");
  
  // Bras gauche
  PShape leftArm = buildArm(); 
  leftArm.setName("leftArm");
  leftArm.translate(0, -60 * stepHeight, -rGlobal);  // Positionnement du bras gauche
  armsGroup.addChild(leftArm);
    
  
  // Bras droit
  PShape rightArm = buildArm();
  rightArm.setName("rightArm");
  rightArm.translate(0, -60 * stepHeight, rGlobal);  // Positionnement du bras droit
  armsGroup.addChild(rightArm);
  
  mummyGroup.addChild(armsGroup);
  


  return mummyGroup;
}
