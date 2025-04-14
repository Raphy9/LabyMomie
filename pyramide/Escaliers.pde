// Fonction pour gérer la montée/descente des escaliers
void gererEscaliers() {
  // Vérifier si le joueur est sur un escalier montant
  int cellX = int(posX - DECALAGES[niveauActuel]);
  int cellY = int(posY - DECALAGES[niveauActuel]);

  if (cellX >= 0 && cellX < LAB_SIZES[niveauActuel] &&
    cellY >= 0 && cellY < LAB_SIZES[niveauActuel]) {

    // Afficher un message si le joueur est sur un escalier
    if (labyrinthes[niveauActuel][cellY][cellX] == 'E') {
      pushMatrix();
      camera();
      perspective();
      hint(DISABLE_DEPTH_TEST);

      fill(255);
      textSize(16);
      noLights();
      text("Appuyez sur 'E' pour monter", width/2 - 100, height - 50);

      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    } else if (labyrinthes[niveauActuel][cellY][cellX] == 'D') {
      pushMatrix();
      camera();
      perspective();
      hint(DISABLE_DEPTH_TEST);

      fill(255);
      textSize(16);
      noLights();
      text("Appuyez sur 'D' pour descendre", width/2 - 100, height - 50);

      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
}

// Fonction pour animer la montée/descente des escaliers
void animerMonteeDescente(int nouveauNiveau, float nouvellePosX, float nouvellePosY) {
  if (warp.isPlaying()) {
    warp.stop();
  }
  if (!warp.isPlaying()) {
    warp.play();
  }

  oldPosX = posX;
  oldPosY = posY;
  oldPosZ = posZ;

  // Calculer la position intermédiaire pour l'animation
  float posXIntermediaire, posYIntermediaire, posZIntermediaire;

  if (nouveauNiveau > niveauActuel) {
    // Montée
    posXIntermediaire = (LAB_SIZES[niveauActuel] - 2) + DECALAGES[niveauActuel];
    posYIntermediaire = (LAB_SIZES[niveauActuel] - 2) + DECALAGES[niveauActuel];
    posZIntermediaire = HAUTEURS_NIVEAUX[niveauActuel] + (HAUTEURS_NIVEAUX[nouveauNiveau] - HAUTEURS_NIVEAUX[niveauActuel]) / 2;
  } else {
    // Descente
    posXIntermediaire = 1 + DECALAGES[niveauActuel];
    posYIntermediaire = 1 + DECALAGES[niveauActuel];
    posZIntermediaire = HAUTEURS_NIVEAUX[niveauActuel] + (HAUTEURS_NIVEAUX[nouveauNiveau] - HAUTEURS_NIVEAUX[niveauActuel]) / 2;
  }

  // Mettre à jour le niveau actuel et la position
  niveauActuel = nouveauNiveau;
  NIVEAUACTUEL = nouveauNiveau;
  posX = nouvellePosX+0.4;
  posY = nouvellePosY+0.4;
  posZ = HAUTEURS_NIVEAUX[niveauActuel];

  // Démarrer l'animation
  animMode = 1;
  anim = 10; // Animation plus longue pour la montée/descente
}
