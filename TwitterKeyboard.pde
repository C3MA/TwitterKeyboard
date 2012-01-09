#include <SPI.h> // needed in Arduino 0019 or later
#include <Ethernet.h>
#include <Twitter.h>

#include <PS2Keyboard.h>

const int DataPin = 8;
const int IRQpin =  3;

PS2Keyboard keyboard;

// Ethernet Shield Settings
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };

// If you don't specify the IP address, DHCP is used(only in Arduino 1.0 or later).
byte ip[] = { 10, 23, 42, 177 };

// Your Token to Tweet (get it from http://arduino-tweet.appspot.com/)
Twitter twitter("TOKEN");

// Message to post
char msg[141];
int msgPos = 0;

void setup()
{
  keyboard.begin(DataPin, IRQpin, PS2Keymap_German);
  
  delay(1000);
  //Ethernet.begin(mac, ip);
  // or you can use DHCP for autoomatic IP address configuration.
  Ethernet.begin(mac);
  Serial.begin(9600);
  
}

void loop()
{
  if (keyboard.available()) {

   char c = keyboard.read();
    
    if(c == PS2_ESC){
      msgPos = 0;
      msg[0] = 0; 
      return;
    }

    if(c == PS2_ENTER){
      postTweet();
      msgPos = 0;
      msg[0] = 0;
      return;
    }
    
    //append read charater
    msg[msgPos] = c;
    msgPos++;  
    msg[msgPos] = 0; 

   if(msgPos >= 139)
      postTweet();
  }
  
}


void postTweet()
{
  Serial.println("connecting ...");
  if (twitter.post(msg)) {
    // Specify &Serial to output received response to Serial.
    // If no output is required, you can just omit the argument, e.g.
    int status = twitter.wait();
    //int status = twitter.wait(&Serial);
    if (status == 200) {
      Serial.println("OK.");
    } else {
      Serial.print("failed : code ");
      Serial.println(status);
    }
  } else {
    Serial.println("connection failed.");
  }
}
