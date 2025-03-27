void drawMiniMap() {
  // On réinitialise la caméra et la perspective pour l'affichage 2D
  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  
  // Propriétés de la minimap.
  int mapSize = 200;
  int mapX = 20;
  int mapY = 20;
  int cellSize = mapSize / LAB_SIZES[niveauActuel];
  
  // Background de la mini-carte
  fill(0, 0, 0, 150);
  rect(mapX-5, mapY-5, mapSize+10, mapSize+10);
  
  // Afficher le niveau actuel
  fill(255);
  text("Niveau: " + niveauActuel, mapX, mapY-10);
  
  // Dessiner le labyrinthe du niveau actuel
  for (int j=0; j<LAB_SIZES[niveauActuel]; j++) {
    for (int i=0; i<LAB_SIZES[niveauActuel]; i++) {
      if (labyrinthes[niveauActuel][j][i] == '#') {
        fill(100, 100, 100);
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
  
 // On dessine ici la position de la momie (en violet)
  if (mummyNiveau == niveauActuel) {
    fill(255, 0, 255); // Couleur violette pour la momie
    ellipse(mapX + (mummyPosX-DECALAGES[mummyNiveau])*cellSize, mapY + (mummyPosY-DECALAGES[mummyNiveau])*cellSize, cellSize*1.2, cellSize*1.2);
    
    // On dessine la direction de la momie
    stroke(255, 165, 0); // Orange pour la direction de la momie
    line(mapX + (mummyPosX-DECALAGES[mummyNiveau])*cellSize, mapY + (mummyPosY-DECALAGES[mummyNiveau])*cellSize, 
         mapX + (mummyPosX-DECALAGES[mummyNiveau] + mummyDirX)*cellSize, mapY + (mummyPosY-DECALAGES[mummyNiveau] + mummyDirY)*cellSize);
    noStroke();
  }
  
  hint(ENABLE_DEPTH_TEST);
}
