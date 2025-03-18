PShape mummyGroup;  // Le groupe global de la momie

int numBands   = 5;       // Nombre de bandes spirales
float angleStep = 0.3;    // Incrément d'angle par anneau
float bandOffset = 5.0;   // Décalage en angle pour l'épaisseur des bandes
float stepHeight = 3.0;   // Écart vertical entre les anneaux (hauteur)
float rGlobal = 30.0;     // Rayon de base

void setup() {
  size(800, 600, P3D);
  noStroke();
  
  // Création du PShape group global qui contiendra toutes les parties
  mummyGroup = createShape(GROUP);
  
  // ==========================================================
  // 1) Construction du Corps (i de 0 à 64)
  // ==========================================================
  PShape bodyGroup = createShape(GROUP);
  
  for (int b = 0; b < numBands; b++) {
    float globalOffset = TWO_PI * b / numBands;
    
    // Pour chaque bande, on crée un PShape de type QUAD_STRIP
    PShape bandShape = createShape();
    bandShape.beginShape(QUAD_STRIP);
    bandShape.noStroke();
    
    for (int i = 0; i <= 64; i++) {
      float t = map(i, 0, 64, 0, 1);  // t varie de 0 à 1
      // Variation du rayon pour créer un ventre plus large
      float r = rGlobal + 5 * sin(t * PI);
      float angle = i * angleStep + globalOffset;
      float y = i * stepHeight;
      
      // Calcul des deux bords de la bande
      float x1 = r * cos(angle);
      float z1 = r * sin(angle);
      float x2 = r * cos(angle + bandOffset);
      float z2 = r * sin(angle + bandOffset);
      
      // Couleur variable avec noise
      float c = map(noise(i * 0.1 + b), 0, 1, 100, 160);
      bandShape.fill(c, c * 0.8, c * 0.6);
      
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
      // Le rayon décroît de manière linéaire pour la tête
      float r = rGlobal + 0.25 * rGlobal - 5 * tHead;
      float angle = i * angleStep + globalOffset;
      float y = i * stepHeight;
      
      float x1 = r * cos(angle);
      float z1 = r * sin(angle);
      float x2 = r * cos(angle + bandOffset);
      float z2 = r * sin(angle + bandOffset);
      
      float c = map(noise(i * 0.1 + b), 0, 1, 100, 160);
      bandShape.fill(c, c * 0.8, c * 0.6);
      
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
  
  // On choisit iEye dans la zone de la tête (ici i = 75)
  float iEye = 75;
  float tHead = map(iEye, 64, 84, 0, 1);
  float rEye = rGlobal + rGlobal * 0.11 - 5 * tHead;  // Calcul du rayon à la hauteur des yeux
  float yEye = iEye * stepHeight;
  float zOffset = 8;  // Décalage en Z pour séparer les yeux
  
  // Oeil gauche
  PShape leftEye = createShape(SPHERE, 4.5);
  leftEye.setFill(color(0));
  // Positionnement de l'oeil gauche
  leftEye.translate(rEye, -yEye, zOffset);
  eyesGroup.addChild(leftEye);
  
  // Oeil droit
  PShape rightEye = createShape(SPHERE, 4.5);
  rightEye.setFill(color(0));
  // Positionnement de l'oeil droit
  rightEye.translate(rEye, -yEye, -zOffset);
  eyesGroup.addChild(rightEye);
  
  mummyGroup.addChild(eyesGroup);

  // ==========================================================
  // 4) Construction des Bras
  // ==========================================================
  PShape armsGroup = createShape(GROUP);
  
  // Bras gauche
  PShape leftArm = createShape();
  // TODO : definir bras gauche
  armsGroup.addChild(leftArm);
  
  // Bras droit
  PShape rightArm = createShape();
  // TODO : definir bras droit
  armsGroup.addChild(rightArm);
  
  mummyGroup.addChild(armsGroup);
}

void draw() {
  background(255);
  lights();
  
  // Positionnement et rotation de la caméra
  translate(width/2, height/1.5, 0);
  rotateX(PI/6);
  rotateY(frameCount * 0.1);
  
  // Affichage du groupe complet
  shape(mummyGroup);
}
