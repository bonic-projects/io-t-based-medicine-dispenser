//Keypad
#include <Keypad.h>
const byte ROWS = 4;
const byte COLS = 3;
char keys[ROWS][COLS] = { 
    {'1', '2', '3'},
    {'4', '5', '6'},
    {'7', '8', '9'},
    {'*', '0', '#'}};
byte rowPins[ROWS] = {13, 12, 14, 27}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {26, 25, 33}; //connect to the column pinouts of the keypad
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);
char enteredPassword[5];
const char *password = "1234";

//WiFi
#define wifiLedPin 2

//Firebase
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
// Provide the token generation process info.
#include <addons/TokenHelper.h>
// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>
/* 1. Define the WiFi credentials */
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino
/* 2. Define the API Key */
#define API_KEY "AIzaSyCR6J8jgK9y-qyU2eQbegJhj7QaviiWiFA"
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://medicine-dispenser-baaf9-default-rtdb.asia-southeast1.firebasedatabase.app/"
/* 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "medicine@gmail.com"
#define USER_PASSWORD "Medicine@123"
// Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
unsigned long sendDataPrevMillis = 0;
// Variable to save USER UID
String uid;
//Databse
String path;

FirebaseData stream;

void streamCallback(StreamData data)
{
  Serial.println("NEW DATA!");

  String p = data.dataPath();

  Serial.println(p);
  printResult(data); // see addons/RTDBHelper.h

  FirebaseJson jVal = data.jsonObject();
  FirebaseJsonData resetFB;
  jVal.get(resetFB, "reset");
  if (resetFB.success)
  {
    Serial.println("Success data resetFB");
    bool value = resetFB.to<bool>(); 
    memset(enteredPassword, 0, sizeof(enteredPassword));
  }
}

void streamTimeoutCallback(bool timeout)
{
  if (timeout)
    Serial.println("stream timed out, resuming...\n");

  if (!stream.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream.httpCode(), stream.errorReason().c_str());
}




void setup() {  
  Serial.begin(115200);
  //WIFI
  pinMode(wifiLedPin, OUTPUT);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  unsigned long ms = millis();
  while (WiFi.status() != WL_CONNECTED)
  {
    digitalWrite(wifiLedPin, LOW);
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  digitalWrite(wifiLedPin, HIGH);
  Serial.println(WiFi.localIP());
  Serial.println();

  //FIREBASE
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Limit the size of response payload to be collected in FirebaseData
  fbdo.setResponseSize(2048);

  Firebase.begin(&config, &auth);

  // Comment or pass false value when WiFi reconnection will control by your code or third party library
  Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);

  config.timeout.serverResponse = 10 * 1000;

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

  path = "atm/" + uid + "/reading2";

   //Stream setup
  if (!Firebase.beginStream(stream, "atm/" + uid + "/data"))
    Serial.printf("sream begin error, %s\n\n", stream.errorReason().c_str());

  Firebase.setStreamCallback(stream, streamCallback, streamTimeoutCallback);
}

void loop() {
  readKeypad();

  if (Firebase.ready() && (millis() - sendDataPrevMillis > 5000 || sendDataPrevMillis == 0)){
    updateData();
  }
}

void readKeypad(){
  char key = keypad.getKey();
  if (key != NO_KEY && strlen(enteredPassword) < 4)
  {
    enteredPassword[strlen(enteredPassword)] = key;
    Serial.print(enteredPassword);
    updateData();
  }

  if (key != NO_KEY && key == '*')
  {
    memset(enteredPassword, 0, sizeof(enteredPassword));
    updateData();
  }
  // if (strlen(enteredPassword) == 4)
  // {
  //   Serial.println("Password:");
  //   Serial.println(password);
  //   if (strcmp(enteredPassword, password) == 0)
  //   {
  //     Serial.println("Correct password");
  //     // enteredPassword[0] = '\0';
  //     memset(enteredPassword, 0, sizeof(enteredPassword));
  //    }
  //      else
  //    {
  //     Serial.println("Password incorrect");
  //     delay(1000);
  //     memset(enteredPassword, 0, sizeof(enteredPassword));
  //    }
  // }
}



void updateData(){
  if (Firebase.ready())
  {
    sendDataPrevMillis = millis();
    FirebaseJson json;
    json.set("pin", enteredPassword);
    json.set(F("ts/.sv"), F("timestamp"));
    Serial.printf("Set json... %s\n", Firebase.RTDB.set(&fbdo, path.c_str(), &json) ? "ok" : fbdo.errorReason().c_str());
    Serial.println("");
  }
}
