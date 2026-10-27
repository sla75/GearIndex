# ComponentBattery

## AXS Derailleur 300 mAh LiPo (SRAM AXS)
* TypeFully ~ 8.40V
* ChargedNominal ~ 7.40V
* LowCritical < 6.80V

## AXS Pod / Shifter CR2032 Coin Cell
* TypeFully ~ 3.00V - 3.20V
* ChargedNominal ~ 2.60V
* LowCritical < 2.40V

# On-Device LED Quick Reference
​If checking the GX Transmission derailleur directly without the Garmin head unit:
* ​Solid Green: Good ~ 25% to 100%
* ​Solid Red: Low ~ 15% to 25%
* ​Flashing Red: Critically Low < 15%
* ​Red / Green Alternate Flash: Shift rejected (e.g., extreme cold below -15°C or overload/bound chain).

# Očekávané hodnoty napětí SRAM AXS vs. ANT+ Status
​Typické hodnoty napětí, které baterie vysílají do ANT+ profilu:
## ​SRAM AXS Baterie přehazovačky (LiPo 2S):
* ​8.40V - 7.60V BATTERY_STATUS_NEW / GOOD (Zelená LED)
* ​7.60V - 7.00V BATTERY_STATUS_OK / LOW (Červená LED)
* ​< 6.80V BATTERY_STATUS_CRITICAL (Blikající červená LED)
## ​SRAM AXS Pod / Ovládač (CR2032):
* ​3.00V - 2.80V BATTERY_STATUS_NEW / GOOD
* ​2.80V - 2.50V BATTERY_STATUS_OK / LOW
* ​< 2.40V BATTERY_STATUS_CRITICAL