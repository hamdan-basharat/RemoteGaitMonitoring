#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include "BluetoothSerial.h"

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS (100)

BluetoothSerial SerialBT;

// Check I2C device address and correct line below (by default address is 0x29 or 0x28)
//                                   id, address
Adafruit_BNO055 bno = Adafruit_BNO055(55, 0x28);

/**************************************************************************/
/*
    Displays some basic information on this sensor from the unified
    sensor API sensor_t type (see Adafruit_Sensor for more information)
*/
/**************************************************************************/
void displaySensorDetails(void)
{
  sensor_t sensor;
  bno.getSensor(&sensor);
  SerialBT.println("------------------------------------");
  SerialBT.print  ("Sensor:       "); SerialBT.println(sensor.name);
  SerialBT.print  ("Driver Ver:   "); SerialBT.println(sensor.version);
  SerialBT.print  ("Unique ID:    "); SerialBT.println(sensor.sensor_id);
  SerialBT.print  ("Max Value:    "); SerialBT.print(sensor.max_value); SerialBT.println(" xxx");
  SerialBT.print  ("Min Value:    "); SerialBT.print(sensor.min_value); SerialBT.println(" xxx");
  SerialBT.print  ("Resolution:   "); SerialBT.print(sensor.resolution); SerialBT.println(" xxx");
  SerialBT.println("------------------------------------");
  SerialBT.println("");
  delay(500);
}

/**************************************************************************/
/*
    Arduino setup function (automatically called at startup)
*/
/**************************************************************************/
void setup(void)
{
  Serial.begin(115200);
  SerialBT.begin("ESP32");
  SerialBT.println("Orientation Sensor Test"); SerialBT.println("");

  /* Initialise the sensor */
  if(!bno.begin())
  {
    /* There was a problem detecting the BNO055 ... check your connections */
    SerialBT.print("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while(1);
  }
   
  delay(1000);

  /* Use external crystal for better accuracy */
  bno.setExtCrystalUse(true);
   
  /* Display some basic information on this sensor */
  displaySensorDetails();
}

/**************************************************************************/
/*
    Arduino loop function, called once 'setup' is complete (your own code
    should go here)
*/
/**************************************************************************/
void loop(void)
{
  /* Get a new sensor event */
  sensors_event_t event;
  bno.getEvent(&event);

  /* Board layout:
         +----------+
         |         *| RST   PITCH  ROLL  HEADING
     ADR |*        *| SCL
     INT |*        *| SDA     ^            /->
     PS1 |*        *| GND     |            |
     PS0 |*        *| 3VO     Y    Z-->    \-X
         |         *| VIN
         +----------+
  */

  /* The processing sketch expects data as roll, pitch, heading */
  //SerialBT.print(F("Orientation: "));
  //SerialBT.print((float)event.orientation.x);
  //SerialBT.print(F(","));
  SerialBT.println((float)event.orientation.y);
  //SerialBT.print(F(","));
  //SerialBT.print((float)event.orientation.z);
  //SerialBT.println(F(" "));

  /* Also send calibration data for each sensor. */
  uint8_t sys, gyro, accel, mag = 0;
  bno.getCalibration(&sys, &gyro, &accel, &mag);
  /*
  SerialBT.print(F("Calibration: "));
  SerialBT.print(sys, DEC);
  SerialBT.print(F(" "));
  SerialBT.print(gyro, DEC);
  SerialBT.print(F(" "));
  SerialBT.print(accel, DEC);
  SerialBT.print(F(" "));
  SerialBT.println(mag, DEC); */

  delay(BNO055_SAMPLERATE_DELAY_MS);
}
