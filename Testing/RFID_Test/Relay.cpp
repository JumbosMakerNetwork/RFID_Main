#include <iostream>
#include <string>
#include <ctype.h>
#include <wiringPi.h>
#include <wiringPiSPI.h>
#include <wiringSerial.h>
#include <curl/curl.h>
#include <curl/easy.h>
#include <MFRC522.h>
using namespace std;
/*
  * Power/Data Interlock Relay Terminal for Makerspace RFID system
  * Brian O'Connell, Will Dolan 2016
  * Translated into C++ by Will Dolan, June 2016
*/

////////////////////// Wireless network information //////////////////////

const char *SSID      = "tuftswireless";
const char *PSK       = ""; 
// const char *DBIP      = "130.64.17.0";
const char *DBIP      = "130.64.91.17";
const int STID        = 5;             // Station ID number (soldering)

///////////////// Hardware assignments //////////////////////
#define RST_PIN      25;            // GPIO pin 25, physical pin 37   
#define SS_PIN       10;            // SPI0_CE0 pin, physical pin 26
static const int CHANNEL = 1;        // which Pi i/o SPI channel we're using for MFRC

const int greenLED    = 7;           // physical pin 7
const int redLED      = 6;           // physical pin 22
const int relayPin    = 4;           // physical pin 16
const int HELP_BUTTON = 5;           // physical pin 18
string http_data;

size_t writeCallback(char* buf, size_t size, size_t nmemb, void* up);
string composeURL(string RFID, string req, string info);
string ReqJMN(string RFID1, string req1, string info1);
void   beginUse(string resp);
void   rejectUse();
void   endUse();
void   noUserHandler();
int    getPICC();
string GetRFID(byte *buffer, byte bufferSize);
void   contact_admin(string user_RFID);
void   sendHelpEmail(string user_RFID);
void   display(string line1, string line2);
string getName(string response);
string center(string toCenter);

int main(void)
{       
        // "setup"
        ////////////////////// RFID/Spi Setup //////////////////////
        wiringPiSetupGpio(); // Initialize wiringPi
        int SPI_fd = wiringPiSPISetup(CHANNEL, 500000);
        unsigned char buffer[100];
        string RFID_UID = "";

        MFRC522 RFID(SS_PIN, RST_PIN);  // Create mfrc522 instance
        MFRC522::MIFARE_Key key;
 
        // Prepare the key (used both as key A and as key B)
        // using FFFFFFFFFFFFh which is the default at chip delivery from the factory
        for (int i = 0; i < 6; i++) {
                key.keyByte[i] = 0xFF;
        }
        GetRFID(key.keyByte, MFRC522::MF_KEY_SIZE);

        ////////////////////// initialize Serial //////////////////////

        //SoftwareSerial LCD(2,3);        // D2 -> LCD TX, D3 -> LCD RX (unused)
        LCD serialOpen (char *TODO, 9600);
        RFID.PCD_Init();

        // For the timer
        unsigned long t0 = 0;
        unsigned long t1 = 0;
        string timer = "";

        pinMode(redLED, OUTPUT);
        pinMode(greenLED, OUTPUT);
        pinMode(relayPin, OUTPUT);

        pullUpDnControl(HELP_BUTTON, PUD_UP); // Enable pull-up resistor on button
        // formerly pinMode(HELP_BUTTON, INPUT_PULLUP);
        int inithelpState = digitalRead(HELP_BUTTON);
        display("Waiting for", "RFID...");

        // "Loop"
        while(1) {
                do {
                        if(digitalRead(HELP_BUTTON) != inithelpState) {
                                contact_admin("0");
                        }
                } while ( !getPICC() );
  
                cout << "An RFID has been detected" << endl;
                RFID_UID = GetRFID(RFID.uid.uidByte, RFID.uid.size);
                display("Welcome!", "RFID Detected!");

                string resp = ReqJMN(RFID_UID, "1", "begin");
                cout << resp << endl;

                if (resp[0]== 'T') {
                        beginUse(resp);
                }
                else if (resp[0] == 'F') {
                        rejectUse();
                }
                else {
                        noUserHandler();
                }
                display("Waiting for", "RFID..");
        }
}

void beginUse(string resp) 
{
        int inithelpState = digitalRead(HELP_BUTTON);
        int helpButtonCounts = 0;

        digitalWrite(greenLED, HIGH);
        string name = getName(resp);
        display("Welcome", name);
        delay(1000);
        display("Permission","Granted!");
        delay(1000);

        t0 = millis(); //TODO suitable replacement
        digitalWrite(greenLED, HIGH);
        digitalWrite(relayPin, HIGH);
        display("Commence","Use...");

        //while the RFID engaged is the same as before
        while( getPICC() ) { 
                RFID.PICC_IsNewCardPresent();
                RFID.PICC_ReadCardSerial();
                if(digitalRead(HELP_BUTTON) != inithelpState) {   
                    if(helpButtonCounts > 0) {
                          contact_admin(RFID_UID);
                    }
                    else {
                        helpButtonCounts++;
                        sendHelpEmail(RFID_UID);
                    }
                }
                delay(2000);  //give access for 2 secs
                display("Commence Use","or Press Help!");
        }
        endUse();
}
void rejectUse()
{
        digitalWrite(redLED, HIGH);  
        display("Insufficient","credentials");
        delay(1000);
        display("Get approved at","maker.tufts.edu");
        delay(1000);
        digitalWrite(redLED, LOW);
        digitalWrite(relayPin, LOW);
}
void noUserHandler()
{
        // Blink the red light and give an error message.
        // Display a warning to get a staff member. 
        display("No ID found","in Database");
        digitalWrite(relayPin, LOW);
        digitalWrite(redLED, HIGH);  
        delay(1000);
        display("Get approved at","maker.tufts.edu"); 
        digitalWrite(redLED, LOW);
        delay(1000);
}

