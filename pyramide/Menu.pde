// 0 : menu, 1 : jeu 
int currentState = 0;

// Pour la rotation de la vue 360° dans le menu
float camAngle = 0;

// Gestion du clic de la souris
void mousePressed() {
  if (currentState == 0) {
    // Définition des dimensions et position du bouton "Play"
    int btnWidth = 150;
    int btnHeight = 50;
    int btnX = width/2 - btnWidth/2;
    int btnY = height/2 - btnHeight/2;
    
    // Vérification si le clic se fait dans la zone du bouton
    if (mouseX > btnX && mouseX < btnX + btnWidth &&
        mouseY > btnY && mouseY < btnY + btnHeight) {
      // Passage à l'état "jeu" qui reprend ta scène exactement où elle en était
      currentState = 1;
    }
  }
}

void drawMenu() {
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
  
  // Affichage de la momie à côté de la pyramide
  /*
  pushMatrix();
  translate(-688, 300, -1100);
  rotateX(PI/2);
  scale(5); 
  renderMummy();
  popMatrix();
  */
  
  //Affichage du sol
  pushMatrix();
  translate(0,300,0);
  rotateX(PI/2);
  scale(5);
  gestionRenderSol();
  popMatrix();
 
  
  
  popMatrix();
  
  // affichage du bouton "Play"
  drawPlayButton();
  // affichage du titre
  drawTitle();
  
  //remet les param de text comme avant
  textSize(22);
  textAlign(LEFT, CENTER);
  
}


void drawPlayButton() {
  // Définition des dimensions et position du bouton
  int btnWidth = 150;
  int btnHeight = 50;
  int btnX = width/2 - btnWidth/2;
  int btnY = height/2 - btnHeight/2;
  
  // Dessiner le bouton
  stroke(0);
  strokeWeight(2);
  fill(255);
  rect(btnX, btnY, btnWidth, btnHeight, 10);
  
  // Configuration du texte
  textAlign(CENTER, CENTER);
  textSize(30);
  
  // Pour créer un effet de contour noir autour du texte,
  // on dessine d'abord le texte en noir, légèrement décalé dans plusieurs directions.
  fill(0);
  text("JOUER", width/2 - 1, height/2);
  text("JOUER", width/2 + 1, height/2);
  text("JOUER", width/2, height/2 - 1);
  text("JOUER", width/2, height/2 + 1);
  
  // Dessiner ensuite le texte principal au centre avec une couleur contrastante.
  fill(0, 102, 204);
  text("JOUER", width/2, height/2);
}

// Fonction pour dessiner le titre du jeu
void drawTitle() {
  // Configuration du texte
  textAlign(CENTER, CENTER);
  textSize(80);
  fill(155, 120, 0); 
  // On dessine plusieurs fois le texte décalé légèrement pour simuler un contour
  text("LABYMOMIE", width/2 - 2, 100);
  text("LABYMOMIE", width/2 + 2, 100);
  text("LABYMOMIE", width/2, 100 - 2);
  text("LABYMOMIE", width/2, 100 + 2);
  
  // Dessiner le texte principal du titre
  fill(255, 215, 0);
  text("LABYMOMIE", width/2, 100);
}
