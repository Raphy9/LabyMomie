// === Importation de bibliotheque ====
import processing.sound.*;

// ==== Sons ====
SoundFile ambiantExterieur;
SoundFile ambiantInterieur;
SoundFile reveal;
SoundFile death;
SoundFile warp;
SoundFile button;

// ==== Param ====
int revealDistance = 40;
float time = 0;

// ===== Variables pour le Laby ====
char[][][] labyrinthes;
char[][][][] sides;
boolean[][][] decouvert;
ArrayList<PShape> niveauxShapes = new ArrayList<PShape>();

// ===== Variables du Joueur ====
float posX, posY, posZ, dirX, dirY;
float oldDirX, oldDirY;
float oldPosX, oldPosY, oldPosZ;
float targetPosX, targetPosY, targetPosZ;  // Position cible à atteindre
int niveauActuel = 0; // Niveau actuel du joueur (0 = base, 1 = milieu, 2 = sommet)
boolean estExterieur = false; // Si le joueur est à l'extérieur ou pas.
int NIVEAUACTUEL = 0;

// ===== Variables d'animation ====
float animationTimer = 0;                // Timer qui suit l'avancement de l'animation
boolean isMoving = false;                // True si le joueur est en train de se déplacer
float collisionDistance = 8;             // Seuil de collision avec la momie
float hauteur = 10; // Hauteur caméra
int anim = 0;
int animMode = 0; // 0 = pas d'animation, 1 = animation de translation, 2 = animation de rotation

// ===== Textures et PShape =====
PImage textureStone;
PImage texturePorte;
PImage textureSable;
PImage textureStoneJaune;
PImage textureporteJaune;
PImage textureCiel;
PImage textureSolPlafond;
PImage textureSolPlafondJaune;

PShape lanterneModel;

// ==================== Initialisation ======================

// ==== Initialisation du son ====
void initSound() {
  ambiantExterieur = new SoundFile(this, "ambiant_exterieur.mp3");
  ambiantInterieur = new SoundFile(this, "ambiant_interieur.mp3");
  reveal = new SoundFile(this, "reveal.mp3");
  death = new SoundFile(this, "death.mp3");
  warp = new SoundFile(this, "warp.mp3");
  button = new SoundFile(this, "button.mp3");
  ambiantExterieur.loop();
}

// ==== Initialisation des textures et models ====

void initTexturesModels() {
  // Chargement des models
  lanterneModel = createTorch3D();
  // Chargement des textures
  textureStone = loadImage("stone.jpg");
  if (textureStone == null) {
    System.out.println("La texture n'existe pas");
  }
  texturePorte = loadImage("porte.png");
  if (texturePorte == null) {
    System.out.println("La texture n'existe pas");
  }
  textureSolPlafond = loadImage("textureSolPlafond.png");
  if (textureSolPlafond == null) {
    System.out.println("La texture n'existe pas");
  }
  textureSable = loadImage("desert.png");
  if (textureSable == null) {
    System.out.println("La texture n'existe pas");
  }
  textureCiel = loadImage("ciel.png");
  if (textureCiel == null) {
    System.out.println("La texture n'existe pas");
  }
  textureSolPlafondJaune = createTextureJaune(textureSolPlafond);
  textureStoneJaune = textureStone;
  textureMode(NORMAL);
}

// ======= SETUP =======
void setup() {
  
  surface.setTitle("Des momies et des pyramides !");
  frameRate(20);
  randomSeed(2);
  size(1000, 830, P3D);

  // Initialisation du son
  initSound();

  // Initialisation des Textures et des Models
  initTexturesModels();
  
  // Initialisation des labyrinthes pour chaque niveau
  initLevelLaby();
  
  // Initialise le brouillard de la minimap
  decouvert = new boolean[NIVEAUX][][];
  initBrouillardMiniMap();
  
  // Initialise le shader tempete de sable
  initSandstormShader();
  
  // Initialisation des momies pour chaque niveau
  mummyGroup = createMummy();
  initMomies();

  // Initialisation des variables pour le sol desertique
  hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];
  
  // Initialisation des particules pour la torche
  genererFlammeParticules();  

  // Initialisation des variables de position et direction
  posX = 1.4; posY = 1.0; posZ = HAUTEURS_NIVEAUX[0];
  dirX = 0; dirY = 1;
  oldPosX = posX; oldPosY = posY; oldPosZ = posZ;
  oldDirX = dirX; oldDirY = dirY;
}

// ======= DRAW =======
void draw() {
  background(0);

  // Mise à jour du temps pour les shaders
  time += 0.05;

  // Gestion du menu
  if (currentState == 0) {
    drawMenu();
  } else if (currentState == 1) {
    drawGame();
  }
}

