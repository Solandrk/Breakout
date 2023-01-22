private static final int HEIGHT = 700;
private static final int WIDTH = 400;

Environment env;
boolean gameCondition = true;

void setup(){
  background(0);
  size(400,650);
  env = new Environment();
}
void draw(){ 
  if(gameCondition){
      env.ball.move();
  }else {
    showMenu("");
  }
}

void showMenu(String condition){
  fill(255);
  int xC = WIDTH/2-150;
  int yC = HEIGHT/2-200;
  rect(xC ,yC,300,400);
  MenuOption option1 = new MenuOption("Continue",new float[]{xC+100,yC+50},null);
  option1.drawOption();
   MenuOption option2 = new MenuOption("Save Game",new float[]{xC+90,yC+90},null);
  option2.drawOption();
  MenuOption option3 = new MenuOption("Restart",new float[]{xC+110,yC+130},null);
  option3.drawOption();
     MenuOption option4 = new MenuOption("Exit",new float[]{xC+125,yC+170},null);
  option4.drawOption();
}

interface MOptionI {
  void onPressed();
}

class MenuOption {
  private float[] coordinate; 
  private String title ; 
  MOptionI optionI;
  
  public MenuOption(String title,float[] coordinate,MOptionI optionI){
    this.optionI = optionI;
    this.title = title;
    this.coordinate = coordinate;
    
  }
  public void pointerCollision(){
    if(mouseY < coordinate[1] && mouseY > coordinate[1] +10 && 
      mouseX < coordinate[0] && mouseX > coordinate[1]){
        optionI.onPressed();
    }
  }
  public void drawOption(){
    fill(0, 408, 612, 204);
    textSize(24);
    text(title, coordinate[0], coordinate[1]); 
  }
  
}

void keyPressed(){
  if(gameCondition == false)
    return ;
  if(key == CODED)
  {
   if(keyCode == RIGHT)
   {
     env.slider.moveRight();
     env.reflash();
   }else if(keyCode == LEFT )
   {
    env.slider.moveLeft();
    env.reflash();
   }
  }
  
}

class Slider{
  
  public float xAxis;
  public float yAxis;
  public static final int WIDTH = 80;
  public static final int HEIGHT = 10;
  
  public int[] slideColor =new int[]{255,255,255};
 
  public Slider(){
   this.xAxis = 200-Slider.WIDTH/2;
   this.yAxis = 600;
  }
  public void drawSlider(){
    fill(slideColor[0],slideColor[1],slideColor[2]);
   
    rect(xAxis,yAxis,Slider.WIDTH,Slider.HEIGHT);
  } 
  public void moveRight(){
    if(xAxis+WIDTH < 400)
      xAxis += 20;
  }
  public void moveLeft (){
    if(xAxis > 0 )
    xAxis-=20;
  }
  public boolean collision(float[] coordinate)
  {
    if(coordinate[0] > xAxis &&  coordinate[0] <= xAxis+WIDTH && coordinate[1] >= yAxis && coordinate[1] <= yAxis +HEIGHT)
    {
     return true; 
    }
    return false;
  }
  public float[] collisionDetail(float[] coordinate)
  {
    if(collision(coordinate))
    {
      return new float[]{coordinate[0] - (xAxis+WIDTH/2) ,yAxis-coordinate[1]};
    }
    return null;
  }
}

class Ball
{
  private float[] coordinate = {190,380}; 
  private int size = 20;
  private float xMove = 0; 
  private int yMove = 5;
  
  public Ball(){
  }
  
  public void drawBall(){
     circle(coordinate[0],coordinate[1],size);  
  }
  
  public void move(){
     collision();
     coordinate[0]+= xMove;
     coordinate[1] += yMove;
     env.reflash();
  }
  
  private boolean wallCollision()
  {
    if(coordinate[0] >400 || coordinate[0] <=0)
    {
      xMove *=-1;
      return true;
    }
    if(coordinate[1] <=0){
      yMove*=-1;
      return true;  
    }else if (coordinate[1] >= HEIGHT){
      gameCondition = false;
    }
   return false; 
  }
  
