ArrayList<PShape> niveauxShapes = new ArrayList<PShape>();
int NIVEAUACTUEL =0;

char[][][] labyrinthes;
char[][][][] sides;
float posX, posY, posZ, dirX, dirY;
float oldDirX, oldDirY;
float oldPosX, oldPosY, oldPosZ;
float targetPosX, targetPosY, targetPosZ;  // Position cible à atteindre

// Variables d’animation
float animationTimer = 0;                // Timer qui suit l’avancement de l’animation
float animationDuration = 0.2;           // Durée de l’animation (en secondes) – à ajuster selon ton goût
boolean isMoving = false;                // True si le joueur est en train de se déplacer

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

PImage textureLanterne;


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
  
  // Charge la lanterne (ici en format OBJ)
  //lanterneModel = loadShape("lanterne.obj");
  //textureLanterne = loadImage("textureLanterne.jpg");
  //lanterneModel.setFill(color(255, 200, 40));

  textureCiel = loadImage("ciel.png");

  textureMode(NORMAL);
 hauteursSol = new float[TAILLE_DESERT][TAILLE_DESERT];
  // Initialisation du shader pour la tempête de sable
  initSandstormShader();

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

  decouvert = new boolean[NIVEAUX][][];

  initBrouillardMiniMap();
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
}

void draw() {
  background(0);

  // Mise à jour du temps pour les shaders
  time += 0.05;

  // Gestion du Menu
  if (currentState == 0) {
    // Affichage du menu
    drawMenu();
  } else if (currentState == 1) {
    // Affichage de ta scène / jeu
    drawGame();
  }
}


// Seuil de collision avec la momie
float collisionDistance = 5;

void drawGame() {
  float camX, camY, camZ, lookX, lookY, lookZ;

  // Calculer le delta temps approximatif en fonction du frameRate courant
  float dt = 1.0 / frameRate;

  // Effectuer l'interpolation de déplacement uniquement si aucune animation d'étage n'est active
  if (isMoving && anim <= 0) {
    animationTimer += dt;
    float ratio = constrain(animationTimer / animationDuration, 0, 1);

    // Appliquer une interpolation easing
    float t = easeInOutQuad(ratio);
    posX = lerp(oldPosX, targetPosX, t);
    posY = lerp(oldPosY, targetPosY, t);
    posZ = lerp(oldPosZ, targetPosZ, t);

    // Arrêter l'animation une fois terminée
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

  // Dessiner le ciel uniquement si on est à l'extérieur
  if (estExterieur) {
    renderCiel();
  }

  if (anim > 0) {
    anim--;
  }

  gestionDeplacements();

  updateMummy();

  // Vérifier la collision entre le joueur et la momie
  checkMummyCollision();

  perspective(PI/3.0, float(width)/float(height), 1, 1000);

  estExterieur = checkSiExterieur();

  resetShader();
  noTint();

  configLights();

  gestionRenderSol();

  renderPyramide();

  renderMummy();

  noTint();

  gererEscaliers();
  // Appliquer l'effet de tempête de sable uniquement si le joueur est à l'extérieur
  if (estExterieur) {
    applySandstormEffect();
  }
  
  // Afficher la lanterne uniquement si le joueur est à l'intérieur du labyrinthe.
  if (!estExterieur) {
    pushMatrix();
    // Réinitialiser la matrice pour passer en coordonnées écran
    resetMatrix();
    lights();
    // Désactiver le test de profondeur pour que la lanterne ne soit pas cachée
    hint(DISABLE_DEPTH_TEST);

    // Positionner la lanterne en bas à droite.
    // Ici, on translate vers (width - offsetX, height - offsetY)
    float offsetX = 700;  // ajuste selon ce qui te convient
    float offsetY = 700;  // idem
    translate(width - offsetX+90, height - offsetY+240, -900);

    // Optionnel : Ajouter une rotation pour simuler l'angle de vue d'une main
    // Par exemple, tourner légèrement autour de l'axe X et Y
    rotateX(radians(15));
    rotateY(radians(10));
    
    // Si besoin, ajuste l'échelle pour qu'elle soit de la bonne taille sur l'écran
    scale(-3);
    pointLight(251, 139, 35, width - offsetX+90 , height - offsetY+240, 0); 
    lanterneModel.texture(textureStone);
    // Affiche le modèle 3D de la lanterne
    shape(lanterneModel);
    // Réactiver le test de profondeur
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }


  noLights(); // sinon les lumières vont affecter la minimap.
  drawMiniMap();
}

// Fonction pour vérifier si le joueur entre en collision avec la momie
void checkMummyCollision() {
  // Calculer la distance entre le joueur et la momie en prenant en compte l'échelle utilisée (ici, multiplication par 20)
  float dx = posX*20 - mummyPos.x;
  float dy = posY*20 - mummyPos.y;
  float dz = posZ - mummyPos.z;
  float distance = sqrt(dx*dx + dy*dy + dz*dz);

  if (distance < collisionDistance) {
    // Le joueur est en collision avec la momie, retour au menu
    currentState = 0;
    posX = 1.4;
    posY = 1.0;
    posZ = HAUTEURS_NIVEAUX[0];
    dirX = 0;
    dirY = 1;
    initBrouillardMiniMap();
    // Optionnel : réinitialiser la position du joueur ou effectuer d'autres actions
    println("Collision avec la momie : retour au menu !");
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

  // 3e pyramide
  pushMatrix();
  translate(-420, +229, -50);
  renderPyramideLisseExterieure(240, 16, 20, true);
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

PShape creerTorche(PApplet p) {
  // Crée un groupe de shapes pour contenir la torche complète
  PShape torche = p.createShape(PShape.GROUP);

  // --- Création du manche de la torche ---
  PShape manche = p.createShape();
  manche.beginShape();
  manche.fill(139, 69, 19); // Couleur brun (valeurs au format RGB)
  manche.noStroke();

  // Définissez ci-dessous les points de la forme du manche
  // Dans cet exemple, on crée un manche conique vu de face
  manche.vertex(-5, 0);
  manche.vertex(5, 0);
  manche.vertex(8, -80);
  manche.vertex(-8, -80);

  manche.endShape(CLOSE);

  // --- Création de la flamme ---
  PShape flamme = p.createShape();
  flamme.beginShape();
  flamme.fill(255, 140, 0); // Couleur orange
  flamme.noStroke();

  // Exemple de forme de flamme dessinée avec des courbes de Bézier
  flamme.vertex(0, -80);
  flamme.bezierVertex(10, -120, 20, -100, 0, -140);
  flamme.bezierVertex(-20, -100, -10, -120, 0, -80);

  flamme.endShape(CLOSE);

  // Ajout du manche et de la flamme au groupe torche
  torche.addChild(manche);
  torche.addChild(flamme);

  // Retourne le PShape complet de la torche
  return torche;
}


// Fonction d'easing pour un mouvement plus naturel (easeInOutQuad)
float easeInOutQuad(float t) {
  if (t < 0.5) {
    return 2 * t * t;
  } else {
    return -1 + (4 - 2 * t) * t;
  }
}
