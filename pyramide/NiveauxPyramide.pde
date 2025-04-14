// ======= Variables pour niveau ============
final int NIVEAUX = 10;
final int[] LAB_SIZES = {21, 19, 17, 15, 13, 11, 9, 7, 5, 3};
// Attention, un mur fait 20 unités de hauteur !
final float[] HAUTEURS_NIVEAUX = {0, 20, 40, 60, 80, 100, 120, 140, 160, 180};
final float HAUTEUR_SOMMET = 200;
final int[] DECALAGES = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

<<<<<<< HEAD
// ==== Initialisation des labyrinthes pour chaque niveau ====
void initLevelLaby() {
  labyrinthes = new char[NIVEAUX][][];
  sides = new char[NIVEAUX][][][];

  for (int niveau = 0; niveau < NIVEAUX; niveau++) {
    labyrinthes[niveau] = new char[LAB_SIZES[niveau]][LAB_SIZES[niveau]];
    sides[niveau] = new char[LAB_SIZES[niveau]][LAB_SIZES[niveau]][4];
    genererLabyrinthe(niveau);
  }

  // Chargement des niveaux
  for (int niveau = 0; niveau < NIVEAUX; niveau++) {
    niveauxShapes.add(genererShapeNiveau(niveau));
  }
}

// ======= Genere un Laby ========
=======
>>>>>>> parent of 4220c78 (Structure code)
void genererLabyrinthe(int niveau) {
  int labSize = LAB_SIZES[niveau];

  int todig = 0;
  for (int j=0; j<labSize; j++) {
    for (int i=0; i<labSize; i++) {
      sides[niveau][j][i][0] = 0;
      sides[niveau][j][i][1] = 0;
      sides[niveau][j][i][2] = 0;
      sides[niveau][j][i][3] = 0;
      if (j%2==1 && i%2==1) {
        labyrinthes[niveau][j][i] = '.';
        todig++;
      } else
        labyrinthes[niveau][j][i] = '#';
    }
  }

  int gx = 1;
  int gy = 1;
  while (todig > 0) {
    int oldgx = gx;
    int oldgy = gy;
    int alea = floor(random(0, 4));
    if      (alea==0 && gx>1)          gx -= 2;
    else if (alea==1 && gy>1)          gy -= 2;
    else if (alea==2 && gx<labSize-2)  gx += 2;
    else if (alea==3 && gy<labSize-2)  gy += 2;

    if (labyrinthes[niveau][gy][gx] == '.') {
      todig--;
      labyrinthes[niveau][gy][gx] = ' ';
      labyrinthes[niveau][(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
    }
  }

  // Entrée et sortie du labyrinthe (uniquement pour le niveau 0)
  if (niveau == 0) {
    labyrinthes[niveau][0][1] = ' ';
    labyrinthes[niveau][labSize - 2][labSize - 1] = ' ';
  } else {
    // Pour les niveaux supérieurs, on bouche l'emplacement qui servait d'entrée
    labyrinthes[niveau][0][1] = '#';
  }
  // On positionne des escaliers à côté de la sortie
  if (niveau < NIVEAUX - 1) {
    labyrinthes[niveau][labSize-2][labSize-2] = 'E'; // Escalier montant
  }
  if (niveau > 0) {
    labyrinthes[niveau][1][1] = 'D'; // Escalier descendant
  }

  // Calcul des côtés des couloirs
  for (int j=1; j<labSize-1; j++) {
    for (int i=1; i<labSize-1; i++) {
      if (labyrinthes[niveau][j][i]==' ' || labyrinthes[niveau][j][i]=='E' || labyrinthes[niveau][j][i]=='D') {
        if (labyrinthes[niveau][j-1][i]=='#' &&
          (labyrinthes[niveau][j+1][i]==' ' || labyrinthes[niveau][j+1][i]=='E' || labyrinthes[niveau][j+1][i]=='D') &&
          labyrinthes[niveau][j][i-1]=='#' && labyrinthes[niveau][j][i+1]=='#')
          sides[niveau][j-1][i][0] = 1;// c'est un bout de couloir vers le haut
        if ((labyrinthes[niveau][j-1][i]==' ' || labyrinthes[niveau][j-1][i]=='E' || labyrinthes[niveau][j-1][i]=='D') &&
          labyrinthes[niveau][j+1][i]=='#' &&
          labyrinthes[niveau][j][i-1]=='#' && labyrinthes[niveau][j][i+1]=='#')
          sides[niveau][j+1][i][3] = 1;// c'est un bout de couloir vers le bas
        if (labyrinthes[niveau][j-1][i]=='#' && labyrinthes[niveau][j+1][i]=='#' &&
          (labyrinthes[niveau][j][i-1]==' ' || labyrinthes[niveau][j][i-1]=='E' || labyrinthes[niveau][j][i-1]=='D') &&
          labyrinthes[niveau][j][i+1]=='#')
          sides[niveau][j][i+1][1] = 1;// c'est un bout de couloir vers la droite
        if (labyrinthes[niveau][j-1][i]=='#' && labyrinthes[niveau][j+1][i]=='#' &&
          labyrinthes[niveau][j][i-1]=='#' &&
          (labyrinthes[niveau][j][i+1]==' ' || labyrinthes[niveau][j][i+1]=='E' || labyrinthes[niveau][j][i+1]=='D'))
          sides[niveau][j][i-1][2] = 1;// c'est un bout de couloir vers la gauche
      }
    }
  }
}


// ======== Construction du Niveau ============
PShape genererShapeNiveau(int niveau) {
  // Création d'un groupe global pour le niveau
  PShape niveauShape = createShape(GROUP);
  int labSize = LAB_SIZES[niveau];
  float hauteurNiveau = HAUTEURS_NIVEAUX[niveau];
  int decalage = DECALAGES[niveau];

  noStroke();
  // Parcours de toutes les cases du labyrinthe du niveau
  for (int j = 0; j < labSize; j++) {
    for (int i = 0; i < labSize; i++) {
      // Créer un PShape groupe pour la cellule courante
      PShape cellShape = createShape(GROUP);
      // Calcul de la translation de la cellule dans l'espace 3D
      float transX = (i + decalage) * 20;
      float transY = (j + decalage) * 20;
      float transZ = hauteurNiveau;

      // Selon le caractère de la cellule, on recrée les dessins déjà faits dans renderNiveauPyramide
      if (labyrinthes[niveau][j][i] == '#') {
        boolean estExterieur = (i == 0 || i == labSize - 1 || j == 0 || j == labSize - 1);

        // Mur Nord (face avant)
        if (j == 0 || labyrinthes[niveau][j-1][i] != '#') {
          PShape murNord = createShape();
          murNord.beginShape(QUADS);
          if (estExterieur || (j == 0 && i == 1)) {
            murNord.texture(textureStone);
          } else {
            //murNord.texture(textureStone);
            murNord.texture(textureStone);
          }
          murNord.vertex(0, 0, 0, 0, 0);
          murNord.vertex(20, 0, 0, 1, 0);
          murNord.vertex(20, 0, 20, 1, 1);
          murNord.vertex(0, 0, 20, 0, 1);
          murNord.endShape();
          murNord.translate(transX, transY, transZ);
          cellShape.addChild(murNord);
        }

        // Mur Sud (face arrière)
        if (j == labSize - 1 || labyrinthes[niveau][j+1][i] != '#') {
          PShape murSud = createShape();
          murSud.beginShape(QUADS);
          if (estExterieur) {
            murSud.texture(textureStone);
          } else {
            //murSud.texture(textureStone);
            murSud.texture(textureStone);
          }
          murSud.vertex(0, 20, 0, 0, 0);
          murSud.vertex(20, 20, 0, 1, 0);
          murSud.vertex(20, 20, 20, 1, 1);
          murSud.vertex(0, 20, 20, 0, 1);
          murSud.endShape();
          murSud.translate(transX, transY, transZ);
          cellShape.addChild(murSud);
        }

        // Mur Est (face droite)
        if (i == labSize - 1 || labyrinthes[niveau][j][i+1] != '#') {
          PShape murEst = createShape();
          murEst.beginShape(QUADS);
          if (estExterieur) {
            murEst.texture(textureStone);
          } else {
            //murEst.texture(textureStone);
            murEst.texture(textureStone);
          }
          murEst.vertex(20, 0, 0, 0, 0);
          murEst.vertex(20, 20, 0, 1, 0);
          murEst.vertex(20, 20, 20, 1, 1);
          murEst.vertex(20, 0, 20, 0, 1);
          murEst.endShape();
          murEst.translate(transX, transY, transZ);
          cellShape.addChild(murEst);
        }

        // Mur Ouest (face gauche)
        if (i == 0 || labyrinthes[niveau][j][i-1] != '#') {
          PShape murOuest = createShape();
          murOuest.beginShape(QUADS);
          if (estExterieur) {
            murOuest.texture(textureStone);
          } else {
            //murOuest.texture(textureStone);
            murOuest.texture(textureStone);
          }
          murOuest.vertex(0, 0, 0, 0, 0);
          murOuest.vertex(0, 20, 0, 1, 0);
          murOuest.vertex(0, 20, 20, 1, 1);
          murOuest.vertex(0, 0, 20, 0, 1);
          murOuest.endShape();
          murOuest.translate(transX, transY, transZ);
          cellShape.addChild(murOuest);
        }

        // Plafond (face supérieure)
        PShape plafond = createShape();
        plafond.beginShape(QUADS);
        //plafond.texture(textureStone);
        plafond.texture(textureStone);
        plafond.vertex(0, 0, 20, 0, 0);
        plafond.vertex(20, 0, 20, 1, 0);
        plafond.vertex(20, 20, 20, 1, 1);
        plafond.vertex(0, 20, 20, 0, 1);
        plafond.endShape();
        plafond.translate(transX, transY, transZ);
        cellShape.addChild(plafond);

        // Sol (face inférieure)
        PShape sol = createShape();
        sol.beginShape(QUADS);
        //sol.texture(textureStone);
        sol.texture(textureStone);
        sol.vertex(0, 0, 0, 0, 0);
        sol.vertex(20, 0, 0, 1, 0);
        sol.vertex(20, 20, 0, 1, 1);
        sol.vertex(0, 20, 0, 0, 1);
        sol.endShape();
        sol.translate(transX, transY, transZ);
        cellShape.addChild(sol);
      } else if (labyrinthes[niveau][j][i] == ' ') {
        // Sol pour les cases vides - GRIS
        PShape solVide = createShape();
        solVide.beginShape(QUADS);
        solVide.noStroke();
        //solVide.fill(50, 50, 50);
        solVide.texture(textureSolPlafond);
        solVide.vertex(0, 0, 0, 0, 0);
        solVide.vertex(20, 0, 0, 1, 0);
        solVide.vertex(20, 20, 0, 1, 1);
        solVide.vertex(0, 20, 0, 0, 1);
        solVide.endShape();
        solVide.translate(transX, transY, transZ);
        cellShape.addChild(solVide);

        // Plafond pour les cases vides - GRIS
        PShape plafondVide = createShape();
        plafondVide.beginShape(QUADS);
        plafondVide.noStroke();
        //plafondVide.fill(50, 50, 50);
        plafondVide.texture(textureSolPlafond);
        plafondVide.vertex(0, 0, 20, 0, 0);
        plafondVide.vertex(20, 0, 20, 1, 0);
        plafondVide.vertex(20, 20, 20, 1, 1);
        plafondVide.vertex(0, 20, 20, 0, 1);
        plafondVide.endShape();
        plafondVide.translate(transX, transY, transZ);
        cellShape.addChild(plafondVide);
      } else if (labyrinthes[niveau][j][i] == 'E' || labyrinthes[niveau][j][i] == 'D') {
        // Marqueur pour l'emplacement des escaliers
        PShape escalier = createShape();
        escalier.beginShape(QUADS);
        escalier.noStroke();
        if (labyrinthes[niveau][j][i] == 'E') {
          escalier.fill(0, 0, 255); // Bleu pour monter
        } else {
          escalier.fill(255, 0, 0); // Rouge pour descendre
        }
        escalier.vertex(0, 0, 0, 0, 0);
        escalier.vertex(20, 0, 0, 1, 0);
        escalier.vertex(20, 20, 0, 1, 1);
        escalier.vertex(0, 20, 0, 0, 1);
        escalier.endShape();
        escalier.translate(transX, transY, transZ);
        cellShape.addChild(escalier);
      }

      // Ajouter la cellule au niveau
      niveauShape.addChild(cellShape);
    }
  }
  return niveauShape;
}
