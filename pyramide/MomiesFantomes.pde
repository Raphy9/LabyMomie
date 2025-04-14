// ===== Structure Momie fantome ==========
class Momie {
  float posX;      // Position X dans le labyrinthe
  float posY;      // Position Y dans le labyrinthe
  float dirX;      // Direction X de déplacement
  float dirY;      // Direction Y de déplacement
  int niveau;      // Niveau de la momie dans la pyramide
  int moveTimer;   // Compteur pour changer de direction

  Momie(float posX, float posY, float dirX, float dirY, int niveau) {
    this.posX = posX;
    this.posY = posY;
    this.dirX = dirX;
    this.dirY = dirY;
    this.niveau = niveau;
    this.moveTimer = 0;
  }
}

Momie[] momies;

// ===== Initialisation des momies fantômes ======
void initMomies() {
  momies = new Momie[NIVEAUX];

  for (int niveau = 0; niveau < NIVEAUX; niveau++) {
    // On essaie plusieurs positions jusqu'à en trouver une valide
    boolean positionTrouvee = false;

    for (int i = 6; i < LAB_SIZES[niveau] - 1 && !positionTrouvee; i++) {
      for (int j = 6; j < LAB_SIZES[niveau] - 1 && !positionTrouvee; j++) {
        float testX = i + DECALAGES[niveau] + 0.5;
        float testY = j + DECALAGES[niveau] + 0.5;

        if (isValidMummyPosition(testX, testY, niveau)) {
          // Direction aléatoire initiale
          float angle = random(TWO_PI);
          float dirX = cos(angle);
          float dirY = sin(angle);

          // Créer la momie et l'ajouter au tableau
          momies[niveau] = new Momie(testX, testY, dirX, dirY, niveau);
          positionTrouvee = true;
        }
      }
    }

    // Si aucune position valide n'est trouvée, on utilise une position par défaut
    if (!positionTrouvee) {
      float angle = random(TWO_PI);
      float dirX = cos(angle);
      float dirY = sin(angle);

      // Par défaut au milieu du labyrinthe
      float posX = LAB_SIZES[niveau]/2 + DECALAGES[niveau];
      float posY = LAB_SIZES[niveau]/2 + DECALAGES[niveau];

      momies[niveau] = new Momie(posX, posY, dirX, dirY, niveau);
    }
  }

  if (momies[0] != null) {
    mummyPosX = momies[0].posX;
    mummyPosY = momies[0].posY;
    mummyDirX = momies[0].dirX;
    mummyDirY = momies[0].dirY;
    mummyNiveau = 0;
    mummyPos.set(mummyPosX * 20, mummyPosY * 20, HAUTEURS_NIVEAUX[mummyNiveau]);
  }
}

// ===== Maj les momies fantômes ======
void updateAllPhantomMummies() {
  // Mettre à jour chaque momie
  for (int i = 0; i < NIVEAUX; i++) {
    if (momies[i] != null) {
      updateMummyAt(i);
    }
  }

  if (momies[0] != null) {
    mummyPosX = momies[0].posX;
    mummyPosY = momies[0].posY;
    mummyDirX = momies[0].dirX;
    mummyDirY = momies[0].dirY;
    mummyPos.set(mummyPosX * 20, mummyPosY * 20, HAUTEURS_NIVEAUX[mummyNiveau]);
  }
}


