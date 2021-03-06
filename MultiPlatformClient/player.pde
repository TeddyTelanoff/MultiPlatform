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
    isCrouching, 
    pCrouching, 
    onPlatform;
  float
    maxSpeed, 
    jumpHeight, 
    bounceHeight, 
    speed, 
    normSpeed, 
    crouchSpeed;
  int
    crouchHeight, 
    normHeight;
  int
    _height = 100, 
    _width = 50, 
    _rwidth = 80, 
    maxHeight, 
    highestY, 
    minX, 
    maxX, 
    framesSinceLastCrouch = 0;
  float
    shotDamage, 
    reloadMillis, 
    pastMillis, 
    millisSinceReload;

  Player(boolean myPlayer) {
    this.myPlayer = myPlayer;
    maxHeight = -height * 2;
    highestY = height * 2;
    minX = -width/2;
    maxX = int(width * 1.5);

    if (myPlayer) {
      maxSpeed = selCharacter.getFloat("max-speed");
      normSpeed = selCharacter.getFloat("normal-speed");
      crouchSpeed = selCharacter.getFloat("crouch-speed");

      crouchHeight = selCharacter.getInt("crouch-height");
      normHeight = selCharacter.getInt("normal-height");
      jumpHeight = selCharacter.getFloat("jump-height");
      bounceHeight = selCharacter.getFloat("bounce-height");

      shotDamage = selCharacter.getFloat("shot-damage");
      reloadMillis = selCharacter.getFloat("reload-speed");
    } else {
      //defaults
      maxSpeed = 50;
      normSpeed = 5;
      crouchSpeed = 1;

      crouchHeight = 50;
      normHeight = 100;
      jumpHeight = 20;
      bounceHeight = 5;

      shotDamage = 2;
      reloadMillis = 800;
    }

    position = new PVector(625, 400);
    gravity = new PVector(0, 1);
    acceleration = new PVector(0, 0);
    desPos = new PVector();

    pastMillis = millis();
  }

  void show() {
    updateHitbox();

    if (facingLeft) image(playerSprites[playerId][0], position.x - _width/2, position.y, _rwidth, _height);
    else image(playerSprites[playerId][1], position.x, position.y, _rwidth, _height);

    noFill();
    if (myPlayer)
      stroke(0, 255, 0);
    else
      stroke(255, 0, 0);

    rect(position.x, position.y, _width, _height);

    healthBar();
  }

  void updateHitbox() {
    if (isCrouching) {
      _height = crouchHeight;
      speed = crouchSpeed;
    } else {
      _height = normHeight;
      speed = normSpeed;
    }
  }

  void healthBar() {
    int healthBarWidth = (int) map(health, 0, 20, 0, _width);

    noStroke();
    fill(#ff0000);
    rect(position.x + healthBarWidth, position.y - 15, _width - healthBarWidth, 10);

    fill(#00ff00);
    rect(position.x, position.y - 15, healthBarWidth, 10);

    fill(#ff0000);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(health + " HP", position.x + _width/2, position.y - 25);
  }

  void update() {
    checkShot();

    if (myPlayer) {
      millisSinceReload = millis() - pastMillis;

      if (isA) {
        facingLeft = true;
        if (isCrouching) 
          for (int i = 0; i < platforms.size(); i++) 
            if (position.y + _height == platforms.get(i).position.y) {
              if (position.x + _width >= platforms.get(i).position.x && position.x - 1 + _width < platforms.get(i).position.x + crouchSpeed)
                position.x+= speed;
              break;
            }
        position.x-= speed;
      }
      if (isD) {
        facingLeft = false;
        if (isCrouching) 
          for (int i = 0; i < platforms.size(); i++) 
            if (position.y + _height == platforms.get(i).position.y) {
              if (position.x + 1 >= platforms.get(i).position.x + platforms.get(i).w && position.x < platforms.get(i).position.x + platforms.get(i).w + crouchSpeed)
                position.x-= speed;
              break;
            }
        position.x+= speed;
      }

      if (health <= 0)
        die();

      if (pCrouching == true && isCrouching == false) {
        unCrouch();
      } 
      if (pCrouching == false && isCrouching == true) {
        crouch();
      }

      acceleration.add(gravity);
      acceleration.limit(maxSpeed);

      for (int i = 0; i < acceleration.y; i++)
        checkForPlatforms(position.x, position.y + i);

      position.add(acceleration);
      position.x = constrain(position.x, minX, maxX);
      position.y = constrain(position.y, maxHeight, highestY + 1);

      pCrouching = isCrouching;

      if (framesSinceLastCrouch < 10) framesSinceLastCrouch++;
    }
  }

  void checkForPlatforms(float x, float y) {
    PVector position = new PVector(x, y);

    onPlatform = false;
    for (int i = 0; i < platforms.size(); i++) {
      Platform _plat = platforms.get(i);

      if (position.y + _height >= _plat.position.y &&
        position.y + _height < _plat.position.y + _plat.h/2 &&
        position.x < _plat.position.x + _plat.w &&
        position.x + _width > _plat.position.x &&
        !_plat.vanished) {
        acceleration.y = 0;
        if (isJump)jump();
        position.y = _plat.position.y - _height - 10;
        onPlatform = true;
        break;
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
    acceleration.add(0, -jumpHeight);
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

  void crouch() {
    if (onPlatform)
      position.add(0, normHeight - crouchHeight);
  }

  void unCrouch() {
    if (framesSinceLastCrouch == 10) {
      if (!isDown)
        position.add(0, crouchHeight - normHeight);
    } else
      if (!onPlatform)
        position.add(0, crouchHeight - normHeight);
    acceleration.y = 0;
    framesSinceLastCrouch = 0;
  }

  void checkShot() {
    if (!isCrouching)
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
    exit();
  }
}

boolean isA, isD, isJump, isDown, isLeft, isRight; 

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

  case 83:
    return isDown = b;

  case 32:
    return isJump = b;

  case 87:
    return isJump = b;

  case 16:
    return player.isCrouching = b;

  default:
    return b;
  }
}