// ======= DRAWGAME=======
void drawGame() {
  background(100, 0, 255);
  
  // Variables
  float camX, camY, camZ, lookX, lookY, lookZ;
  float dt = 1.0 / frameRate;
  
  // Gestionnaire de Momie
  renderMummy();
  updateMummy();
  
  // Gestionnaire de son
  if (!estExterieur) {
    if (ambiantExterieur.isPlaying()) {
      ambiantExterieur.stop();
    }
    if (!ambiantInterieur.isPlaying()) {
      ambiantInterieur.loop();
    }
  } else {
    if (ambiantInterieur.isPlaying()) {
      ambiantInterieur.stop();
    }
    if (!ambiantExterieur.isPlaying()) {
      ambiantExterieur.loop();
    }
  }

  // Gestionnaire d'animation
  if (isMoving && anim <= 0) {
    animationTimer += dt;
    float ratio = constrain(animationTimer / 0.2, 0, 1);

    float t = easeInOutQuad(ratio);
    posX = lerp(oldPosX, targetPosX, t);
    posY = lerp(oldPosY, targetPosY, t);
    posZ = lerp(oldPosZ, targetPosZ, t);

    if (ratio >= 1) {
      isMoving = false;
    }
  }
  
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
    } else if (animMode == 2) {
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
    } else {
      camX = posX*20;
      camY = posY*20;
      camZ = posZ + hauteur;
      lookX = posX*20 + dirX*20;
      lookY = posY*20 + dirY*20;
      lookZ = posZ;
    }
  } else {
    camX = posX*20;
    camY = posY*20;
    camZ = posZ + hauteur;
    lookX = posX*20 + dirX*20;
    lookY = posY*20 + dirY*20;
    lookZ = posZ;
  }
  
  if (anim > 0) {
    anim--;
  }

  // Gestionnaire de camera
  camera(
    camX, camY, camZ,
    camX + dirX*20, camY + dirY*20, camZ,
    0, 0, -1
    );

  // Gestionnaire de deplacements
  gestionDeplacements();
  
  // Gestionnaire de sol désertique
  gestionRenderSol();
  
  // Gestionnaire d'escaliers
  gererEscaliers();
  
  // Update
  updateRotationAnimation();
  updateAllPhantomMummies();
  checkAllMummiesCollision();

  perspective(PI/3.0, float(width)/float(height), 1, 1000);

  estExterieur = checkSiExterieur();

  noTint();

  // ======= Rendu de la scene ========

  resetShader();

  configLights();

  renderPyramide();

  renderRDCMummy();
  
  if (estExterieur) {
    applySandstormEffect();
  }

  if (estExterieur) {
    renderCiel();
  }
  
  noTint();

  // ===== HUD (Minimap, Boussole, Torche) =====
  if (!estExterieur) {
    pushMatrix();
    // On réinitialise la matrice pour passer en coordonnées écran
    resetMatrix();
    lights();
    hint(DISABLE_DEPTH_TEST);

    // Position : en bas à droite
    float offsetX = 700;
    float offsetY = 700;
    if (!estExterieur) {
      translate(width - offsetX+90, height - offsetY+450, -900);
    }

    rotateX(radians(15));
    rotateY(radians(10));

    scale(-3);
    pointLight(251, 139, 35, width - offsetX+90, height - offsetY+240, 0);
    lanterneModel.texture(textureStone);
    shape(lanterneModel);
    updateAndRenderFlame();
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
  noLights();
  drawCompass();

  if (!estExterieur) {
    noLights();
    drawMiniMap();
  }
}

// ====== Configurartion des lumieres ======
// Permet de configurer les lumiere
void configLights() {
  if (estExterieur) {
    directionalLight(180, 180, 180, 0.5, 0.5, -1);

    // On ajoute une lumière ambiante faible pour éviter le noir complet dans les zones d'ombre.
    ambientLight(40, 40, 50);
  } else {
    float falloffConstant   = 0.8;    // Atténuation constante
    float falloffLinear     = 0.05;   // Atténuation linéaire
    float falloffQuadratic  = 0.001;  // Atténuation quadratique
    lightFalloff(falloffConstant, falloffLinear, falloffQuadratic);

    // Couleur de la lumière (lanterne) : légèrement "chaude"
    // Pour un effet "feu" : vers l'orangé/jaune
    float r = 255;
    float g = 145;
    float b = 68;

    // Position du joueur en "coordonnées Processing" (x20)
    // + légère hauteur pour que la lumière soit au niveau du regard
    float lx = posX * 20;
    float ly = posY * 20;
    float lz = posZ + hauteur;


    // Lumière ponctuelle qui fera office de lanterne
    ambientLight(r, g, b, lx-8, ly, lz);
  }
}
