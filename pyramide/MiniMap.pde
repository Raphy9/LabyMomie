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
  
  // Background de la mini-carte
  fill(0, 0, 0, 150);
  rect(mapX-10, mapY-10, mapSize+10, mapSize+10);
  
  // Afficher le niveau actuel
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
      }
      else if (labyrinthes[niveauActuel][j][i] == 'E') {
        fill(0, 0, 255);     // escalier montant
        rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
      }
      else if (labyrinthes[niveauActuel][j][i] == 'D') {
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
    }
    else if (labyrinthes[niveauActuel][j][i] == 'E') {
      fill(0, 0, 255);
      rect(mapX + i*cellSize, mapY + j*cellSize, cellSize, cellSize);
    }
    else if (labyrinthes[niveauActuel][j][i] == 'D') {
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
  
  // On dessine la momie du niveau actuel sur la minimap
  drawAllMummiesOnMiniMap(mapX, mapY, cellSize);
  
  hint(ENABLE_DEPTH_TEST);
}
