float currentAngle;   // En radians
float targetAngle= PI/2;
float rotationStep = PI / 30; // Incrément de rotation par frame (ici 1° par appel)

boolean isKeyUpPressed = false;
boolean isKeyDownPressed = false;
boolean isKeyLeftPressed = false;
boolean isKeyRightPressed = false;

void gestionDeplacements() {
  if (isKeyLeftPressed) {
    rotateLeft();
  }
  
  if (isKeyRightPressed) {
    rotateRight();
  }
  
  if (isKeyUpPressed) {
    moveForward();
  }
  
  if (isKeyDownPressed) {
    moveBackward();
  }
  if (!estExterieur) {
    revelerZoneAutourDuJoueur();
  }
}

void updateRotationAnimation() {
  // Facteur de lissage
  float smoothing = 0.2;
  float diff = targetAngle - currentAngle;
  
  // On normalise la différence pour éviter de tourner dans le mauvais sens (entre -PI et PI)
  if(diff > PI) {
    diff -= 2 * PI;
  } else if(diff < -PI) {
    diff += 2 * PI;
  }
  
  if (abs(diff) < 0.001) {
    currentAngle = targetAngle;
  } else {
    currentAngle += diff * smoothing;
  }
  
  dirX = cos(currentAngle);
  dirY = sin(currentAngle);
}

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
  if (keyCode == 38 || keyCode == 39 || keyCode == 40 || keyCode == 37) {
    isMoving = false;
    animationTimer = 0;
    deplacerJoueur(targetPosX, targetPosY);
  }
}

void rotateLeft() {
  targetAngle -= rotationStep;
}

void rotateRight() {
  targetAngle += rotationStep;
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
  oldPosX = posX;
  oldPosY = posY;
  oldPosZ = posZ;

  float newPosZ = posZ;

  if (estExterieur) {
    // Vérifier si le joueur tente de traverser une pyramide extérieure
    if (collisionAvecPyramideExterieure(newPosX, newPosY, newPosZ)) {
      return; // Le déplacement est bloqué par une pyramide extérieure
    }
    
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
      // Le joueur sort du labyrinthe, vérifier s'il tente de traverser une pyramide
      if (collisionAvecPyramideExterieure(newPosX, newPosY, newPosZ)) {
        return; // Le déplacement est bloqué par une pyramide extérieure
      }
      
      targetPosX = newPosX;
      targetPosY = newPosY;
      targetPosZ = newPosZ;
    }
  }

  animationTimer = 0;
  isMoving = true;
}


boolean estDansPyramide(float x, float y, float z, float baseX, float baseY, float baseSize, float hauteurSommet, float marge) {
  // On commence par convertir les coordonnées du joueur en coordonnées relatives à la base de la pyramide
  float relX = x * 20 - baseX;
  float relY = y * 20 - baseY;
  float relZ = z;
  
  // On vérifie ici si le point est à l'intérieur de la base carrée de la pyramide (en prenant en compte la marge)
  if (relX < -marge || relX > baseSize + marge || relY < -marge || relY > baseSize + marge) {
    return false;
  }
  
  float centreX = baseSize / 2;
  float centreY = baseSize / 2;
  
  // Calcul de la distance par rapport au centre
  float distX = abs(relX - centreX) / (centreX + marge/2);
  float distY = abs(relY - centreY) / (centreY + marge/2);
  
  float distMax = max(distX, distY);
  
  // On détermine la hauteur de la pyramide à ce point
  // Quand distMax = 0 (au centre) alors hauteur = hauteurSommet
  // Quand distMax = 1 (au bord) alors hauteur = 0
  float hauteurPoint = hauteurSommet * (1 - distMax);
  
  // On ajoute une marge de sécurité pour la hauteur
  hauteurPoint += 5.0;
  
  // Le point est dans la pyramide si sa hauteur est inférieure à la hauteur de la pyramide à ce point
  return relZ < hauteurPoint;
}

// Fonction pour vérifier si le joueur est en collision avec une pyramide extérieure
boolean collisionAvecPyramideExterieure(float newPosX, float newPosY, float newPosZ) {
  
  // --- Paramètres pour la pyramide principale ---
  float baseX = 0;
  float baseY = 0;
  float baseSize = 21 * 20; // Rappel : nbCases * nbUnites
  float hauteurSommet = 300;
  float margePrincipale = 15.0;
  
  if (estDansPyramide(newPosX, newPosY, newPosZ, baseX, baseY, baseSize, hauteurSommet, margePrincipale)) {
    // Vérifier si le joueur est près d'une entrée
    // Entrée avant (on inclus une certaine marge pour plus de sécurité).
    if (newPosX * 20 >= 20 - margePrincipale && newPosX * 20 <= 40 + margePrincipale && 
        newPosY * 20 <= 0 + margePrincipale && newPosY * 20 >= -15 - margePrincipale) {
      return false; // Pas de collision, c'est une entrée.
    }
    
    // Entrée droite
    if (newPosX * 20 >= baseSize - margePrincipale && newPosX * 20 <= baseSize + 15 + margePrincipale && 
        newPosY * 20 >= baseSize - 40 - margePrincipale && newPosY * 20 <= baseSize - 20 + margePrincipale) {
      return false;
    }
    
    return true; // Collision !
  }
  
  // --- Paramètres de la deuxième pyramide (à gauche) ---
  baseX = 550;
  baseY = -229;
  baseSize = 18 * 17;
  hauteurSommet = 220;
  float margeGauche = 15.0;
  
  // Vérifier si le joueur est à l'intérieur de la deuxième pyramide qui n'a pas d'entrée
  if (estDansPyramide(newPosX, newPosY, newPosZ, baseX, baseY, baseSize, hauteurSommet, margeGauche)) {
    return true;
  }
  
  // --- Paramètres de la troisième pyramide (à droite) ---
  baseX = -420;
  baseY = 229;
  baseSize = 16 * 20;
  hauteurSommet = 240;
  float margeDroite = 1.0;
  
  if (estDansPyramide(newPosX, newPosY, newPosZ, baseX, baseY, baseSize, hauteurSommet, margeDroite)) {
    return true;
  }
  
  return false;
}

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
