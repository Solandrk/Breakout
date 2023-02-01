private static final int HEIGHT = 700;
private static final int WIDTH = 400;

Environment env;
boolean gameCondition = true;
boolean gameover = false;
boolean pause = false;

void setup(){
  background(0);
  size(400,650);
  env = new Environment();
}
void draw(){ 
  if(gameCondition){
      env.ball.move();
  }else {
    if(gameover)
     env.menu.showGameOverMenu();
    if(pause)
      env.menu.showPauseMenu();
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
 
void mousePressed(){ 
  if(!gameCondition)
    env.menu.checkClicked();
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
      gameover = true;
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
    
    int[] result = env.cBlockCollision(coordinate);
    if(result != null){
      yMove *=result[1];
      xMove *=result[0];
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
  public int[] collision(float[] coordinate)
  {

    int zarib[] = null;
    if(coordinate[0] <= this.coordinate[0]+WIDTH && coordinate[0] >= this.coordinate[0] && 
       coordinate[1] <= this.coordinate[1]+HEIGHT && coordinate[1] >= this.coordinate[1] && resistance > 0){
         
             
      resistance--;
      blockColor[0] -= 50;
      if(resistance == 0)
      {
        if(item != null){
          env.items.add(item);
          System.out.println("Item Released");
        }
      }
   
         
       zarib = new int[]{1,1};
       if(coordinate[0] >= this.coordinate[0]+WIDTH-3  || coordinate[0] <= this.coordinate[0]+3){
          zarib[0] = -1;
       }
       if(coordinate[1] >= this.coordinate[1]+HEIGHT-3  || coordinate[1] <= this.coordinate[1]+3){
          zarib[1] = -1;
       }
    }
      return zarib;
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
  Slider slider;
  Menu menu = new Menu(); 
  
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
  private int[] cBlockCollision(float[] coordinate){
    for(int i = 0 ; i< blocks.size(); i++){
       int[] result = blocks.get(i).collision(coordinate);
         if(result != null)
           return result;
    }
  return null;
  }
}

interface MOptionI {
  void onClick();
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
   
    if(mouseY < coordinate[1] && mouseY > coordinate[1] -30 && 
       mouseX > coordinate[0] && mouseX < coordinate[0]+80){
         System.out.println(mouseX + " | "+coordinate[0]  + "\n"+mouseY+" | "+coordinate[1]);
        optionI.onClick();
    }
  }
  public void drawOption(){
    fill(0, 408, 612, 204);
    textSize(24);
    text(title, coordinate[0], coordinate[1]); 
  }
  
}

class Menu{
  
  ArrayList<MenuOption> pauseOptions = new ArrayList();
  ArrayList<MenuOption> startOptions = new ArrayList();
  ArrayList<MenuOption> gameoverOptions = new ArrayList();
  
  private static final int MENU_WIDTH = 300;
  private static final int MENU_HEIGHT = 400;
  private static final int SpaceBetween = 40;
  
  private int xC = WIDTH/2 -150;
  private int yC = HEIGHT/2 -200;
  
  public Menu(){
      pauseOptions.add(new MenuOption("Continue",new float[]{xC+100,yC+50},new MOptionI(){
        @Override
        public void onClick(){
            gameCondition = true;
            env.reflash();
        }
      }));
      pauseOptions.add(new MenuOption("Save Game",new float[]{xC+90,yC+90},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
      pauseOptions.add( new MenuOption("Restart",new float[]{xC+110,yC+130},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
      pauseOptions.add(new MenuOption("Exit",new float[]{xC+125,yC+170},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
      
      /** Game Over Menu */
       gameoverOptions.add(new MenuOption("New Game",new float[]{xC+90,yC+SpaceBetween},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
       gameoverOptions.add(new MenuOption("Load Game",new float[]{xC+88,yC+2*SpaceBetween},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
       gameoverOptions.add(new MenuOption("Main Menu",new float[]{xC+90,yC+3*SpaceBetween},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
       gameoverOptions.add(new MenuOption("Exit",new float[]{xC+125,yC+4*SpaceBetween},new MOptionI(){
        @Override
        public void onClick(){
            
        }
      }));
      
  }
  private void drawBackground(){
    fill(255);
   rect(xC ,yC,300,400,25); 
  }
  public void showGameOverMenu(){
    drawBackground();
      for(int i = 0 ; i<gameoverOptions.size() ;i++){
        gameoverOptions.get(i).drawOption();
      }
  }
  
  public void startMenu(){
  
  }
  
  public void checkClicked(){
     if(pause)
       for(int i = 0 ; i<pauseOptions.size() ;i++){
          pauseOptions.get(i).pointerCollision();
        }
     if(gameover)
        for(int i = 0 ; i<gameoverOptions.size() ;i++){
          gameoverOptions.get(i).pointerCollision();
        }
  }
  
  public void showPauseMenu(){
    drawBackground();
      for(int i = 0 ; i<pauseOptions.size() ;i++){
        pauseOptions.get(i).drawOption();
      }
    }
  }
