// Class Mesh
class Mesh
{
  int tipo; 
  PVector p[][]; // Vertex array
  PVector f[][]; // Force matrix
  PVector a[][]; // Acceleration matrix
  PVector v[][]; // Speed matrix
  
  int sizeX, sizeY; // Mesh dimensions
  
  float directDist; // Length between direct vertices at rest
  float obliqueDist; // Length between diagonal vertices at rest
  
  float k; // Spring constant between vertices
  float m_Damping; // Spring damping
  
  Mesh (int t, int x, int y)
  {
    tipo = t;
    sizeX = x;
    sizeY = y;
    
    p = new PVector[sizeX][sizeY];
    f = new PVector[sizeX][sizeY];
    a = new PVector[sizeX][sizeY];
    v = new PVector[sizeX][sizeY];
    
    directDist = 3;
    obliqueDist = sqrt(2 * (directDist * directDist));
    
    // Elasticity and damping are adjusted depending on the type of mesh
    switch (tipo)
    {
      case 1: 
        k = 400;
        m_Damping = 3;
      break;
      
      case 2: 
        k = 150;
        m_Damping = 2;
      break;
      
      case 3: 
        k = 300;
        m_Damping = 2;
      break;
    }
    
    for (int i = 0; i < sizeX; i++)
    {
      for (int j = 0; j < sizeY; j++)
      {
        p[i][j] = new PVector (i * directDist, j * directDist,0);
        f[i][j] = new PVector (0,0,0);
        a[i][j] = new PVector (0,0,0);
        v[i][j] = new PVector (0,0,0);
      }
    }
  }

  void display(color c)
  {
    fill(c);
    for(int i = 0; i < sizeX-1; i++) {
      
      beginShape(QUAD_STRIP);
      
      for(int j = 0; j < sizeY; j++) {
        PVector p1 = p[i][j];
        PVector p2 = p[i+1][j];
        vertex(p1.x, p1.y, p1.z);
        vertex(p2.x, p2.y, p2.z);
      }
      
      endShape();
    }
  }
  
  // Update the positions and speeds are updated
  void update()
  {
    updateForces();
    
    // Updating using simpletic euler
    for (int i = 0; i < sizeX; i++)
    {
      for (int j = 0; j < sizeY; j++)
      {
        a[i][j].add(f[i][j].x * SIM_STEP, f[i][j].y * SIM_STEP, f[i][j].z * SIM_STEP);
        v[i][j].add(a[i][j].x * SIM_STEP, a[i][j].y * SIM_STEP, a[i][j].z * SIM_STEP);
        p[i][j].add(v[i][j].x * SIM_STEP, v[i][j].y * SIM_STEP, v[i][j].z * SIM_STEP);
        
        if((i==0 &&  j==0) || (i==0 && j== sizeY-1))
        {
          f[i][j].set(0,0,0);
          v[i][j].set(0,0,0);
          p[i][j].set(i * directDist, j * directDist, 0);
        }
        a[i][j].mult(0);
      }
    }
  }

  void updateForces()
  {
    PVector v_Damping = new PVector (0,0,0);
    
    for (int i = 0; i<sizeX; i++)
    {
      for (int j = 0; j < sizeY; j++)
      {
        f[i][j].set(0,0,0);
        PVector vertexPos = p[i][j];
        
        // Gravity force
        f[i][j].set(g.x,g.y,g.z);
        
        // Wind force
        PVector fViento = getFwind(vertexPos, i, j);
        f[i][j] = PVector.add(f[i][j], fViento);
        
        switch(tipo)
        {
          case STRUCTURED:
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i-1, j, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i+1, j, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j-1, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j+1, directDist, k));
          break;
          
          case BEND:
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i-1, j, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i+1, j, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j-1, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j+1, directDist, k));
            
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i-2, j, directDist * 2, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i+2, j, directDist * 2, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j-2, directDist * 2, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j+2, directDist * 2, k));
          break;
          
          case SHEAR:
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i-1, j, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i+1, j, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j-1, directDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i, j+1, directDist, k));
            
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i-1, j-1, obliqueDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i-1, j+1, obliqueDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i+1, j-1, obliqueDist, k));
            f[i][j] = PVector.add(f[i][j], getForce(vertexPos, i+1, j+1, obliqueDist, k));
          break;
        }
        
        // Damping force = -v * kr
        v_Damping.set(v[i][j].x, v[i][j].y, v[i][j].z);
        v_Damping.mult(-m_Damping);
        
        f[i][j] = PVector.add(f[i][j], v_Damping); 
      }
    }
  }
  
  PVector getFwind(PVector v, int i, int j)
  {
    PVector Fw = new PVector(0,0,0);  // Wind force
    
    // Normal
    PVector n1 = new PVector(0,0,0);
    PVector n2 = new PVector(0,0,0);
    PVector n3 = new PVector(0,0,0);
    PVector n4 = new PVector(0,0,0);
    PVector n = new PVector(0,0,0);
    
    
    float projection;
    
    n1 = getNormal(v, i-1, j, i, j-1);
    n2 = getNormal(v, i-1, j, i, j+1);
    n3 = getNormal(v, i, j+1, i+1, j);
    n4 = getNormal(v, i+1, j, i, j-1);
    
    int cont = 0;
    
    if (n1.mag() >0)
    cont++;
    
    if (n2.mag() >0)
    cont++;
    
    if (n3.mag() >0)
    cont++;
    
    if (n4.mag() >0)
    cont++;
    
    n1 = PVector.add(n1, n2);
    n3 = PVector.add(n3, n4);
    n = PVector.add(n1, n3);
    
    // Normalization of the vector indicating the normal
    n.div(cont);
    n.normalize();
    
    // Projection of the normal on the wind
    projection = n.dot(wind);
    
    // The force of the wind is the projection of the normal on the wind
    Fw.set(abs(projection * wind.x), (projection * wind.y), (projection * wind.z));
    
    return Fw;
  }
  
  PVector getNormal (PVector v, int a, int b, int c, int d)
  {
    PVector n = new PVector (0,0,0);
    
    if (a >= 0 && a <= sizeX-1 && b>=0 && b<=sizeY-1 && c>=0 && c<=sizeX-1 && d>=0 && d<= sizeY-1)
    {
      PVector v1 = PVector.sub(p[a][b], v);
      PVector v2 = PVector.sub(p[c][d], v);
      n = v1.cross(v2);
    }
    
    return n;
  }

  PVector getForce(PVector VertexPos, int i, int j,  float m_Distance, float k){

    PVector force = new PVector(0.0, 0.0, 0.0);
    PVector distancia = new PVector(0.0, 0.0, 0.0);
    float elongacion = 0.0;
    
    if (i >= 0 && i < sizeX && j >= 0 && j < sizeY) 
    {
      distancia = PVector.sub(VertexPos, p[i][j]); 
      
      elongacion = distancia.mag() - m_Distance;
      
      distancia.normalize();
      
      force = PVector.mult(distancia, -k * elongacion);
    }
    else
    {
      force.set(0.0, 0.0, 0.0);
    }
    
    return force;
  }
}
