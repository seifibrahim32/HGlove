# HGlove

A smart healthcare application system used for assisting patients to know their expected diseases by doing assessment intake vieweing some sort of medical questions , these questions are powered by EndlessMedical API which helps to give various features for the user to know the top ten diseases. 

Aside of software, we implemented PCB Glove embedded with ESP32 microcontroller which sends data to Firebase Realtime database about health's body oxygen percentage, heart beats and so on, also from the Flutter app we wrote some Kotlin code which helps the application closes during termination of the application by user so in case the glove detected a reach for the maximum level of the oxygen level or heart rate it calls the nearest phone number registered by user during activiation of new account.

Moreover , it helps the the main family carrier member to know the status of the patient health every time by time as well as the patient has a good internet connection, the application serves the patient also the add some tips for the medicine intake , appointments date, and some other features will can be added in future.

NOTE: THIS APPLICATION WAS THE GRADUATION PROJECT OF MINE WITH A+ GRADING. :)))))

## Application characteristics

- Flutter
  Flutter is a cross platform application helps user to desgin multi-platform so we used it to implement in future more platforms rather than Android only.
- Kotlin
  We used Kotlin inside Flutter to create notifications which help user to determine the health characteristics inside as it helps the use different intents for the Android services unlike Flutter , so we enable to have ACTION_CALL which helps to call the emergency number without interfering into the main dialer of the Android phone.
  Nevertheless we used Firebase Database with Kotlin language as it involves "lateinit" for Firebase instace which secures null safety.
  

## Glove
| Foreward               | Backward               |
| ---------------------- | ---------------------- |
|  ![IMG_20230620_091657_419](https://github.com/seifibrahim32/HGlove/assets/58334300/9bf8cc5a-b6e6-472d-bb00-2cf3f3a399b4) |![IMG_20230620_091657_419](https://github.com/seifibrahim32/HGlove/assets/58334300/8dd86e58-c75b-45a8-b5d2-49e2b002c255)|




- ESP32 microcontroller is used for the case 

## Connectivity with Firebase services

I have integrated the ESP32 with the Firebase using ESP32 Mozart Library where utilizes me to use authentication methods and set integer and non integer values with Arduino code to Realtime Database so the Flutter app can detect any changes automtically.
The application requires Internet to set the data in the meantime.
## Screenshots

Still updating the README file.
Still writing...

## Tools
