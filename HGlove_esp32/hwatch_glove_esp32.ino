#include "DFRobot_BloodOxygen_S.h"
#include <Adafruit_MLX90614.h>
#include <Wire.h>
int ADXL345 = 0x53;  // The ADXL345 sensor I2C address

int sensoread[5];

float X_out, Y_out, Z_out;  // Outputs

int read20[100];

int mode = 0;
//int counter = 0;
int i = 0, j,k;

int awake = 0; 

int sensorReadFinaltemp = 0;

int sensorReadFinal = 0;

int sensoreadtemp[5];

void IRAM_ATTR ISR1() {
  mode = 1;
}

void IRAM_ATTR ISR2() {
  mode = 2;
}
void IRAM_ATTR ISR3() {
  awake = 1;
}

Adafruit_MLX90614 mlx = Adafruit_MLX90614();
#define I2C_COMMUNICATION  //use I2C for communication, but use the serial port for communication if the line of codes were masked

#ifdef I2C_COMMUNICATION
#define I2C_ADDRESS 0x57
DFRobot_BloodOxygen_S_I2C MAX30102(&Wire, I2C_ADDRESS);
#else

/* ---------------------------------------------------------------------------------------------------------------
 *    board   |             MCU                | Leonardo/Mega2560/M0 |    UNO    | ESP8266 | ESP32 |  microbit  |
 *     VCC    |            3.3V/5V             |        VCC           |    VCC    |   VCC   |  VCC  |     X      |
 *     GND    |              GND               |        GND           |    GND    |   GND   |  GND  |     X      |
 *     RX     |              TX                |     Serial1 TX1      |     5     |   5/D6  |  D2   |     X      |
 *     TX     |              RX                |     Serial1 RX1      |     4     |   4/D7  |  D3   |     X      |
 * ---------------------------------------------------------------------------------------------------------------*/

#if defined(ARDUINO_AVR_UNO) || defined(ESP8266)
SoftwareSerial mySerial(4, 5);
DFRobot_BloodOxygen_S_SoftWareUart MAX30102(&mySerial, 9600);
#else
DFRobot_BloodOxygen_S_HardWareUart MAX30102(&Serial1, 9600);
#endif
#endif
#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#endif

#include <Firebase_ESP_Client.h>
//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

#define API_KEY "AIzaSyDLRQbUtaWBP1iRMXJQ8cwr9wfbhwdLHpA"
#define DATABASE_URL "https://health-diagnosis-94ee9-default-rtdb.firebaseio.com"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
String message;

bool signupOK = false;
unsigned long sendDataPrevMillis = 0;

#define WIFI_SSID "OnePlus 8T"
#define WIFI_PASSWORD "OMARonly2020"

void setup() {

  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to Wi-Fi");

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  while (MAX30102.begin() == false) {
    Serial.println("init fail!");
    delay(1000);
  }
  Serial.println("init success!");
  Serial.println("start measuring...");
  MAX30102.sensorStartCollect();

  while (!Serial)
    ;
  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  auth.user.email = "@gmail.com";
  auth.user.password = "";
  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("ok");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }


  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback;  //see addons/TokenHelper.h

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Adafruit MLX90614 test");

  if (!mlx.begin()) {
    Serial.println("Error connecting to MLX sensor. Check wiring.");
    while (1)
      ;
  };

  Serial.print("Emissivity = ");
  Serial.println(mlx.readEmissivity());
  Serial.println("================================================");
  pinMode(19, INPUT_PULLUP);
  pinMode(34, INPUT_PULLUP);
  pinMode(32, INPUT_PULLUP);


  attachInterrupt(34, ISR1, FALLING);
  attachInterrupt(32, ISR2, FALLING);
  attachInterrupt(19, ISR3, FALLING);


  Wire.begin();  // Initiate the Wire library
  // Set ADXL345 in measuring mode
  Wire.beginTransmission(ADXL345);  // Start communicating with the device
  Wire.write(0x2D);                 // Access/ talk to POWER_CTL Register - 0x2D
  // Enable measurement
  Wire.write(8);  // (8dec -> 0000 1000 binary) Bit D3 High for measuring enable
  Wire.endTransmission();
  delay(10);
  gyro();
  i = 0;
}

