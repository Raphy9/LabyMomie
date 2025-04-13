ArrayList<PShape> niveauxShapes = new ArrayList<PShape>();
int NIVEAUACTUEL =0;

char[][][] labyrinthes;
char[][][][] sides;
float posX, posY, posZ, dirX, dirY;
float oldDirX, oldDirY;
float oldPosX, oldPosY, oldPosZ;
float targetPosX, targetPosY, targetPosZ;  // Position cible à atteindre

// Variables d'animation
float animationTimer = 0;                // Timer qui suit l'avancement de l'animation
float animationDuration = 0.2;           // Durée de l'animation (en secondes) – à ajuster selon ton goût
boolean isMoving = false;                // True si le joueur est en train de se déplacer
float collisionDistance = 8;             // Seuil de collision avec la momie

float hauteur = 10; // Hauteur caméra
int anim = 0;
int animMode = 0; // 0 = pas d'animation, 1 = animation de translation, 2 = animation de rotation
int niveauActuel = 0; // Niveau actuel du joueur (0 = base, 1 = milieu, 2 = sommet)
boolean estExterieur = false; // Si le joueur est à l'extérieur ou pas.
boolean[][][] decouvert;

// Textures
PImage textureStone;
PImage texturePorte;
PImage textureSable;
PImage textureStoneJaune;
PImage textureporteJaune;
PImage textureCiel;
PImage textureSolPlafond;
PImage textureSolPlafondJaune;

PShape lanterneModel;


float time = 0;

void setup() {
  frameRate(20);
  randomSeed(2);
  size(1000, 1000, P3D);

  lanterneModel = createTorch3D();
  surface.setTitle("Des momies et des pyramides !");
  // Chargement des textures
  textureStone = loadImage("stone.jpg");
  if (textureStone == null) {
    System.out.println("La texture n'existe pas");
  }
  texturePorte = loadImage("porte.png");
  textureSolPlafond = loadImage("textureSolPlafond.png");
  textureSolPlafondJaune = createTextureJaune(textureSolPlafond);
  textureStoneJaune = textureStone;
  textureSable = loadImage("desert.png");
  
  textureCiel = loadImage("ciel.png");

  textureMode(NORMAL);
 hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];

  initSandstormShader();

  mummyGroup = createMummy();

  // On initialise les labyrinthes pour chaque niveau
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

  decouvert = new boolean[NIVEAUX][][];

  initBrouillardMiniMap();
  
  // Initialisation des variables de position et direction
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
  
  // Initialisation des momies pour chaque niveau
  initMomies();
}

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

void drawGame() {
  float camX, camY, camZ, lookX, lookY, lookZ;

  // On calcule le delta temps approximatif en fonction du frameRate courant
  float dt = 1.0 / frameRate;

  if (isMoving && anim <= 0) {
    animationTimer += dt;
    float ratio = constrain(animationTimer / animationDuration, 0, 1);

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

  background(100, 0, 255); // Fond bleu ciel

  camera(
    camX, camY, camZ,
    camX + dirX*20, camY + dirY*20, camZ,
    0, 0, -1
    );

  if (estExterieur) {
    renderCiel();
  }

  if (anim > 0) {
    anim--;
  }
  
  gestionDeplacements();
  updateRotationAnimation();

  // Mise à jour de toutes les momies
  updateAllMummies();

  // Vérification des collisions avec les momies
  checkAllMummiesCollision();

  perspective(PI/3.0, float(width)/float(height), 1, 1000);

  estExterieur = checkSiExterieur();

  resetShader();
  
  noTint();

  configLights();

  gestionRenderSol();

  renderPyramide();

  renderAllMummies();

  noTint();

  gererEscaliers();

  if (estExterieur) {
    applySandstormEffect();
  }
  
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
      translate(width - offsetX+90, height - offsetY+240, -900);
    }

    rotateX(radians(15));
    rotateY(radians(10));
    
    scale(-3);
    pointLight(251, 139, 35, width - offsetX+90 , height - offsetY+240, 0); 
    lanterneModel.texture(textureStone);
    shape(lanterneModel);
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
  noLights();
  drawCompass();
  
  if(!estExterieur) {
    noLights();
    drawMiniMap();
  }
}

void initBrouillardMiniMap() {
  for (int niv = 0; niv < NIVEAUX; niv++) {
    decouvert[niv] = new boolean[LAB_SIZES[niv]][LAB_SIZES[niv]];
    // Par défaut, tout est false => "non découvert"
    for (int j = 0; j < LAB_SIZES[niv]; j++) {
      for (int i = 0; i < LAB_SIZES[niv]; i++) {
        decouvert[niv][j][i] = false;
      }
    }
  }
}


// Pour la pyramide complète
void renderPyramide() {
  // Pyramide d'origine (existante)
  pushMatrix();
  translate(0, 0, -1);
  shape(niveauxShapes.get(NIVEAUACTUEL));
  renderPyramideLisseExterieure(300, 21, 20, false);
  popMatrix();

  // Deuxième pyramide (à gauche)
  pushMatrix();
  translate(550, -229, -5);
  renderPyramideLisseExterieure(220, 18, 17, true);
  popMatrix();

  // 3e pyramide (à droite)
  pushMatrix();
  translate(-420, +229, -50);
  renderPyramideLisseExterieure(240, 16, 20, true);
  popMatrix();
}

void configLights() {
  if (estExterieur) {
    directionalLight(180, 180, 180, 0.5, 0.5, -1);

    // Ajout d'une lumière ambiante faible pour éviter le noir complet dans les zones d'ombre
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

PShape creerTorche(PApplet p) {
  // Crée un groupe de shapes pour contenir la torche complète
  PShape torche = p.createShape(PShape.GROUP);

  // --- Création du manche de la torche ---
  PShape manche = p.createShape();
  manche.beginShape();
  manche.fill(139, 69, 19); // Couleur brun (valeurs au format RGB)
  manche.noStroke();

  // On crée un manche conique vu de face
  manche.vertex(-5, 0);
  manche.vertex(5, 0);
  manche.vertex(8, -80);
  manche.vertex(-8, -80);

  manche.endShape(CLOSE);

  PShape flamme = p.createShape();
  flamme.beginShape();
  flamme.fill(255, 140, 0); // Orange
  flamme.noStroke();

  // Forme de flamme
  flamme.vertex(0, -80);
  flamme.bezierVertex(10, -120, 20, -100, 0, -140);
  flamme.bezierVertex(-20, -100, -10, -120, 0, -80);

  flamme.endShape(CLOSE);

  torche.addChild(manche);
  torche.addChild(flamme);

  return torche;
}


// Fonction d'easing pour un mouvement plus naturel
float easeInOutQuad(float t) {
  if (t < 0.5) {
    return 2 * t * t;
  } else {
    return -1 + (4 - 2 * t) * t;
  }
}
