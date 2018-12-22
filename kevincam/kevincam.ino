#include <Arduino.h>
#include <bluefruit.h>

#include "BluefruitConfig.h"

#define FACTORYRESET_ENABLE      1


unsigned char relayServiceUUID[] = {0x5E, 0x4D, 0x75, 0x3B,
                                    0x5C, 0x7E, 0x47, 0xB2,
                                    0x94, 0x71, 0xB1, 0xC2,
                                    0xEC, 0xEF, 0xF6, 0xA2};
unsigned char relayControlUUID[] = {0x5E, 0x4D, 0x75, 0x3B,
                                    0x5C, 0x7E, 0x47, 0xB2,
                                    0x94, 0x71, 0x01, 0x00,
                                    0xEC, 0xEF, 0xF6, 0xA2};
BLEService        relayService = BLEService(relayServiceUUID);
BLECharacteristic relayControlCharacteristic = BLECharacteristic(relayControlUUID);

#define RELAY_ON  (0x01)
#define RELAY_OFF (0x00)
#define RELAY_PIN A0

uint8_t           relayState = RELAY_OFF;

BLEDis bledis;    // DIS (Device Information Service) helper class instance

#define CFG_ADV_BLINKY_INTERVAL 1000
TimerHandle_t ledBlinkTimer;

void setup() {
  boolean success;

  Serial.begin(115200);
  
  // Initialise the Bluefruit module
  Serial.println("Initialise the Bluefruit nRF52 module");
  Bluefruit.begin();

  // Initialize built-in LED.
  pinMode(LED_BUILTIN, OUTPUT);

  // Disable automatic BLE connection status on LED.
  Bluefruit.autoConnLed(false);

  // Create functioning blinky.
  ledBlinkTimer = xTimerCreate(NULL, ms2tick(CFG_ADV_BLINKY_INTERVAL/2), true, NULL, blinky_cb);
  xTimerStart(ledBlinkTimer, 0);

  // Initialize the output pin to the relay.
  pinMode(RELAY_PIN, OUTPUT);
  setRelayState(RELAY_OFF);
  
  // Set the advertised device name (keep it short!)
  Serial.println("Setting Device Name to 'KevinCam'");
  Bluefruit.setName("KevinCam");

  // Set the connect/disconnect callback handlers
  Bluefruit.setConnectCallback(connect_callback);
  Bluefruit.setDisconnectCallback(disconnect_callback);

  // Configure and Start the Device Information Service
  Serial.println("Configuring the Device Information Service");
  bledis.setManufacturer("Adafruit Industries");
  bledis.setModel("Bluefruit Feather52");
  bledis.begin();

  // Setup the relay service
  Serial.println("Configuring the Relay Service");
  setupRelay();
  
  // Start advertising.
  startAdv();
}

void loop() {
  displayRelayStatus();
  displayBLEConnectionStatus();
  
  delay(2000);
}

void error(const __FlashStringHelper*err) {
  Serial.println(err);
  while (1);
}

void startAdv(void)
{
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();

  // Include HRM Service UUID
  Bluefruit.Advertising.addService(relayService);

  // Include Name
  Bluefruit.Advertising.addName();
  
  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds  
}

void setupRelay(void)
{
  relayService.begin();

  relayControlCharacteristic.setProperties(CHR_PROPS_READ | CHR_PROPS_WRITE);
  relayControlCharacteristic.setPermission(SECMODE_OPEN, SECMODE_OPEN);
  relayControlCharacteristic.setFixedLen(1);
  relayControlCharacteristic.setWriteCallback(write_relay_cb);
  relayControlCharacteristic.setCccdWriteCallback(cccd_write_relay_cb);
  relayControlCharacteristic.begin();
  updateRelayCharacteristicValue();
}

void connect_callback(uint16_t conn_handle)
{
  char central_name[32] = { 0 };
  Bluefruit.Gap.getPeerName(conn_handle, central_name, sizeof(central_name));

  Serial.print("Connected to ");
  Serial.println(central_name);
}

/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;

  Serial.println("Disconnected");
}

void write_relay_cb(BLECharacteristic& chr, uint8_t* data, uint16_t len, uint16_t offset) {
  Serial.println("Relay data written");
  Serial.println(data[0] ? "ON" : "OFF");
  setRelayState(data[0]);
  updateRelayCharacteristicValue();
  
  // TODO: If turning the relay on, start a 30-second timer to turn it off again.
}

void cccd_write_relay_cb(BLECharacteristic& chr, uint16_t cccd_value) {
  Serial.println("CCCD relay data written");  
}

void updateRelayCharacteristicValue() {
  relayControlCharacteristic.write8(relayState);
}

void setRelayState(uint8_t newRelayState) {
  relayState = newRelayState;
  digitalWrite(RELAY_PIN, newRelayState == 0 ? LOW : HIGH);  
}

void displayRelayStatus() {
  digitalWrite(LED_BUILTIN, relayState == 0 ? LOW : HIGH);
}

void displayBLEConnectionStatus() {
  setBlueLED(Bluefruit.connected());
}

void setBlueLED(boolean onOff) {
  digitalWrite(LED_BLUE, onOff ? HIGH : LOW);
}

void blinky_cb(TimerHandle_t xTimer) {
  if (relayState == 0) {
    digitalToggle(LED_BUILTIN);
  }
}
