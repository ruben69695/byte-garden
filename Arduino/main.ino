#include <SoftwareSerial.h>
#include "DHT.h"
#include <DS3231.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>
#include "resources.h"

#define DHTPIN 4
#define DHTTYPE DHT22 // DHT22 AM2302

SoftwareSerial Bluetooth(2, 3); // TX, RX
DHT dht(DHTPIN, DHTTYPE);
uint8_t SOILPIN = A0;

int dryValue = 610;
int wetValue = 268;

unsigned long startMs;
unsigned long actualMs;
unsigned long fileStartMs;

char start = '#';
char end = '?';
char separator = ';';

DS3231 Clock;

bool firstInit = true;

void setup()
{
  Bluetooth.begin(9600);
  Serial.begin(19200);
  Wire.begin();

  while (!Serial)
    ;

  Serial.println("Initializing SD card...");
  if (!SD.begin())
  {
    Serial.println("initialization failed.");
    while (true)
      ;
  }

  dht.begin();
  startMs = millis();
  fileStartMs = startMs;
}

void loop()
{
  // Check for data on bluetooth module
  if (Bluetooth.available())
  {
    Serial.write(Bluetooth.read());
  }

  // Check for data on serial monitor
  if (Serial.available())
  {
    Bluetooth.write(Serial.read());
  }

  actualMs = millis();

  if (firstInit || actualMs - startMs >= 5000)
  {
    startMs = actualMs;

    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();

    int currentSoilValue = analogRead(SOILPIN);
    int soilValuePercentatge = map(currentSoilValue, dryValue, wetValue, 0, 100);

    if (soilValuePercentatge < 0)
      soilValuePercentatge = 0;
    else if (soilValuePercentatge > 100)
      soilValuePercentatge = 100;

    DatexTime currentDate = getDateTime();

    String result = start + currentDate.toString() + separator + temperature + separator + humidity + separator + soilValuePercentatge + end;

    if (firstInit || actualMs - fileStartMs >= 1200000)
    {
      fileStartMs = actualMs;
      File file = SD.open(currentDate.getStringDateForFile(), FILE_WRITE);
      file.println(result);
      file.close();
    }

    // Send values
    Serial.println(result);
    Bluetooth.println(result);
  }

  if (firstInit)
  {
    firstInit = false;
  }
}

void setDateTime(DatexTime *dateTime)
{
  Clock.setSecond(dateTime->second); // Set the second
  Clock.setMinute(dateTime->minute); // Set the minute
  Clock.setHour(dateTime->hour);     // Set the hour
  Clock.setDoW(6);                   // Set the day of the week, nevermind we dont use it but we supply it, this lib is very delicated
  Clock.setDate(dateTime->day);      // Set the date of the month
  Clock.setMonth(dateTime->month);   // Set the month of the year
  Clock.setYear(dateTime->year);     // Set the year (Last two digits of the year)
}

DatexTime getDateTime()
{
  int second, minute, hour, date, month, year, tmp;
  bool century = false;
  bool h12 = false;
  bool PM = false;

  second = Clock.getSecond();
  minute = Clock.getMinute();
  hour = Clock.getHour(h12, PM);
  date = Clock.getDate();
  month = Clock.getMonth(century);
  year = Clock.getYear();
  tmp = Clock.getTemperature(); // nevermind we dont use it but we get it, this lib is very delicated and works bad if we dont get it

  return DatexTime(year, month, date, hour, minute, second);
}

void printDateTime(DatexTime *dateTime, bool blt)
{
  String result = dateTime->toString();

  Serial.println(result);
  if (blt)
    Bluetooth.println(result);
}

void synchronizeData()
{
  File root = SD.open("/");
  File entry;

  do
  {
    entry = root.openNextFile();

    if (entry)
    {
      String filename = String(entry.name()); // Necessary to create a copy of the name to delete it later

      if (!entry.isDirectory())
      {
        synchFile(&entry);
      }

      entry.close();

      SD.remove(filename); // !!!Hope it works before go to the next file!!!!
    }

  } while (entry);

  root.close();
}

void synchFile(File *file)
{
  Serial.print("Reading file ");
  Serial.println(file->name());

  if (file)
  {
    while (file->available())
    {
      Bluetooth.write(file->read());
    }
  }
  {
    Serial.print("Error opening ");
    Serial.println(file->name());
  }
}
