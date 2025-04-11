// --- Variables Globales pour la rotation fluide ---
float currentAngle;   // Angle actuel (en radians)
float targetAngle;    // Angle visé
float rotationStep = PI / 45;  // Incrément de rotation par frame (ici 1° par appel)

// Variables de déplacement déjà existantes
boolean isKeyUpPressed = false;
boolean isKeyDownPressed = false;
boolean isKeyLeftPressed = false;
boolean isKeyRightPressed = false;

// --- Gestion des déplacements ---
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

// --- Fonction d'interpolation de la rotation ---
// Cette fonction doit être appelée à chaque frame (dans draw())
void updateRotationAnimation() {
  // Facteur de lissage (plus il est faible, plus la rotation sera progressive)
  float smoothing = 0.4;
  float diff = targetAngle - currentAngle;
  
  // Normaliser la différence pour éviter de tourner dans le mauvais sens (entre -PI et PI)
  if(diff > PI) {
    diff -= 2 * PI;
  } else if(diff < -PI) {
    diff += 2 * PI;
  }
  
  // Si la différence est très faible, on "snap" directement à targetAngle
  if (abs(diff) < 0.001) {
    currentAngle = targetAngle;
  } else {
    currentAngle += diff * smoothing;
  }
  
  // Mettre à jour le vecteur direction
  dirX = cos(currentAngle);
  dirY = sin(currentAngle);
}

// --- Révélation de la zone autour du joueur (inchangée) ---
void revelerZoneAutourDuJoueur() {
  int px = int(posX - DECALAGES[niveauActuel]);
  int py = int(posY - DECALAGES[niveauActuel]);

  int rayon = 3;

  for (int y = py - rayon; y <= py + rayon; y++) {
    for (int x = px - rayon; x <= px + rayon; x++) {
      if (x >= 0 && x < LAB_SIZES[niveauActuel] &&
          y >= 0 && y < LAB_SIZES[niveauActuel]) {
        float dist = dist(px, py, x, y);
        if (dist <= rayon) {
          decouvert[niveauActuel][y][x] = true;
        }
      }
    }
  }
}

// --- KeyReleased (inchangé pour les déplacements) ---
void keyReleased() {
  // Pour les touches directionnelles
  if (keyCode == 37) {
    isKeyLeftPressed = false;
  }
  else if (keyCode == 39) {
    isKeyRightPressed = false;
  }
  if (keyCode == 38) {
    isKeyUpPressed = false;
  }
  else if (keyCode == 40) {
    isKeyDownPressed = false;
  }
  // Autres actions à la relâche
  if (keyCode == 38 || keyCode == 39 || keyCode == 40 || keyCode == 37) {
    // Par exemple, arrêter l'interpolation de déplacement si besoin
    isMoving = false;
    animationTimer = 0;
    deplacerJoueur(targetPosX, targetPosY);
  }
}

// --- Fonctions de rotation modifiées pour animation fluide ---
void rotateLeft() {
  // Plutôt que d'effectuer la rotation immédiatement, on ajoute une petite rotation à la cible
  targetAngle -= rotationStep;
}

void rotateRight() {
  targetAngle += rotationStep;
}

// --- Fonctions de déplacement en avant/arrière (inchangées) ---
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

// --- Déplacement du joueur (inchangé) ---
void deplacerJoueur(float newPosX, float newPosY) {
  oldPosX = posX;
  oldPosY = posY;
  oldPosZ = posZ;

  float newPosZ = posZ;

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
          return;  // Le déplacement est bloqué par un mur
        }
      } else {
        return;  // La case ciblée est un mur
      }
    } else {
      targetPosX = newPosX;
      targetPosY = newPosY;
      targetPosZ = newPosZ;
    }
  }

  animationTimer = 0;
  isMoving = true;
}

// --- Gestion des touches (inchangée pour la plupart) ---
void keyPressed() {
  if (anim > 0) return;

  if (keyCode == 38) {
    isKeyUpPressed = true;
  }
  else if (keyCode == 40) {
    isKeyDownPressed = true;
  }
  else if (keyCode == 37) {
    isKeyLeftPressed = true;
  }
  else if (keyCode == 39) {
    isKeyRightPressed = true;
  }
  else if (key == 'e' || key == 'E') {
    int cellX = int(posX - DECALAGES[niveauActuel]);
    int cellY = int(posY - DECALAGES[niveauActuel]);

    if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] &&
        cellY >= 0 && cellY < LAB_SIZES[niveauActuel] &&
        labyrinthes[niveauActuel][cellY][cellX] == 'E' &&
        niveauActuel < NIVEAUX - 1) {

      animerMonteeDescente(niveauActuel + 1, 1 + DECALAGES[niveauActuel + 1], 1 + DECALAGES[niveauActuel + 1]);
      NIVEAUACTUEL++;
    }
  }
  else if (key == 'd' || key == 'D') {
    int cellX = int(posX - DECALAGES[niveauActuel]);
    int cellY = int(posY - DECALAGES[niveauActuel]);

    if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] &&
        cellY >= 0 && cellY < LAB_SIZES[niveauActuel] &&
        labyrinthes[niveauActuel][cellY][cellX] == 'D' &&
        niveauActuel > 0) {

      animerMonteeDescente(niveauActuel - 1, (LAB_SIZES[niveauActuel - 1] - 2) + DECALAGES[niveauActuel - 1],
                            (LAB_SIZES[niveauActuel - 1] - 2) + DECALAGES[niveauActuel - 1]);
      NIVEAUACTUEL--;
    }
  }
}

PVector adjustCameraCollision(PVector playerPos, PVector desiredCam) {
  // La direction de la caméra depuis le joueur
  PVector dir = PVector.sub(desiredCam, playerPos);
  float maxDist = dir.mag();
  dir.normalize();
  
  // On parcourt la ligne de playerPos à desiredCam par petits pas
  float step = 1.0;
  float safeDist = maxDist; // par défaut, aucun mur rencontré
  for (float d = 0; d <= maxDist; d += step) {
    PVector sample = PVector.add(playerPos, PVector.mult(dir, d));
    // Conversion des coordonnées sample en coordonnées de la grille
    int gridX = int(sample.x / 20.0 - DECALAGES[niveauActuel]);
    int gridY = int(sample.y / 20.0 - DECALAGES[niveauActuel]);
    
    if (gridX >= 0 && gridX < LAB_SIZES[niveauActuel] &&
        gridY >= 0 && gridY < LAB_SIZES[niveauActuel]) {
      if (labyrinthes[niveauActuel][gridY][gridX] == '#') {
        // Collision détectée : on positionne la distance safe juste avant le mur,
        // en retirant par exemple 2 unités comme marge.
        safeDist = max(0, d - 2);
        break;
      }
    }
  }
  
  // Position safe de la caméra : à partir du joueur, avancer safeDist le long de la direction.
  PVector safeCam = PVector.add(playerPos, PVector.mult(dir, safeDist));
  return safeCam;
}
