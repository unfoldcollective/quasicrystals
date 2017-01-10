/*
  "Quasicrystals"
  Points are added by the user drawing on the screen, in principle forming a line.
  But these points are not still, they follow a subtle movement pattern --each point slowly moves away from its nearest neighbour.
  Of course, as the points move, the nearest neighbour of each point will not always be the same, so the result is not just a wild expansion.
  The system does expand, but at the same time a relatively regular, but always "shaking" pattern becomes gradually visible at the same time.
  I noticed that sometimes, a group of points can get "trapped" forming a rather regular mesh in a very small region and seem to stop expanding (like a black hole?)
  I draw a line from each point to its nearest neighbour. The colors come in cycles from the outside to the inside.
  You can press + and - to play with the zoom, and the arrows to move the viewpoint around. Space to stop moving the viewpoint. 's' to take a screenshot.
*/
int maxPoints = 1000; // Maximum number of total points
float speed = 0.008; // How fast they will move
float zoomSpeed = 0;
PVector cameraSpeed = new PVector();
color[] palette = {#FFFFFF, #FFFFFF, #FFFFFF, #FFFFFF};
color bgColor = 0;
ArrayList<PVector> points = new ArrayList();

int NUM_TOUCH_POINTS_X = 5;
int NUM_TOUCH_POINTS_Y = 2;
float targetX, targetY, cursorX, cursorY;
float easing = 0.02;
float dThreshold = 5;
float noiseScale = 1;
float noiseMultiplier = 10;
Boolean shouldDraw = false;

void setup()
{
  //fullScreen();
  size(450, 850);
  background(0);
  fill(bgColor, 31);
  
  noCursor();
  
  targetX = width * 0.5;
  targetY = height * 0.1;
  cursorX = width * 0.5;
  cursorY = height * 0.9;
}
void draw()
{
  float dx = targetX - cursorX;
  cursorX += dx * easing;
  float dy = targetY - cursorY;
  cursorY += dy * easing;
  
  if (abs(dx) > dThreshold || abs(dy) > dThreshold){
    addPoint();
  }
  
  int nPoints = points.size();
  noStroke();
  rect(0, 0, width, height); // Clear the screen but with some degree of transparency
  for(int i = 0; i < nPoints; i++)
  {
    PVector currentPoint = points.get(i);
    PVector closestPoint = null;
    float distanceToClosestPoint = -1;
    for(int j = 0; j < nPoints; j++)
    {
      if(i != j) {
        PVector anotherPoint = points.get(j);
        float distance = currentPoint.dist(anotherPoint);
        if(distanceToClosestPoint == -1 || distance < distanceToClosestPoint)
        {
          distanceToClosestPoint = distance;
          closestPoint = anotherPoint;
        }
      }
    }
    if(closestPoint != null)
    {
      int colorIndex = Math.max(0, Math.round(map(distanceToClosestPoint, 25, 60, 0, 3)))%4;
      strokeWeight(Math.min(1, 10/distanceToClosestPoint));
      color chosenColor = palette[colorIndex];
      stroke(chosenColor);
      line(currentPoint.x, currentPoint.y, closestPoint.x, closestPoint.y);
      PVector distance = new PVector(closestPoint.x - currentPoint.x, closestPoint.y - currentPoint.y);
      PVector displacement = new PVector(- distance.x * speed, - distance.y * speed); // Move points 
      displacement.x += zoomSpeed * (currentPoint.x - width/2);
      displacement.y += zoomSpeed * (currentPoint.y - height/2);
      displacement.add(cameraSpeed);
      //displacement.add(getDisplacementNoise());
      points.get(i).add(displacement);
    }
  }
}
PVector getDisplacementNoise(float noiseScalar) {
  PVector noise = new PVector();
  noise.x = noiseMultiplier * noise(cursorX * noiseScalar);
  noise.y = noiseMultiplier * noise(cursorY * noiseScalar);
  return noise;
}
void addPoint()
{
  if( ! ( points.size() < maxPoints) ) {
    points.remove(0);
  }
  PVector point = new PVector(cursorX, cursorY).add(getDisplacementNoise(noiseScale));
  if(shouldDraw){
    points.add(point); 
  }
}
void addPointAt(float x, float y)
{
  if( ! ( points.size() < maxPoints) ) {
    points.remove(0);
  }
  PVector point = new PVector(x, y);
  if(shouldDraw){
    points.add(point); 
  }
}
void moveTargetX(float n) {
  float maxScaleX = NUM_TOUCH_POINTS_X + 1;
  float ratioX = n / maxScaleX;
  targetX = ratioX * width;
}
void moveTargetY(float n) {
  float maxScaleY = NUM_TOUCH_POINTS_Y + 1;
  float ratioY = n / maxScaleY;
  targetY = ratioY * height;
}
void moveCursorX(float n) {
  float maxScaleX = NUM_TOUCH_POINTS_X + 1;
  float ratioX = n / maxScaleX;
  cursorX = ratioX * width;
}
void moveCursorRatioX(float ratio) {
  cursorX = ratio * width;
}
void moveCursorY(float n) {
  float maxScaleY = NUM_TOUCH_POINTS_Y + 1;
  float ratioY = n / maxScaleY;
  cursorY = ratioY * height;
}
void moveCursorRatioY(float ratio) {
  cursorY = ratio * height;
}
void dropCursor(float n) {
  shouldDraw = true;
  moveCursorRatioX(n/(NUM_TOUCH_POINTS_X+1));
  moveCursorRatioY(0.9);
  moveTargetX(n);
  // move target with noise
  PVector noise = getDisplacementNoise(10);
  targetX += noise.x;
  targetY += noise.y;
  drawPointsAroundCursor(8, 20);
}
void drawPointsAroundCursor(int numPoints, float rad) {
  ellipseMode(RADIUS);
  ellipse(cursorX, cursorY, rad, rad);
  
  float angle=TWO_PI/(float)numPoints;
  for(int i=0;i<numPoints;i++)
  {
    addPointAt(cursorX + rad*sin(angle*i), cursorY + rad*cos(angle*i));
  }
}
void clearScreen() {
  background(bgColor);
  points.clear();
}
void keyPressed() {
  switch(key) {
    case'c':
    // Clear the screen
      clearScreen();
      break;
    case '-':
      zoomSpeed -= 0.002;
      break;
    case '+':
      zoomSpeed += 0.002;
      break;
    case ' ':
      zoomSpeed = 0;
      cameraSpeed.x = 0;
      cameraSpeed.y = 0;
      break;
    case 's':
      saveFrame();
      break;
    // horizontal
    case '1':
      dropCursor(1);
      break;
    case '2':
      dropCursor(2);
      break;
    case '3':
      dropCursor(3);
      break;
    case '4':
      dropCursor(4);
      break;
    case '5':
      dropCursor(5);
      break;
    // vertical
    case 'q':
      moveTargetY(1);
      break;
    case 'a':
      moveTargetY(2);
      break;
  }
  switch(keyCode) {
    case UP:
      cameraSpeed.y += 0.2;
      break;
    case DOWN:
      cameraSpeed.y -= 0.2;
      break;
    case LEFT:
      cameraSpeed.x += 0.2;
      break;
    case RIGHT:
      cameraSpeed.x -= 0.2;
      break;
  }
}