// ===== Maj une momies fantômes spécifique ======
void updateMummyAt(int niveau) {
  Momie momie = momies[niveau];
  if (momie == null) return;

  // Mise à jour du timer pour changer de direction
  momie.moveTimer++;
  if (momie.moveTimer >= mummyMoveInterval) {
    // Changer de direction aléatoirement
    float angle = random(TWO_PI);
    momie.dirX = cos(angle);
    momie.dirY = sin(angle);
    momie.moveTimer = 0;
  }

  // On calcule la nouvelle position potentielle
  float newMummyPosX = momie.posX + momie.dirX * mummySpeed;
  float newMummyPosY = momie.posY + momie.dirY * mummySpeed;

  // Vérification des collisions avec les murs
  int cellX = int(newMummyPosX - DECALAGES[niveau]);
  int cellY = int(newMummyPosY - DECALAGES[niveau]);

  // Variable permettant de connaître si la nouvelle position est valide (dans les limites et pas un mur)
  boolean canMove = true;

  // Vérifier si la position est dans les limites du labyrinthe
  if (cellX < 0 || cellX >= LAB_SIZES[niveau] ||
    cellY < 0 || cellY >= LAB_SIZES[niveau]) {
    canMove = false;
  }
  // On vérifie si la position est un mur
  else if (labyrinthes[niveau][cellY][cellX] == '#') {
    canMove = false;
  }
  // On vérifie si la position mènerait à l'extérieur (entrée/sortie du labyrinthe)
  else if (cellX == 0 || cellX == LAB_SIZES[niveau]-1 ||
    cellY == 0 || cellY == LAB_SIZES[niveau]-1) {
    // Si c'est une entrée ou sortie, on ne permet pas à la momie de s'y déplacer
    if (labyrinthes[niveau][cellY][cellX] == ' ' &&
      ((cellX == 0) || (cellX == LAB_SIZES[niveau]-1) ||
      (cellY == 0) || (cellY == LAB_SIZES[niveau]-1))) {
      canMove = false;
    }
  } else {
    float margin = 0.3; // Marge pour éviter de traverser les murs

    // Vérifier les cellules adjacentes
    if (newMummyPosX - (cellX + DECALAGES[niveau]) < margin &&
      cellX > 0 && labyrinthes[niveau][cellY][cellX-1] == '#')
      canMove = false;

    if ((cellX + 1 + DECALAGES[niveau]) - newMummyPosX < margin &&
      cellX < LAB_SIZES[niveau]-1 && labyrinthes[niveau][cellY][cellX+1] == '#')
      canMove = false;

    if (newMummyPosY - (cellY + DECALAGES[niveau]) < margin &&
      cellY > 0 && labyrinthes[niveau][cellY-1][cellX] == '#')
      canMove = false;

    if ((cellY + 1 + DECALAGES[niveau]) - newMummyPosY < margin &&
      cellY < LAB_SIZES[niveau]-1 && labyrinthes[niveau][cellY+1][cellX] == '#')
      canMove = false;
  }

  // Mettre à jour la position si possible
  if (canMove) {
    momie.posX = newMummyPosX;
    momie.posY = newMummyPosY;
  } else {
    // Si collision, on change de direction immédiatement
    float angle = random(TWO_PI);
    momie.dirX = cos(angle);
    momie.dirY = sin(angle);
    momie.moveTimer = 0;
  }

  // Si la momie est à l'extérieur alors on la replace à l'intérieur.
  if (checkIfGhostMummyOutsideAt(niveau)) {
    repositionGhostMummyAt(niveau);
  }
}

// ===== Verifie si la momie fantôme est dehors ======
boolean checkIfGhostMummyOutsideAt(int niveau) {
  Momie momie = momies[niveau];
  if (momie == null) return false;

  int cellX = int(momie.posX - DECALAGES[niveau]);
  int cellY = int(momie.posY - DECALAGES[niveau]);

  // On vérifie si la position est en dehors des limites du labyrinthe
  if (cellX < 0 || cellX >= LAB_SIZES[niveau] ||
    cellY < 0 || cellY >= LAB_SIZES[niveau]) {
    return true;
  }

  // On vérifie si la momie est sur une entrée/sortie du labyrinthe
  if ((cellX == 0 || cellX == LAB_SIZES[niveau]-1 ||
    cellY == 0 || cellY == LAB_SIZES[niveau]-1) &&
    labyrinthes[niveau][cellY][cellX] == ' ') {
    return true;
  }

  return false;
}

// ===== Repositionne la momie fantôme à une position valide =========
void repositionGhostMummyAt(int niveau) {
  // On essaie plusieurs positions jusqu'à en trouver une valide
  for (int i = 6; i < LAB_SIZES[niveau] - 1; i++) {
    for (int j = 6; j < LAB_SIZES[niveau] - 1; j++) {
      float testX = i + DECALAGES[niveau] + 0.5;
      float testY = j + DECALAGES[niveau] + 0.5;

      if (isValidMummyPosition(testX, testY, niveau)) {
        momies[niveau].posX = testX;
        momies[niveau].posY = testY;
        return;
      }
    }
  }

  // Si aucune position valide n'est trouvée, on utilise une position par défaut
  momies[niveau].posX = LAB_SIZES[niveau]/2 + DECALAGES[niveau];
  momies[niveau].posY = LAB_SIZES[niveau]/2 + DECALAGES[niveau];
}



// Vérifier les collisions avec toutes les momies Y COMPRIS avec la momie du RDC
void checkAllMummiesCollision() {
  for (int i = 0; i < NIVEAUX; i++) {
    if (momies[i] != null && i == niveauActuel) {
      checkMummyCollisionAt(i);
    }
  }
}

// ===== Verifie la collision avec les momies fantômes ======
void checkMummyCollisionAt(int niveau) {
  Momie momie = momies[niveau];
  if (momie == null) return;

  // Calcul de la distance entre le joueur et la momie en prenant en compte l'échelle utilisée
  float dx = posX*20 - momie.posX*20;
  float dy = posY*20 - momie.posY*20;
  float dz = posZ - HAUTEURS_NIVEAUX[niveau];
  float distance = sqrt(dx*dx + dy*dy + dz*dz);

  if (distance < revealDistance) {
    if (!estExterieur) {
      if (!reveal.isPlaying()) {
        reveal.play();
      }
    }
  }

  if (distance < collisionDistance) {
    if (!estExterieur) {
      if (!death.isPlaying()) {
        death.play();
      }
    }
    currentState = 0;
    posX = 1.4;
    posY = 1.0;
    posZ = HAUTEURS_NIVEAUX[0];
    dirX = 0;
    dirY = 1;
    niveauActuel = 0;
    NIVEAUACTUEL = 0; // On met aussi à jour la variable globale NIVEAUACTUEL
    initBrouillardMiniMap();
  }
}
