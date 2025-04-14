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
//var pr la pos de la momie
PVector mummyPos = new PVector(-688, 300, -1100);


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
    // Si c'est une entrée ou sortie, on ne permet pas à la momie de s'y déplacer
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
  
  // Mise à jour de la position globale de la momie
  mummyPos.set(mummyPosX * 20, mummyPosY * 20, HAUTEURS_NIVEAUX[mummyNiveau]);
}

// Dessine la momie du rez de chaussée sur la minimap (car après on les cache pour complexifier le jeu).
void drawRDCMummyOnMiniMap(int mapX, int mapY, int cellSize) {
  if (momies[niveauActuel] != null) {
    Momie momie = momies[niveauActuel];
    
    fill(255, 0, 255); // Couleur violette pour la momie
    ellipse(mapX + (momie.posX-DECALAGES[niveauActuel])*cellSize, 
            mapY + (momie.posY-DECALAGES[niveauActuel])*cellSize, 
            cellSize*1.2, cellSize*1.2);
    
    // On dessine la direction de la momie
    stroke(255, 165, 0); // Orange pour la direction de la momie
    line(mapX + (momie.posX-DECALAGES[niveauActuel])*cellSize, 
         mapY + (momie.posY-DECALAGES[niveauActuel])*cellSize, 
         mapX + (momie.posX-DECALAGES[niveauActuel] + momie.dirX)*cellSize, 
         mapY + (momie.posY-DECALAGES[niveauActuel] + momie.dirY)*cellSize);
    noStroke();
  }
}



//=====================FONCTION  MOMIE===================================

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
