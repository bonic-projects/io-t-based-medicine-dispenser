//Libraries
#include <SPI.h>//https://www.arduino.cc/en/reference/SPI
#include <MFRC522.h>//https://github.com/miguelbalboa/rfid
#include <Servo.h>
static const int servoPin1 = 12;
static const int servoPin2 = 13;
Servo myServo1; //define servo name
Servo myServo2;
#define SS_PIN 21
#define RST_PIN 22
#define LED_G 33 //define green LED pin
#define LED_R 32
#define BUZZ_B 25

String content= "";


//Databse
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>

// Provide the token generation process info.
#include "addons/TokenHelper.h"
// Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert your network credentials
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"

// Insert Firebase project API Key
#define API_KEY "AIzaSyCR6J8jgK9y-qyU2eQbegJhj7QaviiWiFA"

// Insert Authorized Email and Corresponding Password
#define USER_EMAIL "medicine@gmail.com"
#define USER_PASSWORD "Medicine@123"

// Insert RTDB URLefine the RTDB URL
#define DATABASE_URL "https://medicine-dispenser-baaf9-default-rtdb.asia-southeast1.firebasedatabase.app/"
// Define Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Variable to save USER UID
String uid;

// Database main path (to be updated in setup with the user UID)
String databasePath;

FirebaseJson json;

// Timer variables (send new readings every three minutes)
unsigned long sendDataPrevMillis = 0;
unsigned long timerDelay = 5000;

bool isrRegMod = false;
bool isrWorkMod = true;

FirebaseData stream;

void streamCallback(StreamData data)
{
  Serial.println("NEW DATA!");

  String p = data.dataPath();

  Serial.println(p);
  printResult(data); // see addons/RTDBHelper.h

  FirebaseJson jVal = data.jsonObject();
  FirebaseJsonData isrRegModFB;
  FirebaseJsonData isrWorkModFB;
  FirebaseJsonData servo1FB;
  FirebaseJsonData servo2FB;
  FirebaseJsonData redLedFB;
  FirebaseJsonData greenLedFB;
  FirebaseJsonData buzzerFB;
  FirebaseJsonData resetFb;
    
  jVal.get(isrRegModFB, "isrRegMod");
  jVal.get(isrWorkModFB, "isrWorkMod");
  jVal.get(servo1FB, "servo1");
  jVal.get(servo2FB, "servo2");
  jVal.get(redLedFB, "redLed");
  jVal.get(greenLedFB, "greenLed");
  jVal.get(buzzerFB, "buzzer");
  jVal.get(resetFb, "reset");

  if (isrRegModFB.success)
  {
    Serial.println("Success data");
    isrRegMod = isrRegModFB.to<bool>();   
  }  
  if (isrWorkModFB.success)
  {
    Serial.println("Success data");
    isrWorkMod = isrWorkModFB.to<bool>();   
  }
    if (servo1FB.success)
  {
    Serial.println("Success data servo1FB");
    int value = servo1FB.to<int>(); 
    myServo1.write(value); 
  }
    if (servo2FB.success)
  {
    Serial.println("Success data servo2FB");
    int value = servo2FB.to<int>(); 
    myServo2.write(value); 
  }
  if (greenLedFB.success)
  {
    Serial.println("Success data");
    bool value = greenLedFB.to<bool>(); 
    digitalWrite(LED_G, value);
  }
  if (redLedFB.success)
  {
    Serial.println("Success data");
    bool value = redLedFB.to<bool>(); 
    digitalWrite(LED_R, value);  
  }
  if (buzzerFB.success)
  {
    Serial.println("Success data");
    bool value = buzzerFB.to<bool>(); 
    digitalWrite(BUZZ_B, value);  
  }
  if (resetFb.success)
  {
    Serial.println("Success data resetFb");
    bool value = buzzerFB.to<bool>(); 
    content=""; 
  }
}

void streamTimeoutCallback(bool timeout)
{
  if (timeout)
    Serial.println("stream timed out, resuming...\n");

  if (!stream.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream.httpCode(), stream.errorReason().c_str());
}


