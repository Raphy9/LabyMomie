// Variables pour savoir si une touche est maintenue
boolean isKeyUpPressed = false;
boolean isKeyDownPressed = false;
boolean isKeyLeftPressed = false;
boolean isKeyRightPressed = false;

void gestionDeplacements() {
  // Si la touche "flèche gauche" est maintenue
  if (isKeyLeftPressed) {
    rotateLeft();
  }
  // Si la touche "flèche droite" est maintenue
  if (isKeyRightPressed) {
    rotateRight();
  }

  // Si la touche "flèche haut" est maintenue
  if (isKeyUpPressed) {
    moveForward();
  }

  // Si la touche "flèche bas" est maintenue
  if (isKeyDownPressed) {
    moveBackward();
  }
  if (!estExterieur) {
    revelerZoneAutourDuJoueur();
  }
}

void revelerZoneAutourDuJoueur() {
  int px = int(posX - DECALAGES[niveauActuel]);
  int py = int(posY - DECALAGES[niveauActuel]);

  int rayon = 3;

  for (int y = py - rayon; y <= py + rayon; y++) {
    for (int x = px - rayon; x <= px + rayon; x++) {
      if (x >= 0 && x < LAB_SIZES[niveauActuel] &&
        y >= 0 && y < LAB_SIZES[niveauActuel]) {
        // On considère la distance si on veut un vrai cercle de rayon 3
        float dist = dist(px, py, x, y);
        if (dist <= rayon) {
          decouvert[niveauActuel][y][x] = true;
        }
      }
    }
  }
}


// Cette fonction est appelée lorsqu'une touche est relâchée
void keyReleased() {
  if (keyCode == 38 || keyCode == 39 || keyCode == 40 || keyCode == 37) {
    // Arrêter l'interpolation de déplacement :
    isMoving = false;
    animationTimer = 0;
    deplacerJoueur(targetPosX, targetPosY);
  }
  // Touche flèche haut
  if (keyCode == 38) {
    isKeyUpPressed = false;
  }
  // Touche flèche bas
  else if (keyCode == 40) {
    isKeyDownPressed = false;
  }
  // Touche flèche gauche
  else if (keyCode == 37) {
    isKeyLeftPressed = false;
  }
  // Touche flèche droite
  else if (keyCode == 39) {
    isKeyRightPressed = false;
  }
}

// Rotation à gauche
void rotateLeft() {
  oldDirX = dirX;
  oldDirY = dirY;

  float angle = -PI / 48;
  float tempDirX = dirX;
  dirX = dirX * cos(angle) - dirY * sin(angle);
  dirY = tempDirX * sin(angle) + dirY * cos(angle);

  float longueur = sqrt(dirX * dirX + dirY * dirY);
  dirX /= longueur;
  dirY /= longueur;

  animMode = 2;
  anim = 0;
}

// Rotation à droite
void rotateRight() {
  oldDirX = dirX;
  oldDirY = dirY;

  float angle = PI / 48;
  float tempDirX = dirX;
  dirX = dirX * cos(angle) - dirY * sin(angle);
  dirY = tempDirX * sin(angle) + dirY * cos(angle);

  float longueur = sqrt(dirX * dirX + dirY * dirY);
  dirX /= longueur;
  dirY /= longueur;

  animMode = 2;
  anim = 0;
}

void moveForward() {
  if (anim > 0) return;
  float newPosX = posX + dirX * 0.6;
  float newPosY = posY + dirY * 0.6;
  deplacerJoueur(newPosX, newPosY);
}

void moveBackward() {
  if (anim > 0) return;
  float newPosX = posX - dirX * 0.6;
  float newPosY = posY - dirY * 0.6;
  deplacerJoueur(newPosX, newPosY);
}

void deplacerJoueur(float newPosX, float newPosY) {
  // Stocker la position actuelle pour l'interpolation
  oldPosX = posX;
  oldPosY = posY;
  oldPosZ = posZ;

  float newPosZ = posZ;  // En général, on ne change pas Z dans ce déplacement

  // Initialisation de la cible en fonction de l'environnement
  if (estExterieur) {
    targetPosX = newPosX;
    targetPosY = newPosY;
    targetPosZ = newPosZ;
  } else {
    int cellX = int(newPosX - DECALAGES[niveauActuel]);
    int cellY = int(newPosY - DECALAGES[niveauActuel]);

    if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] &&
      cellY >= 0 && cellY < LAB_SIZES[niveauActuel]) {
      if (labyrinthes[niveauActuel][cellY][cellX] != '#') {
        boolean canMove = true;
        float margin = 0.2;

        if (newPosX - (cellX + DECALAGES[niveauActuel]) < margin &&
          cellX > 0 && labyrinthes[niveauActuel][cellY][cellX - 1] == '#')
          canMove = false;

        if ((cellX + 1 + DECALAGES[niveauActuel]) - newPosX < margin &&
          cellX < LAB_SIZES[niveauActuel] - 1 && labyrinthes[niveauActuel][cellY][cellX + 1] == '#')
          canMove = false;

        if (newPosY - (cellY + DECALAGES[niveauActuel]) < margin &&
          cellY > 0 && labyrinthes[niveauActuel][cellY - 1][cellX] == '#')
          canMove = false;

        if ((cellY + 1 + DECALAGES[niveauActuel]) - newPosY < margin &&
          cellY < LAB_SIZES[niveauActuel] - 1 && labyrinthes[niveauActuel][cellY + 1][cellX] == '#')
          canMove = false;

        if (canMove) {
          targetPosX = newPosX;
          targetPosY = newPosY;
          targetPosZ = newPosZ;
        } else {
          // Le déplacement est bloqué par un mur
          return;
        }
      } else {
        // La case ciblée est un mur
        return;
      }
    } else {
      // Hors labyrinthe, on autorise le déplacement
      targetPosX = newPosX;
      targetPosY = newPosY;
      targetPosZ = newPosZ;
    }
  }

  // Démarrer l'animation du déplacement
  animationTimer = 0;
  isMoving = true;
}



void keyPressed() {
  if (anim > 0) return;

  // Touche flèche haut
  if (keyCode == 38) {
    isKeyUpPressed = true;
  }
  // Touche flèche bas
  else if (keyCode == 40) {
    isKeyDownPressed = true;
  }
  // Touche flèche gauche
  else if (keyCode == 37) {
    isKeyLeftPressed = true;
  }
  // Touche flèche droite
  else if (keyCode == 39) {
    isKeyRightPressed = true;
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
      NIVEAUACTUEL++;
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
      NIVEAUACTUEL--;
    }
  }
}