void endUse()
{
        display("Goodbye!", "Signed out!");
        t1 = millis(); //TODO dont know if this will work
        t1 = t1-t0;
        t1 = t1/1000; //this gives us seconds since signin

        digitalWrite(greenLED, LOW);
        digitalWrite(relayPin, LOW);

        cout << "seconds elapsed: " << info << endl;
        ReqJMN(RFID_UID, "2", string(t1)); //todo unsure if string() will work
}


/////////////////////////////////////////////////////////////////
/////////////////////RFID UTILITY FUNCTIONS//////////////////////
//////////////////////////////////////////////////////////////////

int getPICC() {
  // Getting ready for Reading PICCs
        if ( !RFID.PICC_IsNewCardPresent() ) { //If a new PICC placed to RFID reader continue
                return 0;
        }
        if ( !RFID.PICC_ReadCardSerial() ) {   //Since a PICC is placed, get Serial and continue
                return 0;
        }
        return 1;
}
// Grab the hex values from a byte array, returns decimal equivalent
string GetRFID(byte *buffer, byte bufferSize) {
        cout << "Get RFID called." << endl;
        string tmp = "";
        string tmp2;
        for (int i = 0; i < bufferSize; i++) {
                tmp2 = "";
                tmp2 += String(buffer[i] < 0x10 ? "0" : "");
                tmp2 += String(buffer[i], HEX);
                tmp = tmp2 + tmp;
        }
        tmp.toupper(); // TODO need to apply to all 
        return tmp;
}


////////////////////////////////////////////////////////////////////////
/////////////////////// WIFI / DATABASE UTILITIES //////////////////////
////////////////////////////////////////////////////////////////////////

void contact_admin(string user_RFID)
{
        display("Administrator","Contacted.");
        delay(2500);
        display("Please wait,","help is coming!");
        delay(2500);  
        display("Waiting for", "RFID..");
        ReqJMN(user_RFID, "4", "contact_admin");
}
void sendHelpEmail(string user_RFID)
{
        display("Help","Requested!");
        delay(1500);                
        display("Check your email","for information");
        delay(2000);                
        display("or press again","to call admin.");
        delay(1500);        
        ReqJMN(RFID_UID, "4", "help_email");
}

string ReqJMN(string RFID1, string req1, string info1)
{
        string resp="";
        char z;
        cout << "Starting request..." << endl;
        string httpURL = composeURL(RFID1, req1, info1);

        CURL* curl;
        curl_global_init(CURL_GLOBAL_ALL); //pretty obvious
        curl = curl_easy_init();
        curl_easy_setopt(curl, CURLOPT_URL, httpURL.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, &writeCallback);
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L); //tell curl to output its progress

        curl_easy_perform(curl);
        curl_easy_cleanup(curl);

        //here parse data, return 't' or 'e' or 'f'
        cout << "completed request. httpdata: \n" << http_data << endl;

        return resp;
}

//callback must have this declaration
        //buf is a pointer to the data that curl has for us
        //size*nmemb is the size of the buffer
size_t writeCallback(char* buf, size_t size, size_t nmemb, void* up)
{ 
        for (int c = 0; c<size*nmemb; c++)
        {
                http_data.push_back(buf[c]);
        }
        return size*nmemb; //tell curl how many bytes we handled
}

string composeURL(string RFID1 string req, string info)
{
        string httpURL = "http://" + DBIP + "/RFID.php?";
        httpURL += "stid=" + STID;      // Universal constant
        httpURL += "&rfid=" + RFID;    //local
        httpURL += "&req=" + req;      //local
        httpURL += "&info=" + info;    //local
        cout << httpURL << endl;
        return httpURL;
}



////////////////////////////////////////////////////////////////////////
////////////////// MISC UTILITIES ///////////////////////////////////
//////////////////////////////////////////////////////

// Function for sending strings to the display
//TODO enable for new serial communication
void display(string line1, string line2)
{
        // Clear the display
        LCD.write(254); LCD.write(128);
        LCD.write("                "); // clear display (16 characters each line)
        LCD.write("                ");

        line1 = center(Line1);
        line2 = center(Line2);

        // Concatenate the strings
        char L1[ ] = "                "; // 16 Characters
        char L2[ ] = "                ";
        line1.toCharArray(L1, 16);
        line2.toCharArray(L2, 16);

        LCD.write(254); LCD.write(128); // First line
        LCD.write(L1);

        LCD.write(254); LCD.write(192); // Second line
        LCD.write(L2);

        delay(25);
}

string getName(string response)
{
        response.remove(0,2);   //removes 'T' and a whitespace, also, this fxn is
                              //pass by copy, so we're not altering the reponse from before
        Serial.println(response);

        //find whitespace after name
        int k = 0;
        for(k; k < response.length(); k++) {
              if(response[k] == ' ') {
                    break;
              }
        }

        int j = (16 - k);
        // now remove everything after index k, up to the last index (index 15)
        response.remove(k, j);
        return response;
}

string center(string toCenter)
{
        // Center the string for the display
        int a = toCenter.length();
        a = a + (a % 2);  //makes divisible by 2
        a = 16 - a;
        a = a/2;
        string center1 = "";
        for (a; a > 0; a--) {    //for loop concatenates whitespaces to beginning of new array
                center1 += ' ';
        }
        center1 += toCenter;
        return center1;
}