// ===== Variables =====
float compassRadius = 150;
float compassThickness = 40;

// =================================== Création de notre boussole ==============================

// Affiche la boussole
void drawCompass() {
  // On réinitialise la caméra et la perspective pour l'affichage 2D
  camera();
  perspective();
  hint(DISABLE_DEPTH_TEST);
  scale(0.4);
  rotateX(radians(25));
  rotateY(PI);
  rotateZ(radians(-30));
  pushMatrix();
  drawCompassBody(compassRadius, compassThickness);
  pushMatrix();
  translate(0, 0, -compassThickness/2.0);
  // Le cadre de la boussole reste fixe
  drawCompassFace(compassRadius);
  popMatrix();
  hint(ENABLE_DEPTH_TEST);

  popMatrix();
}

// Affiche le socle de la boussole
void drawCompassBody(float radius, float thickness) {
  int nbSteps = 60; // Nombre de segments pour faire le tour du cylindre
  float angleStep = TWO_PI / nbSteps;
  float halfH = thickness/2.0; // Moitié de l'épaisseur (pour dessiner de -halfH à +halfH)

  translate(-width*1.42, height*1.25, 0);
  fill(150, 100, 50);
  noStroke();

  // --- Face latérale du cylindre ---
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= nbSteps; i++) {
    float angle = i * angleStep;
    float x = cos(angle) * radius;
    float y = sin(angle) * radius;
    // On relie deux points : (x, y, -halfH) et (x, y, +halfH)
    vertex(x, y, -halfH);
    vertex(x, y, +halfH);
  }
  endShape();

  // --- Face du bas ---
  // On dessine un disque (TRIANGLE_FAN)
  beginShape(TRIANGLE_FAN);
  vertex(0, 0, +halfH);   // centre
  for (int i = 0; i <= nbSteps; i++) {
    float angle = i * angleStep;
    float x = cos(angle) * radius;
    float y = sin(angle) * radius;
    vertex(x, y, +halfH);
  }
  endShape();
}

// Affiche le cadran de la boussole
void drawCompassFace(float radius) {
  noStroke();
  fill(232, 216, 178);
  circle3D(radius);

  noFill();
  stroke(100, 60, 30);
  strokeWeight(3);
  circle3D(radius - 5);

  pushMatrix();
  translate(0, 0, -1);

  // --- Points cardinaux (N, E, S, O) ---
  
  pushMatrix();
  textAlign(CENTER, CENTER);
  textSize(25);
  fill(0);
  float textRadius = radius * 0.7;

  pushMatrix();
  translate(0, -textRadius);
  rotateX(PI);
  text("N", 0, 0);
  popMatrix();

  pushMatrix();
  translate(textRadius, 0);
  rotateY(PI);
  text("E", 0, 0);
  popMatrix();

  pushMatrix();
  translate(0, textRadius);
  rotateY(PI);
  text("S", 0, 0);
  popMatrix();

  pushMatrix();
  translate(-textRadius, 0);
  rotateY(PI);
  text("O", 0, 0);
  popMatrix();
  popMatrix();

  // Rotation des aiguilles en fonction de l'orientation du joueur
  pushMatrix();
  float angleNorth = -currentAngle;
  rotate(angleNorth);
  drawNeedle(radius * 0.52, 8, color(200, 0, 0)); // Aiguille Nord (rouge)
  
  pushMatrix();
  rotate(PI);
  drawNeedle(radius * 0.52, 8, color(0, 0, 200)); // Aiguille Sud (bleue)
  popMatrix();
  
  popMatrix();
  popMatrix();
}

// =================================== Fonction pour notre boussole ==============================

/**
 * Dessine un disque à plat dans le plan XY (Z=0) de rayon r.
 */
void circle3D(float r) {
  int nbSteps = 20;
  float angleStep = TWO_PI / nbSteps;

  beginShape(TRIANGLE_FAN);
  vertex(0, 0, 0); // centre
  for (int i=0; i<=nbSteps; i++) {
    float angle = i * angleStep;
    float x = cos(angle) * r;
    float y = sin(angle) * r;
    vertex(x, y, 0);
  }
  endShape();
}

// Dessine une aiguille pour la boussole
void drawNeedle(float length, float baseHalfWidth, color col) {
  noStroke();
  fill(col);
  
  beginShape();
    vertex(-baseHalfWidth, 0, 0);
    vertex(-2, -length, 0);
    vertex(2, -length, 0);
    vertex(baseHalfWidth, 0, 0);
  endShape(CLOSE);
}

/**
 * Dessine une ligne du centre vers (x2, y2) dans le plan XY (Z = 0).
 */
void line3D(float x1, float y1, float x2, float y2) {
  beginShape(LINES);
  vertex(x1, y1, 0);
  vertex(x2, y2, 0);
  endShape();
}
