// Implémentation des escaliers entre les niveaux de la pyramide

// Fonction pour rendre un escalier entre deux niveaux
/*
void renderEscalier(int niveauDepart) {
  int labSizeDepart = LAB_SIZES[niveauDepart];
  int labSizeArrivee = LAB_SIZES[niveauDepart + 1];
  float hauteurDepart = HAUTEURS_NIVEAUX[niveauDepart];
  float hauteurArrivee = HAUTEURS_NIVEAUX[niveauDepart + 1];
  int decalageDepart = DECALAGES[niveauDepart];
  int decalageArrivee = DECALAGES[niveauDepart + 1];
  
  // Position de l'escalier au niveau de départ (près de la sortie)
  int escX = labSizeDepart - 2;
  int escY = labSizeDepart - 2;
  
  // Nombre de marches
  int nbMarches = 20;
  float hauteurMarche = (hauteurArrivee - hauteurDepart) / nbMarches;
  float largeurMarche = 20.0 / nbMarches;
  
  pushMatrix();
  translate((escX + decalageDepart) * 20, (escY + decalageDepart) * 20, hauteurDepart);
  
  // Dessiner les marches
  for (int i = 0; i < nbMarches; i++) {
    pushMatrix();
    translate(0, 0, i * hauteurMarche);
    
    // Utiliser la texture de pierre
    texture(textureStone);
    
    // Dessiner la marche
    beginShape(QUADS);
    texture(textureStone);
    
    // Surface horizontale de la marche
    vertex(0, 0, hauteurMarche, 0, 0);
    vertex(20, 0, hauteurMarche, 1, 0);
    vertex(20, largeurMarche, hauteurMarche, 1, 1);
    vertex(0, largeurMarche, hauteurMarche, 0, 1);
    
    // Face verticale de la marche
    vertex(0, 0, 0, 0, 0);
    vertex(20, 0, 0, 1, 0);
    vertex(20, 0, hauteurMarche, 1, 1);
    vertex(0, 0, hauteurMarche, 0, 1);
    
    // Face latérale gauche
    vertex(0, 0, 0, 0, 0);
    vertex(0, largeurMarche, 0, 1, 0);
    vertex(0, largeurMarche, hauteurMarche, 1, 1);
    vertex(0, 0, hauteurMarche, 0, 1);
    
    // Face latérale droite
    vertex(20, 0, 0, 0, 0);
    vertex(20, largeurMarche, 0, 1, 0);
    vertex(20, largeurMarche, hauteurMarche, 1, 1);
    vertex(20, 0, hauteurMarche, 0, 1);
    
    endShape();
    
    // Déplacer pour la prochaine marche
    translate(0, largeurMarche, 0);
    
    popMatrix();
  }
  
  // Ajouter un indicateur visuel pour l'escalier
  pushMatrix();
  translate(10, 10, nbMarches * hauteurMarche + 5);
  fill(0, 100, 255);
  sphere(3);
  popMatrix();
  
  popMatrix();
}
*/
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
      text("Appuyez sur 'E' pour monter", width/2 - 100, height - 50);
      
      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    }
    else if (labyrinthes[niveauActuel][cellY][cellX] == 'D') {
      pushMatrix();
      camera();
      perspective();
      hint(DISABLE_DEPTH_TEST);
      
      fill(255);
      textSize(16);
      text("Appuyez sur 'D' pour descendre", width/2 - 100, height - 50);
      
      hint(ENABLE_DEPTH_TEST);
      popMatrix();
    }
  }
}

// Fonction pour animer la montée/descente des escaliers
void animerMonteeDescente(int nouveauNiveau, float nouvellePosX, float nouvellePosY) {
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
  posX = nouvellePosX+0.4;
  posY = nouvellePosY;
  posZ = HAUTEURS_NIVEAUX[niveauActuel];
  
  // Démarrer l'animation
  animMode = 1;
  anim = 40; // Animation plus longue pour la montée/descente
}
