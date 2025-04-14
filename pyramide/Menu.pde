// ======= Variables ========
int currentState = 0; // 0 : menu, 1 : jeu
float camAngle = 0;

// ======= Gestionnaire du clic de la souris ========
void mousePressed() {
  if (currentState == 0) {
    // Définition des dimensions et position du bouton Play
    int btnWidth = 150;
    int btnHeight = 50;
    int btnX = width/2 - btnWidth/2;
    int btnY = height/2 - btnHeight/2;

    // Si le clic se fait dans la zone du bouton
    if (mouseX > btnX && mouseX < btnX + btnWidth &&
      mouseY > btnY && mouseY < btnY + btnHeight) {
      currentState = 1;
      if (!button.isPlaying()) {
        button.play();
      }
    }
  }
}

// ======= Dessine le Menu du Jeu ========
void drawMenu() {
  // == Gestion son ==
  if (!ambiantExterieur.isPlaying()) {
    ambiantExterieur.loop();
  }
  if (ambiantInterieur.isPlaying()) {
    ambiantInterieur.stop();
  }

  // == Scene en Arriere Plan ==
  pushMatrix();
  renderCiel();

  translate(width/2, height/2, 0);
  camAngle += 0.01;
  rotateY(PI);
  rotateY(camAngle);

  // Affichage de la pyramide extérieure au centre
  pushMatrix();
  translate(-500, 300, 230);
  rotateX(PI/2);
  renderPyramideLisseExterieure(300, 21, 20, false);
  popMatrix();

  // Affichage de la pyramide extérieure a droite
  pushMatrix();
  translate(0, 300, 0);
  rotateX(PI/2);
  renderPyramideLisseExterieure(220, 18, 17, true);
  popMatrix();

  // Affichage de la pyramide extérieure a gauche
  pushMatrix();
  translate(-1000, 300, 460);
  rotateX(PI/2);
  renderPyramideLisseExterieure(240, 16, 20, true);
  popMatrix();

  //Affichage du sol
  pushMatrix();
  translate(0, 300, 0);
  rotateX(PI/2);
  scale(5);
  genererSolDesertique();
  renderSolDesertique(false);
  popMatrix();

  popMatrix();

  // === Titre et Bouttons ===
  drawPlayButton();
  drawTitle();
  textSize(22);
  textAlign(LEFT, CENTER);
}

// ========= Desssine le bouton Play ============
void drawPlayButton() {
  // Définition des dimensions et position du bouton
  int btnWidth = 150;
  int btnHeight = 50;
  int btnX = width/2 - btnWidth/2;
  int btnY = height/2 - btnHeight/2;

  stroke(0);
  strokeWeight(2);
  fill(255);
  rect(btnX, btnY, btnWidth, btnHeight, 10);

  // Configuration du texte
  textAlign(CENTER, CENTER);
  textSize(30);

  // On dessine le contour
  fill(0);
  text("JOUER", width/2 - 1, height/2);
  text("JOUER", width/2 + 1, height/2);
  text("JOUER", width/2, height/2 - 1);
  text("JOUER", width/2, height/2 + 1);

  // Dessine le titre
  fill(0, 102, 204);
  text("JOUER", width/2, height/2);
}

// ========= Dessine le titre du jeu ==============
void drawTitle() {
  
  // Configuration du texte
  textAlign(CENTER, CENTER);
  textSize(80);
  
  // On dessine le contour
  fill(155, 120, 0);
  text("LABYMOMIE", width/2 - 2, 100);
  text("LABYMOMIE", width/2 + 2, 100);
  text("LABYMOMIE", width/2, 100 - 2);
  text("LABYMOMIE", width/2, 100 + 2);

  // Dessine le titre
  fill(255, 215, 0);
  text("LABYMOMIE", width/2, 100);
}
