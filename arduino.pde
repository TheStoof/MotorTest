#include <Servo.h>

// variable to store the data from the serial port
int cmd = 0;
int pos = 0;
Servo servo;

// command arguments
int cmd_arg[2];

int serialStatus = 0;

void setup() {
  // connect to the serial port
  Serial.begin(115200);
  setupPins();
  serialStatus = 1;
}

void loop()
{

  if(serialStatus==0)
  {
    Serial.flush();
    setupPins();
  }
  askCmd();

  {
    if(Serial.available()>0)
    {
      cmd = int(Serial.read()) - 48;
  
      if(cmd==0) //set digital low
      {
        cmd_arg[0] = int(readData()) - 48;
        digitalWrite(cmd_arg[0],LOW);
      }
  
      if(cmd==1) //set digital high
      {
        cmd_arg[0] = int(readData()) - 48;
        digitalWrite(cmd_arg[0],HIGH);
      }
  
      if(cmd==2) //get digital value
      {
        cmd_arg[0] = int(readData()) - 48;
        cmd_arg[0] = digitalRead(cmd_arg[0]);
        Serial.println(cmd_arg[0]);
      }
  
      if(cmd==3) // set analog value
      {
        Serial.println("I'm in the right place");
        cmd_arg[0] = int(readData()) - 48;
        cmd_arg[1] = readHexValue();
        analogWrite(cmd_arg[0],cmd_arg[1]);
      }
  
      if(cmd==4) //read analog value
      {
        cmd_arg[0] = int(readData()) - 48;
        cmd_arg[0] = analogRead(cmd_arg[0]);
        Serial.println(cmd_arg[0]);
      }
  
      if(cmd==5)
      {
        serialStatus = 0;
      }

      // rotate left
      if(cmd==6)
      {
        if (pos > 0) {
	    pos = pos - 5;
	    servo.write(pos);
	}
      }

      // rotate right
      if(cmd==7)
      {
        if (pos < 180) {
	    pos = pos + 5;
	    servo.write(pos);
	}
      }

    }
  }
}

char readData()
{
  askData();

  while(1)
  {
    if(Serial.available()>0)
    {
      return Serial.read();
    }
  }
}


//read hex value from serial and convert to integer
int readHexValue()
{
  int strval[2];
  int converted_str;

  while(1)
  {
    if(Serial.available()>0)
    {
      strval[0] = convert_hex_to_int(Serial.read());
      break;
    }
  }

  askData();

  while(1)
  {
    if(Serial.available()>0)
    {
      strval[1] = convert_hex_to_int(Serial.read());
      break;
    }
  }

  converted_str = (strval[0]*16) + strval[1];
  return converted_str;
}


int convert_hex_to_int(char c)
{
  return (c <= '9') ? c-'0' : c-'a'+10;
}


void askData()
{
  Serial.println("?");
}


void askCmd()
{
  askData();
  while(Serial.available()<=0)
  {}
}


void setupPins()
{
  while(Serial.available()<1)
  {
    // get number of output pins and convert to int
    // 48 = 0; 49 = 1; 50 = 2;
    // enableServo from Ruby code will send '/' that is converted to 47.
    cmd = int(readData()) - 48;

    if (cmd == -1) {
	// default pin 9
	servo.attach(9);
	// set to 90 degrees
	pos = 90;
	servo.write(pos);
    } else {
        for(int i=0; i<cmd; i++) {
            cmd_arg[0] = int(readData()) - 48;
           pinMode(cmd_arg[0], OUTPUT);
        }
    }
    break;
  }
}