  private boolean collision(){
    if(env.slider.collision(coordinate)){
      float[] detail = env.slider.collisionDetail(coordinate);
      float xL = detail[0]/20;        
      if(abs(detail[0]) <=8){
        xMove = 0;
      }else if(xMove == 0){
        xMove = xL;
      }else
        xMove *=abs(xL);
      yMove *=-1;
      return true;
    }
    if(wallCollision())
      return true;
    
    if(env.cBlockCollision(coordinate)){
      yMove *=-1;
      return true;
    }
    
    return false;
  }
  
}

class Block {
  private float[] coordinate;
  public static final int WIDTH = 40;
  public static final int HEIGHT = 15;
  private int resistance = 0; 
  private Item item; 
  
  public int[] blockColor =new int[]{255,100,0};
  
  public Block(float[] coordinate,int resistance){
   this.coordinate = coordinate; 
   this.resistance = resistance;
   int x = floor(random(10));
   System.out.println("fasdfafasdfasdf");
   if( x== 1)
   {
     item = new Item(coordinate,(int)random(1));
     System.out.println("Item in : Width = "+coordinate[0] + " | Height = "+coordinate[1] );
   }
  }
  public Block(float x,float y, int resistance){
   this.coordinate = new float[]{x,y}; 
   this.resistance = resistance;
   int rItem = floor(random(10));
   if( rItem== 1)
   {
     item = new Item(coordinate,(int)random(2));
     System.out.println("Item in : Width = "+coordinate[0] + " | Height = "+coordinate[1] );
   }
  }
  public void drawBlock(){
    if(resistance > 0){
    fill(blockColor[0],blockColor[1],blockColor[2]);
    rect(coordinate[0],coordinate[1],WIDTH,HEIGHT);
    }
  }
  public boolean collision(float[] coordinate)
  {
    if(coordinate[0] <= this.coordinate[0]+WIDTH && coordinate[0] >= this.coordinate[0] && 
       coordinate[1] <= this.coordinate[1]+HEIGHT && coordinate[1] >= this.coordinate[1] && resistance > 0){
      resistance--;
      blockColor[0] -= 100;
      if(resistance == 0)
      {
        if(item != null){
          env.items.add(item);
          System.out.println("Item Released");
        }
      }
      return true;
    }
    return false;
  }
}

class Item {
  
  private ItemType data; 
  private float[] coordinate;
  public Item(float[] coordinate , int type){
    this.coordinate = coordinate;
    switch(type)
    {
       case 0: data = ItemType.Increase; break;
       case 1 : data = ItemType.SpeedUp;break;
    }
  }
  public void drawItem()
  {
   rect(coordinate[0],coordinate[1],25,25); 
  }
  public void fall(){
    if(coordinate[1] < HEIGHT){
      coordinate[1] += 2;
    }
  }

}

  enum ItemType {
    Increase,SpeedUp,
  }
  
class Environment {
  
  ArrayList<Block> blocks = new ArrayList();
  ArrayList<Item> items = new ArrayList();
  Ball ball; 
  Slider slider ; 
  
  public Environment(){
    slider = new Slider();
    ball = new Ball();
     for(int j = 0 ; j<4;j++){
      for(int i = 0 ; i< WIDTH/Block.WIDTH; i++){
         Block block = new Block(i*(Block.WIDTH+2)+2,j*(Block.HEIGHT+1)+100,1+(int)random(3));
         blocks.add(block); 
      }  
  } 
  drawEnvironment();
  }
  public void reflash(){
   background(0);
   drawEnvironment();
  }
  
  public void drawEnvironment(){
    slider.drawSlider();
    ball.drawBall();
      for(int i = 0 ; i< blocks.size(); i++){
         blocks.get(i).drawBlock();
      }
   for(int j = 0 ; j<items.size();j++)
   {
     items.get(j).fall();
     items.get(j).drawItem();
   }
  }
  private boolean cBlockCollision(float[] coordinate){
    for(int i = 0 ; i< blocks.size(); i++){
         if(blocks.get(i).collision(coordinate))
           return true;
    }
  return false;
  }
}
