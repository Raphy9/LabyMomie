
/**
 * Crée l'ensemble de la torche sous forme d'un PShape GROUP :
 *  - Manche (profil révolutionné)
 *  - Collier autour du manche (profil révolutionné)
 *  - Flamme (contour 2D extrudé)
 */
PShape createTorch3D() {
  PShape torch = createShape(GROUP);
  
  // 1) Manche
  // Le profil est un tableau de PVector (x, y) en vue de côté
  // On le "révolutionne" autour de l'axe Y, avec revolveDetail segments
  PVector[] handleProfile = {
    new PVector(  0,  0 ),   // Base (rayon = 0, y=0)
    new PVector(  5,  0 ),   // Léger rayon au bas du manche
    new PVector(  7, 30 ),   // Manche qui s’élargit doucement
    new PVector(  6, 60 ),   // Rétrécit un peu plus haut
    new PVector(  5, 90 ),   // Partie quasi cylindrique
    new PVector(  4, 120 )   // Haut du manche
  };
  PShape handle = revolveShape(handleProfile, 32);
  handle.setFill(color(90, 50, 0));  // Couleur bois/marron
  handle.setStroke(false);
  torch.addChild(handle);

  // 2) Collier (anneau) près du sommet
  // On crée un petit anneau en forme de “bague” au-dessus du manche
  // Même principe : on décrit un petit profil évasé et on le “révolutionne”
  PVector[] ringProfile = {
    new PVector(4, 120),  // Doit coller à la fin du manche
    new PVector(6, 125),  // Légèrement plus large
    new PVector(7, 135),  // Montée de l’anneau
    new PVector(6, 140),  // Redescente
    new PVector(4, 145)   // Retour vers la forme du manche
  };
  PShape ring = revolveShape(ringProfile, 32);
  ring.setFill(color(70, 35, 0));
  ring.setStroke(false);
  torch.addChild(ring);

  // 3) Flamme (extrusion)
  // On la place juste au-dessus de l’anneau (disons y ~145)
  // On définit un contour en 2D, puis on l’extrude sur +/- 5 en Z
  PShape flame = createFlamme3D();
  torch.addChild(flame);

  return torch;
}

/**
 * Génère un PShape 3D en “révolutionnant” un profil 2D autour de l’axe Y.
 *  - profile : tableau de PVector (x, y) décrivant la silhouette en coupe
 *  - revolveDetail : nombre de segments de révolution (plus c’est grand, plus c’est lisse)
 */
PShape revolveShape(PVector[] profile, int revolveDetail) {
  PShape shape3D = createShape();
  shape3D.beginShape(QUADS);
  shape3D.noStroke();
  
  // On balaie revolveDetail + 1 pour fermer la forme
  for (int i = 0; i < revolveDetail; i++) {
    float theta1 = TWO_PI * i / revolveDetail;
    float theta2 = TWO_PI * (i+1) / revolveDetail;
    
    // On calcule cos/sin pour deux positions d'angle
    float cos1 = cos(theta1), sin1 = sin(theta1);
    float cos2 = cos(theta2), sin2 = sin(theta2);

    // Pour chaque segment vertical du profil
    for (int j = 0; j < profile.length - 1; j++) {
      PVector p1 = profile[j];
      PVector p2 = profile[j+1];

      // Coordonnées en (x, y, z) lorsqu’on tourne autour de Y
      // - x dépend de p.x * cos(...) et de p.x * sin(...)
      // - y reste p.y (la hauteur)
      // - z dépend de p.x * sin(...) et cos(...), etc.

      // 4 points du QUAD
      float x1 = p1.x*cos1; 
      float z1 = -p1.x*sin1; 
      float y1 = p1.y;
      
      float x2 = p1.x*cos2; 
      float z2 = -p1.x*sin2; 
      float y2 = p1.y;
      
      float x3 = p2.x*cos2; 
      float z3 = -p2.x*sin2; 
      float y3 = p2.y;
      
      float x4 = p2.x*cos1; 
      float z4 = -p2.x*sin1; 
      float y4 = p2.y;

      // Ajout du quad
      shape3D.vertex(x1, y1, z1);
      shape3D.vertex(x2, y2, z2);
      shape3D.vertex(x3, y3, z3);
      shape3D.vertex(x4, y4, z4);
    }
  }
  
  shape3D.endShape(CLOSE);
  return shape3D;
}

/**
 * Crée une "flamme" en remplaçant l'extrusion par un ensemble de particules de feu.
 * La fonction génère un PShape GROUP contenant plusieurs petites sphères positionnées
 * aléatoirement dans la zone de la flamme (entre y ~150 et y ~220).
 */
PShape createFlamme3D() {
  // Création du groupe qui contiendra les particules
  PShape flameGroup = createShape(GROUP);
  
  // Nombre de particules que l'on souhaite générer
  int numParticles = 800;
  
  // Plage de variation pour la position (en x, y, z)
  // Ici, la flamme sera située entre y = 150 et y = 220,
  // avec x variant approximativement de -20 à 20 et z de -4 à 4.
  for (int i = 0; i < numParticles; i++) {
    // Taille aléatoire pour la particule (pour varier l'aspect du feu)
    float particleSize = random(1, 3);
    // Création d'une sphère pour représenter la particule
    PShape particle = createShape(SPHERE, particleSize);
    
    // Couleur de base : un orange vif, avec une légère variation aléatoire dans le canal vert
    // On ajoute une opacité (alpha) aléatoire pour donner un effet plus "vivant"
    int r = 255;
    int g = (int)random(120, 200);
    int b = 0;
    int a = (int)random(150, 255);
    particle.setFill(color(r, g, b, a));
    particle.setStroke(false);
    
    // Position aléatoire dans la zone de la flamme
    float x = random(-8, 8);
    float y = random(120, 180);
    float z = random(-8, 8);
    
    // Appliquer une translation pour positionner la particule
    particle.translate(x, y, z);
    
    // Ajouter la particule au groupe
    flameGroup.addChild(particle);
  }
  
  return flameGroup;
}

   