void loop() {
  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0)) {
    Serial.println(fbdo.stringData());
    Serial.println(fbdo.dataPath());
    if (mode == 1) {
      for (i = i; i < (i + 10) && mode == 1; i++) {
        sensorReadFinal = 0;
        MAX30102.getHeartbeatSPO2();
        for (int senread = 0; senread < 5; senread++) {
          sensoread[senread] = MAX30102._sHeartbeatSPO2.Heartbeat - 10;
          delay(100);
        }
        for (int senread = 0; senread < 5; senread++) {
          sensorReadFinal = sensorReadFinal + sensoread[senread];
        }

        sensorReadFinal = sensorReadFinal / 5;
        for (int senread = 0; senread < 5; senread++) {
          sensoreadtemp[senread] = MAX30102.getTemperature_C();
          delay(100);
        }
        for (int senread = 0; senread < 5; senread++) {
          sensorReadFinaltemp = sensorReadFinaltemp + sensoreadtemp[senread];
        }

        sensorReadFinaltemp = sensorReadFinaltemp / 5;

        Serial.println("SPO2 is : " );
        Serial.print(MAX30102._sHeartbeatSPO2.SPO2);
        Serial.println("%");

        if (Firebase.RTDB.setInt(&fbdo, "heartRate", MAX30102._sHeartbeatSPO2.Heartbeat)) {
          Serial.println("PASSED");
          Serial.println("PATH: " + fbdo.dataPath());
          Serial.println("TYPE: " + fbdo.dataType());
        } else {
          Serial.println("FAILED");
          Serial.println("REASON: " + fbdo.errorReason());
        }
        if (Firebase.RTDB.setInt(&fbdo, "spO2", MAX30102._sHeartbeatSPO2.SPO2)) {
          Serial.println("PASSED");
          Serial.println("PATH: " + fbdo.dataPath());
          Serial.println("TYPE: " + fbdo.dataType());
        } else {
          Serial.println("FAILED");
          Serial.println("REASON: " + fbdo.errorReason());
        }
        Serial.print("Heart rate : " );
        Serial.print(sensorReadFinal);
        Serial.println(" beats/min");

        //Serial.print(MAX30102._sHeartbeatSPO2.Heartbeat - 10); 

        Serial.print("Temperature value of the board is : ");
        Serial.print(sensorReadFinaltemp);
        Serial.println(" ℃");
        sensorReadFinal = 0;
        sensorReadFinaltemp = 0;
        //counter++;
        gyro();
        read20[i] = (X_out + Y_out + Z_out) / 3;
        delay(1000);
        Serial.println(read20[i]);
        if (i != 0 && i % 20 == 0) {
          for (j = 0; j < 10 && awake == 0; j++) {
            if (read20[i - 20] == read20[i]) {
              alarm();
              i = 0;
            }
            awake = 0;
          }
        }
        if (i == 100) {
          i = 0;
        }
        Serial.println(i);
        if (mode == 2) {
          break;
        }
      }

      gyro();
      read20[i] = (X_out + Y_out + Z_out) / 3;
      delay(1000);
      Serial.println(read20[i]);
      if (i != 0 && i % 20 == 0) {
        for (j = 0; j < 10 && awake == 0; j++) {
          if (read20[i - 20] == read20[i]) {
            alarm();
            i = 0;
          }
        }
        awake = 0;
      }
      if (i == 100) {
        i = 0;
      }

      i++;
      Serial.println(i);
    }
    if (mode == 2) {
      for (i = i; i < (i + 10) && mode == 2; i++) {
        sensorReadFinal = 0;
        sensorReadFinaltemp = 0;
        for (int senread = 0; senread < 5; senread++) {
          sensoread[senread] = mlx.readObjectTempC();
          delay(100);
        }
        for (int senread = 0; senread < 5; senread++) {
          sensorReadFinal = sensorReadFinal + sensoread[senread];
        }
        sensorReadFinal = sensorReadFinal / 5;

        if (Firebase.RTDB.setInt(&fbdo, "temperature", sensorReadFinal)) {
          Serial.println("PASSED");
          Serial.println("PATH: " + fbdo.dataPath());
          Serial.println("TYPE: " + fbdo.dataType());
        } else {
          Serial.println("FAILED");
          Serial.println("REASON: " + fbdo.errorReason());
        }  

        Serial.println("Ambient = " + sensorReadFinal); 
        Serial.print("*C\tObject = ");
        Serial.print(mlx.readObjectTempC());
        Serial.println(" *C");
        /*
          Serial.print("Ambient = ");
          Serial.print(mlx.readAmbientTempF());
          Serial.print("*F\tObject = ");
          Serial.print(mlx.readObjectTempF());
          Serial.println("*F");
        */
        Serial.println();

        //The sensor updates the data every 4 seconds
        delay(1000);
        sensorReadFinal = 0;
        //Serial.println("stop measuring...");
        //MAX30102.sensorEndCollect();
        gyro();
        read20[i] = (X_out + Y_out + Z_out) / 3;
        delay(1000);
        Serial.println(read20[i]);
        if (i != 0 && i % 20 == 0) {
          for (j = 0; j < 10 && awake == 0; j++) {
            if (read20[i - 20] == read20[i]) {
              alarm();
              i = 0;
            }
          }
          awake = 0;
        }
        if (i == 100) {
          i = 0;
        }
        Serial.println(i);
        if (mode == 1) {
          break;
        }
      }
    }
  } else {
    Serial.println("Firebase isn't setup");
  }
}

void gyro() {
  Wire.beginTransmission(ADXL345);
  Wire.write(0x32);  // Start with register 0x32 (ACCEL_XOUT_H)
  Wire.endTransmission(false);
  Wire.requestFrom(ADXL345, 6, true);        // Read 6 registers total, each axis value is stored in 2 registers
  X_out = (Wire.read() | Wire.read() << 8);  // X-axis value
  X_out = X_out / 256;                       //For a range of +-2g, we need to divide the raw values by 256, according to the datasheet
  Y_out = (Wire.read() | Wire.read() << 8);  // Y-axis value
  Y_out = Y_out / 256;
  Z_out = (Wire.read() | Wire.read() << 8);  // Z-axis value
  Z_out = Z_out / 256;

  Serial.print("Xa= ");
  Serial.println( X_out);
  Serial.print("Ya= ");  
  Serial.println(Y_out); 
  Serial.print("Za= ");
  Serial.println(Z_out);
}

void alarm() {
  awake = 0;
  for (k = 15; k > 0; k--) {
    Serial.println("are you awake?");
    Serial.println(k);
    delay(1000);
    if (awake == 1) {
      break;
    }
  }
  if (k == 0)
    send_alarm();
}

void send_alarm() {
  Serial.println("WARNING");
  delay(100);
}
