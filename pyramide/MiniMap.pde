void drawMiniMap() {
  // On réinitialise la caméra et la perspective pour l'affichage 2D
  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);

  // Propriétés de la minimap.
  int mapSize = 200;
  int mapX = 20;
  int mapY = 40;
  int cellSize = mapSize / LAB_SIZES[niveauActuel];

  fill(0, 0, 0, 150);
  rect(mapX-10, mapY-10, mapSize+10, mapSize+10);

  fill(255);
  text("Niveau: " + niveauActuel, mapX+43, mapY-25);

  for (int j = 0; j < LAB_SIZES[niveauActuel]; j++) {
    for (int i = 0; i < LAB_SIZES[niveauActuel]; i++) {

      // 1) Vérifier si on est en bordure du labyrinthe
      boolean isBordure =
        (i == 0 || i == LAB_SIZES[niveauActuel] - 1
        || j == 0 || j == LAB_SIZES[niveauActuel] - 1);

      // 2) Si bordure, on l'affiche quoi qu'il arrive :
      if (isBordure) {
        if (labyrinthes[niveauActuel][j][i] == '#') {
          fill(100, 100, 100); // mur
          rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
        } else if (labyrinthes[niveauActuel][j][i] == 'E') {
          fill(0, 0, 255);     // escalier montant
          rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
        } else if (labyrinthes[niveauActuel][j][i] == 'D') {
          fill(255, 0, 0);     // escalier descendant
          rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
        }
        // else : l'entrée, donc on ne dessine rien
        continue; // on passe à la prochaine cellule
      }

      // 3) Si on est **à l'intérieur**, on dessine seulement si c'est découvert :
      if (!decouvert[niveauActuel][j][i]) {
        fill(0); // non exploré => noir
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
        continue;
      }

      // 4) Cellule intérieure + découverte => on l'affiche normalement
      if (labyrinthes[niveauActuel][j][i] == '#') {
        fill(100, 100, 100); // mur
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
      } else if (labyrinthes[niveauActuel][j][i] == 'E') {
        fill(0, 0, 255);
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
      } else if (labyrinthes[niveauActuel][j][i] == 'D') {
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

  if (niveauActuel == 0) {
    drawRDCMummyOnMiniMap(mapX, mapY, cellSize);
  }

  // Si on est à l'étage 1 ou supérieur, on affiche le détecteur de momie circulaire
  if (niveauActuel >= 1) {
    drawMummyDetector();
  }

  hint(ENABLE_DEPTH_TEST);
}

void drawMummyDetector() {
  int detectorSize = 100;
  int detectorX = width / 2;
  int detectorY = height - detectorSize - 20;

  // On dessine le fond du détecteur
  noStroke();
  fill(0, 0, 0, 150);
  ellipse(detectorX, detectorY, detectorSize, detectorSize);

  // On dessine le cercle extérieur du détecteur
  noFill();
  stroke(255, 255, 255, 200);
  strokeWeight(2);
  ellipse(detectorX, detectorY, detectorSize, detectorSize);

  // On dessine les lignes de repère
  stroke(255, 255, 255, 100);
  strokeWeight(1);
  line(detectorX - detectorSize/2, detectorY, detectorX + detectorSize/2, detectorY);
  line(detectorX, detectorY - detectorSize/2, detectorX, detectorY + detectorSize/2);

  noStroke();
  fill(0, 255, 0);
  ellipse(detectorX, detectorY, 5, 5);

  detectAndDisplayNearbyMummies(detectorX, detectorY, detectorSize);

  strokeWeight(1);
  noStroke();
}


void detectAndDisplayNearbyMummies(int centerX, int centerY, int detectorSize) {
  float maxDetectionDistance = 150;

  float detectorRadius = detectorSize / 2;

  // On ne vérifie que la momie de l'étage actuel
  if (momies[niveauActuel] != null) {
    Momie momie = momies[niveauActuel];

    float dx = posX*20 - momie.posX*20;
    float dy = posY*20 - momie.posY*20;
    float dz = posZ - HAUTEURS_NIVEAUX[niveauActuel];
    float distance = sqrt(dx*dx + dy*dy + dz*dz);

    // Si la momie est à portée de détection
    if (distance < maxDetectionDistance) {
      // On calcule la position relative de la momie par rapport au joueur
      float relativeX = dx / maxDetectionDistance * detectorRadius;
      float relativeY = dy / maxDetectionDistance * detectorRadius;

      float mummyX = centerX - relativeX;
      float mummyY = centerY - relativeY;

      // On calcule la taille du point en fonction de la distance (plus proche = plus grand)
      float pointSize = map(distance, 0, maxDetectionDistance, 10, 5);

      noStroke();
      fill(255, 0, 255);
      ellipse(mummyX, mummyY, pointSize, pointSize);

      if (distance < maxDetectionDistance / 3) {
        if (frameCount % 10 < 5) {
          // On dessine un cercle autour du cercle de la momie pour indiquer qu'elle est très proche
          noFill();
          stroke(255, 0, 255, 150);
          strokeWeight(1);
          ellipse(mummyX, mummyY, pointSize * 2, pointSize * 2);
        }
      }
    }
  }
}
