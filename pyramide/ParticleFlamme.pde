ArrayList<Particle> flameParticles;

// ========== Structure pour les particules de feu ===========
class Particle {
  PVector basePos;
  float size;
  int fillColor;
  PVector offset;

  Particle(PVector pos, float size, int col) {
    this.basePos = pos.copy();
    this.size = size;
    this.fillColor = col;
    this.offset = new PVector(0, 0, 0);
  }

  void update() {
    // On utilise sin pour une oscillation et noise pour du mouvement
    float flickerY = sin(frameCount * 0.1 + basePos.x + basePos.z) * 2;

    offset.x = (noise(basePos.x, frameCount * 0.05f) - 0.5f) * 4;
    offset.z = (noise(basePos.z, frameCount * 0.05f) - 0.5f) * 4;
    offset.y = flickerY + (noise(basePos.y, frameCount * 0.05f) - 0.5f) * 2+20;
  }

  void display() {
    pushMatrix();
    translate(basePos.x + offset.x, basePos.y + offset.y, basePos.z + offset.z);
    noStroke();
    fill(fillColor);
    sphere(size);
    popMatrix();
  }
}

// ========== Genere des particules de flammezs pour la torche ================
void genererFlammeParticules() {
  // Génération des particules de la flamme
  flameParticles = new ArrayList<Particle>();
  int numParticles = 800;  // Même nombre qu'avant
  for (int i = 0; i < numParticles; i++) {
    // Taille aléatoire pour la particule (entre 1 et 3)
    float particleSize = random(1, 3);
    // Position aléatoire dans la zone de la flamme (tu peux adapter les plages si besoin)
    float x = random(-8, 8);
    float y = random(120, 180);
    float z = random(-8, 8);
    PVector pos = new PVector(x, y, z);

    // Couleur de la particule : orange vif avec opacité variable
    int r = 255;
    int g = (int)random(120, 200);
    int b = 0;
    int a = (int)random(150, 255);
    int col = color(r, g, b, a);

    flameParticles.add(new Particle(pos, particleSize, col));
  }
}