//Parameters
//const int ipaddress[4] = {103, 97, 67, 25};
//Variables
//byte nuidPICC[4] = {0, 0, 0, 0};
MFRC522::MIFARE_Key key;
MFRC522 rfid = MFRC522(SS_PIN, RST_PIN);

// Initialize WiFi
void initWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi ..");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println(WiFi.localIP());
  Serial.println();
}


void setup() {
  pinMode(LED_G, OUTPUT);
  pinMode(LED_R, OUTPUT);
  pinMode(BUZZ_B, OUTPUT);
  
   //Init Serial USB
  Serial.begin(115200);
  Serial.println(F("Initialize System"));
  //init rfid D8,D5,D6,D7
  SPI.begin();
  rfid.PCD_Init();
  Serial.print(F("Reader :"));
  rfid.PCD_DumpVersionToSerial();
  Serial.println("Put your card to the reader...");

  myServo1.attach(servoPin1);
  myServo2.attach(servoPin2);

  Serial.begin(115200);

  // myServo1.write(50);
  // delay(1000);
  // myServo1.write(140);

  // myServo2.write(50);
  // delay(1000);
  // myServo2.write(140);

  //Database
  initWiFi();
  // Assign the api key (required)
  config.api_key = API_KEY;

  // Assign the user sign in credentials
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  // Assign the RTDB URL (required)
  config.database_url = DATABASE_URL;

  Firebase.reconnectWiFi(true);
  fbdo.setResponseSize(4096);

  // Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  // Assign the maximum retry of token generation
  config.max_token_generation_retry = 5;

  // Initialize the library with the Firebase authen and config
  Firebase.begin(&config, &auth);

  // Getting the user UID might take a few seconds
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  // Print user UID
  uid = auth.token.uid.c_str();
  Serial.print("User UID: ");
  Serial.println(uid);

  // Update database path
  databasePath = "atm/" + uid + "/reading";

   //Stream setup
  if (!Firebase.beginStream(stream, "atm/" + uid + "/data"))
    Serial.printf("sream begin error, %s\n\n", stream.errorReason().c_str());

  Firebase.setStreamCallback(stream, streamCallback, streamTimeoutCallback);
}


void loop() {
  readRFID();
  
if (Firebase.ready() && (millis() - sendDataPrevMillis > timerDelay || sendDataPrevMillis == 0)){
    sendData();        
  }
}

void readRFID(void ) { /* function readRFID */
  ////Read RFID card
  for (byte i = 0; i < 6; i++) {
      key.keyByte[i] = 0xFF;
  }
  // Look for new 1 cards
  if ( ! rfid.PICC_IsNewCardPresent())
      return;
  // Verify if the NUID has been readed
  if (  !rfid.PICC_ReadCardSerial())
      return;
  // Store NUID into nuidPICC array
//  for (byte i = 0; i < 4; i++) {
//      nuidPICC[i] = rfid.uid.uidByte[i];
//  }
  Serial.print(F("RFID In Hex: "));
  printHex(rfid.uid.uidByte, rfid.uid.size);
  Serial.println();
  // Halt PICC
//  rfid.PICC_HaltA();
  // Stop encryption on PCD
//  rfid.PCD_StopCrypto1();
}
/**
    Helper routine to dump a byte array as hex values to Serial.
*/
void printHex(byte *buffer, byte bufferSize) {
  content = "";
  for (byte i = 0; i < bufferSize; i++) {
    Serial.print(buffer[i] < 0x10 ? " 0" : " ");
    Serial.print(buffer[i], HEX);
    content.concat(String(buffer[i] < 0x10 ? "0" : ""));
    content.concat(String(buffer[i], HEX));
  }
  Serial.print("Content: ");
  Serial.println(content);
  sendData();
}

void sendData (){
  // Send new readings to database

 if (Firebase.ready()){
    sendDataPrevMillis = millis();

    json.set("rfid", content);
    json.set("ts/.sv", F("timestamp"));
    Serial.printf("Set json... %s\n", Firebase.RTDB.setJSON(&fbdo, databasePath.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
}
}