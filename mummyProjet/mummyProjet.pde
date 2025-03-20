PShape mummyGroup;  // Le groupe global de la momie

// Paramètres généraux (corps, tête, etc.)
int numBands   = 5;       // Nombre de bandes spirales
float angleStep = 0.3;    // Incrément d'angle par anneau
float bandOffset = 5.0;   // Décalage en angle pour l'épaisseur des bandes
float stepHeight = 3.0;   // Écart vertical entre les anneaux (hauteur)
float rGlobal = 30.0;     // Rayon de base

// Système de particules
ArrayList<Particle> particles = new ArrayList<Particle>();

void setup() {
  size(800, 600, P3D);
  noStroke();
  
  // Création du groupe global de la momie
  mummyGroup = createShape(GROUP);
  
  // ==========================================================
  // 1) Construction du Corps (i de 0 à 64)
  // ==========================================================
  PShape bodyGroup = createShape(GROUP);
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    PShape bandShape = createShape();
    bandShape.beginShape(QUAD_STRIP);
    bandShape.noStroke();
    for (int i = 0; i <= 64; i++) {
      float t = map(i, 0, 64, 0, 1);
      float r = rGlobal + 5 * sin(t * PI);
      float angle = i * angleStep + globalOffset;
      float y = i * stepHeight;
      
      float x1 = r * cos(angle);
      float z1 = r * sin(angle);
      float x2 = r * cos(angle + bandOffset);
      float z2 = r * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 200, 255);
      bandShape.fill(c, c * 0.75, c * 0.5);
      
      bandShape.vertex(x1, -y, z1);
      bandShape.vertex(x2, -y, z2);
    }
    bandShape.endShape();
    bodyGroup.addChild(bandShape);
  }
  mummyGroup.addChild(bodyGroup);
  
  // ==========================================================
  // 2) Construction de la Tête (i de 64 à 84)
  // ==========================================================
  PShape headGroup = createShape(GROUP);
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    PShape bandShape = createShape();
    bandShape.beginShape(QUAD_STRIP);
    bandShape.noStroke();
    for (int i = 64; i <= 84; i++) {
      float tHead = map(i, 64, 84, 0, 1);
      float r = rGlobal + 0.25 * rGlobal - 5 * tHead;
      float angle = i * angleStep + globalOffset;
      float y = i * stepHeight;
      
      float x1 = r * cos(angle);
      float z1 = r * sin(angle);
      float x2 = r * cos(angle + bandOffset);
      float z2 = r * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 200, 255);
      bandShape.fill(c, c * 0.75, c * 0.5);
      
      bandShape.vertex(x1, -y, z1);
      bandShape.vertex(x2, -y, z2);
    }
    bandShape.endShape();
    headGroup.addChild(bandShape);
  }
  mummyGroup.addChild(headGroup);
  
  // ==========================================================
  // 3) Construction des Yeux
  // ==========================================================
  PShape eyesGroup = createShape(GROUP);
  float iEye = 75;
  float tHead = map(iEye, 64, 84, 0, 1);
  float rEye = rGlobal + rGlobal * 0.11 - 5 * tHead;
  float yEye = iEye * stepHeight;
  float zOffset = 8;
    
  PShape leftEye = createShape(SPHERE, 3.5);
  leftEye.setFill(color(0));
  leftEye.translate(rEye, -yEye, zOffset);
  eyesGroup.addChild(leftEye);
  
  PShape wLeftEye = createShape(SPHERE, 6);
  wLeftEye.setFill(color(255));
  wLeftEye.translate(rEye-3, -yEye, zOffset);
  eyesGroup.addChild(wLeftEye);
  
  PShape rightEye = createShape(SPHERE, 3.5);
  rightEye.setFill(color(0));
  rightEye.translate(rEye, -yEye, -zOffset);
  eyesGroup.addChild(rightEye);
  
  PShape wRightEye = createShape(SPHERE, 6);
  wRightEye.setFill(color(255));
  wRightEye.translate(rEye-3, -yEye, -zOffset);
  eyesGroup.addChild(wRightEye);
  
  mummyGroup.addChild(eyesGroup);
  
  // ==========================================================
  // 4) Construction des Bras (une seule fois)
  // ==========================================================
  PShape armsGroup = createShape(GROUP);
  
  // Bras gauche
  PShape leftArm = buildArm();  
  leftArm.translate(0, -60 * stepHeight, -rGlobal);  // Positionnement du bras gauche
  armsGroup.addChild(leftArm);
  
  // Bras droit
  PShape rightArm = buildArm();
  rightArm.translate(0, -60 * stepHeight, rGlobal);  // Positionnement du bras droit
  armsGroup.addChild(rightArm);
  
  mummyGroup.addChild(armsGroup);
}

PShape buildArm() {
  // Paramètres du bras
  int armSegments = 30;       // Nombre de segments le long du bras
  float armBase = 15;         // Rayon de départ (au niveau de l'épaule)
  float armTip = 10;          // Rayon à l'extrémité du bras
  float stepArm = 3.0;        // Écart entre les segments le long du bras
  
  PShape armGroup = createShape(GROUP);
  
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    PShape armBand = createShape();
    armBand.beginShape(QUAD_STRIP);
    armBand.noStroke();
    for (int i = 0; i <= armSegments; i++) {
      float t = map(i, 0, armSegments, 0, 1);
      float rArm = lerp(armBase, armTip, t);
      float angle = i * angleStep + globalOffset;
      float pos = i * stepArm;  // Position le long du bras
      
      float x1 = pos;
      float y1 = rArm * cos(angle);
      float z1 = rArm * sin(angle);
      
      float x2 = pos;
      float y2 = rArm * cos(angle + bandOffset);
      float z2 = rArm * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 200, 255);
      armBand.fill(c, c * 0.75, c * 0.5);
      
      armBand.vertex(x1, y1, z1);
      armBand.vertex(x2, y2, z2);
    }
    armBand.endShape();
    armGroup.addChild(armBand);
  }
  return armGroup;
}

void draw() {
  background(255);
  lights();
  
  // Positionnement et rotation de la scène
  translate(width/2, height/1.5, 0);
  rotateX(-PI/6);
  rotateY(frameCount * 0.02);
  
  // Affichage de la momie
  shape(mummyGroup);
  
  // Mise à jour et affichage des particules autour de la momie
  updateParticles();
  displayParticles();
}

// ==========================================================
// Système de particules
// ==========================================================
void updateParticles() {
  // On ajoute quelques particules chaque frame
  for (int i = 0; i < 5; i++) {
    // On génère une position aléatoire sur une sphère autour du centre de la momie
    PVector spawn = PVector.random3D();
    spawn.mult(random(rGlobal * 0.8, rGlobal * 1.5));
    particles.add(new Particle(spawn));
  }
  
  // Mise à jour et suppression des particules trop vieilles
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}

void displayParticles() {
  // On affiche toutes les particules
  for (Particle p : particles) {
    p.display();
  }
}

// ==========================================================
// Classe Particle
// ==========================================================
class Particle {
  PVector pos;
  PVector vel;
  float lifespan;
  
  Particle(PVector pos) {
    this.pos = pos.copy();
    // Vélocité aléatoire pour donner un léger mouvement
    vel = PVector.random3D();
    vel.mult(random(0.5, 2));
    lifespan = 255;
  }
  
  void update() {
    pos.add(vel);
    lifespan -= 2;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    noStroke();
    fill(194, 167, 144, lifespan); // Couleur avec transparence
    sphere(2);
    popMatrix();
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}
