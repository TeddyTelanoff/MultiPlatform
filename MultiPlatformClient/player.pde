class Player {
  int playerId;

  PVector position;
  float health = 20;
  boolean facingLeft;

  final PVector gravity;
  PVector
    acceleration, 
    desPos;
  boolean
    myPlayer, 
    isCrouching;
  float
    smoothness = 0.69, 
    jumpHeight = 20, 
    speed = 5;
  final int
    crouchHeight, 
    normHeight;
  int
    _height = 100, 
    _width = 50, 
    _rwidth = 80, 
    highestY;
  float
    shotDamage = 3, 
    reloadMillis = 500, 
    pastMillis, 
    millisSinceReload;

  Player(boolean _myPlayer) {
    myPlayer = _myPlayer;
    highestY = height - _height;
    crouchHeight = 50;
    normHeight = 100;

    position = new PVector(625, 400);
    gravity = new PVector(0, 1);
    acceleration = new PVector(0, 0);
    desPos = new PVector();

    pastMillis = millis();
  }

  void show() {
    if (facingLeft) image(playerSprites[playerId][0], position.x - _width/2, position.y, _rwidth, _height);
    else image(playerSprites[playerId][1], position.x, position.y, _rwidth, _height);

    noFill();
    if (myPlayer)
      stroke(0, 255, 0);
    else
      stroke(255, 0, 0);

    rect(position.x, position.y, _width, _height);
  }

  void update() {
    checkShot();
    highestY = height - _height;

    millisSinceReload = millis() - pastMillis;

    if (isA) {
      position.x-= speed;
      facingLeft = true;
    }
    if (isD) {
      position.x+= speed;
      facingLeft = false;
    }
    
    if (health <= 0 || position.y > highestY)
      die();

    if (isCrouching) {
      _height = crouchHeight;
    } else {
      _height = normHeight;
    }

    checkForPlatforms();

    acceleration.add(gravity);

    position.add(acceleration);
  }

  void checkForPlatforms() {
    for (int i = 0; i < platforms.size(); i++) {
      Platform _plat = platforms.get(i);

      if (position.y + _height >= _plat.position.y &&
        position.y + _height < _plat.position.y + _plat.h/2 &&
        position.x < _plat.position.x + _plat.w &&
        position.x + _width > _plat.position.x) {
        acceleration.y = 0;
        if (isJump)jump();
        position.y = _plat.position.y - _height;
      } else if (position.y + _height > _plat.position.y &&
        position.y < _plat.position.y + _plat.h) {
        if (position.x + _width > _plat.position.x &&
          position.x < _plat.position.x) {
          position.x = _plat.position.x - _width;
        } else {
          if (position.x + _width > _plat.position.x + _plat.w &&
            position.x < _plat.position.x + _plat.w) {
            position.x = _plat.position.x + _plat.w;
          }
        }
      }
    }
  }

  void jump() {
    acceleration.add(new PVector(0, -jumpHeight));
  }

  void setPos(float x, float y) {
    position = new PVector(x, y);
  }

  void setPos(PVector newPos) {
    position = newPos;
  }

  void setId(int value) {
    playerId = value;
  }

  void crouchChange() {
  }

  void checkShot() {
    if (millisSinceReload >= reloadMillis) {
      if (isLeft) {
        facingLeft = true;
        shots.add(new Shot(id, int(shotDamage), facingLeft, int(position.x), int(position.y + _height/4)));
        sendShot(true);
        pastMillis = millis();
      } else if (isRight) {
        facingLeft = false;
        shots.add(new Shot(id, int(shotDamage), facingLeft, int(position.x), int(position.y + _height/4)));
        sendShot(false);
        pastMillis = millis();
      }
    }
  }

  void sendShot(boolean facingLeft) {
    c.write("shot " + id + " " + int(shotDamage) + " " + facingLeft + " " + int(position.x) + " " + int(position.y + _height/4) + "\n");
  }

  void die() {
    println("dead");
    exit();
  }
}

boolean isA, isD, isJump, isLeft, isRight; 

void keyPressed() {
  setMove(keyCode, true);
}

void keyReleased() {
  setMove(keyCode, false);
}

boolean setMove(int k, boolean b) {
  switch (k) {
  case LEFT:
    return isLeft = b;

  case RIGHT:
    return isRight = b;

  case 65:
    return isA = b;

  case 68:
    return isD = b;

  case 32:
    return isJump = b;

  case 87:
    return isJump = b;
  case 16:
    return player.isCrouching = b;

  default:
    //println(keyCode);
    return b;
  }
}
