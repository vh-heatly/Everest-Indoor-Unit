﻿FUNCTION UoM_ToString : STRING
	USING System;
	USING System.Globalization;
	
    VAR_INPUT
        UoM : INT;
    END_VAR

    CASE TO_UINT(UoM) OF
        UOM#NONE                                        : UoM_ToString := '';                           
	    UOM#YEAR                                        : UoM_ToString := '';
	    UOM#WEEK                                        : UoM_ToString := '';
	    UOM#DAY                                         : UoM_ToString := '';
	    UOM#HOUR                                        : UoM_ToString := 'h';
	    UOM#MINUTE                                      : UoM_ToString := 'm';
	    UOM#MONTH                                       : UoM_ToString := '';
	    UOM#SECOND                                      : UoM_ToString := 's';
	    UOM#HUNDREDTHS_SECOND                           : UoM_ToString := '';
	    UOM#MILLISECOND                                 : UoM_ToString := 'ms';
	    UOM#MICROSECOND                                 : UoM_ToString := '';
	    UOM#MICROMETER                                  : UoM_ToString := '';
	    UOM#MILLIMETER                                  : UoM_ToString := '';
	    UOM#CENTIMETER                                  : UoM_ToString := '';
	    UOM#METER                                       : UoM_ToString := '';
	    UOM#KILOMETER                                   : UoM_ToString := '';
	    UOM#INCH                                        : UoM_ToString := '';
	    UOM#FOOT                                        : UoM_ToString := '';
	    UOM#MILE                                        : UoM_ToString := '';
	    UOM#YARD                                        : UoM_ToString := '';
	    UOM#MILLIGRAM                                   : UoM_ToString := '';
	    UOM#GRAM                                        : UoM_ToString := '';
	    UOM#KILOGRAM                                    : UoM_ToString := '';
	    UOM#OUNCE                                       : UoM_ToString := '';
	    UOM#POUND                                       : UoM_ToString := '';
	    UOM#TON                                         : UoM_ToString := '';
	    UOM#TON_REFRIGERATION                           : UoM_ToString := '';
	    UOM#POUND_MASS                                  : UoM_ToString := '';
	    UOM#POUND_FORCE                                 : UoM_ToString := '';
	    UOM#SQUARE_METER                                : UoM_ToString := '';
	    UOM#SQUARE_KILOMETER                            : UoM_ToString := '';
	    UOM#SQUARE_FOOT                                 : UoM_ToString := '';
	    UOM#SQUARE_INCH                                 : UoM_ToString := '';
	    UOM#SQUARE_MILE                                 : UoM_ToString := '';
	    UOM#SQUARE_YARD                                 : UoM_ToString := '';
	    UOM#HECTARE                                     : UoM_ToString := '';
	    UOM#ACRE                                        : UoM_ToString := '';
	    UOM#MILLILITER                                  : UoM_ToString := '';
	    UOM#CENTILITER                                  : UoM_ToString := '';
	    UOM#LITER                                       : UoM_ToString := '';
	    UOM#CUBIC_METER                                 : UoM_ToString := '';
	    UOM#CUBIC_FOOT                                  : UoM_ToString := '';
	    UOM#CUBIC_INCH                                  : UoM_ToString := '';
	    UOM#IMPERIAL_GALLON                             : UoM_ToString := '';
	    UOM#US_GALLON                                   : UoM_ToString := '';
        UOM#CELSIUS                                     : UoM_ToString := '$008E'; //'$00DFC';
	    UOM#TENTHS_CELSIUS                              : UoM_ToString := '';
	    UOM#FAHRENHEIT                                  : UoM_ToString := '°F';
	    UOM#KELVIN                                      : UoM_ToString := 'K';
	    UOM#DELTAKELVIN                                 : UoM_ToString := 'K';
	    UOM#DELTAFAHRENHEIT                             : UoM_ToString := '';
	    UOM#CELSIUS_PER_HOUR                            : UoM_ToString := '';
	    UOM#CELSIUS_PER_MINUTE                          : UoM_ToString := '';
	    UOM#FAHRENHEIT_PER_HOUR                         : UoM_ToString := '';
	    UOM#FAHRENHEIT_PER_MINUTE                       : UoM_ToString := '';
	    UOM#ATMOSPHERE                                  : UoM_ToString := '';
	    UOM#BAR                                         : UoM_ToString := 'bar';
	    UOM#TENTHS_BAR                                  : UoM_ToString := '';
	    UOM#MILLIBAR                                    : UoM_ToString := '';
	    UOM#PSI                                         : UoM_ToString := 'psi';
	    UOM#PASCAL                                      : UoM_ToString := 'Pa';
	    UOM#HECTOPASCAL                                 : UoM_ToString := '';
	    UOM#KILOPASCAL                                  : UoM_ToString := '';
	    UOM#WATER_CENTIMETER                            : UoM_ToString := '';
	    UOM#WATER_INCH                                  : UoM_ToString := '';
	    UOM#MERCURY_MILLIMETER                          : UoM_ToString := '';
	    UOM#MERCURY_CENTIMETER                          : UoM_ToString := '';
	    UOM#MERCURY_INCH                                : UoM_ToString := '';
	    UOM#PRESSURE_PASCAL                             : UoM_ToString := '';
	    UOM#PRESSURE_WATER_INCH                         : UoM_ToString := '';
	    UOM#PERCENT                                     : UoM_ToString := '%';
	    UOM#TENTHS_PERCENT                              : UoM_ToString := '';
	    UOM#MILLIOHM                                    : UoM_ToString := 'mohm';
	    UOM#OHM                                         : UoM_ToString := '';
	    UOM#KILOOHM                                     : UoM_ToString := '';
	    UOM#MEGAOHM                                     : UoM_ToString := '';
	    UOM#MILLIVOLT                                   : UoM_ToString := '';
	    UOM#VOLT                                        : UoM_ToString := 'V';
	    UOM#MEGAVOLT                                    : UoM_ToString := '';
	    UOM#MILLIAMPERE                                 : UoM_ToString := '';
	    UOM#AMPERE                                      : UoM_ToString := 'A';
	    UOM#VOLT_AMPERE                                 : UoM_ToString := 'mA';
	    UOM#KILOVOLT_AMPERE                             : UoM_ToString := '';
	    UOM#MEGAVOLT_AMPERE                             : UoM_ToString := '';
	    UOM#MICROSIEMENS                                : UoM_ToString := '';
	    UOM#MILLISIEMENS                                : UoM_ToString := '';
	    UOM#SIEMENS                                     : UoM_ToString := '';
	    UOM#VOLT_AMPERE_REACTIVE                        : UoM_ToString := '';
	    UOM#KILOVOLT_AMPERE_REACTIVE                    : UoM_ToString := '';
	    UOM#MEGAVOLT_AMPERE_REACTIVE                    : UoM_ToString := '';
	    UOM#NEWTON                                      : UoM_ToString := '';
	    UOM#NEWTON_METER                                : UoM_ToString := '';
	    UOM#POUND_FOOT                                  : UoM_ToString := '';
	    UOM#POUND_PER_SQUARE_INCH                       : UoM_ToString := '';
	    UOM#POUND_FORCE_PER_SQUARE_INCH                 : UoM_ToString := '';
	    UOM#MILLIWATT                                   : UoM_ToString := '';
	    UOM#WATT                                        : UoM_ToString := 'W';
	    UOM#KILOWATT                                    : UoM_ToString := 'kW';
	    UOM#MEGAWATT                                    : UoM_ToString := 'MW';
	    UOM#WATT_HOUR                                   : UoM_ToString := 'MWh';
	    UOM#KILOWATT_HOUR                               : UoM_ToString := 'kWh';
	    UOM#MEGAWATT_HOUR                               : UoM_ToString := '';
	    UOM#WATT_PER_SQUARE_METER                       : UoM_ToString := '';
	    UOM#WATT_PER_SQUARE_FOOT                        : UoM_ToString := '';
	    UOM#HORSEPOWER                                  : UoM_ToString := '';
	    UOM#THERMAL_POWER_BTU                           : UoM_ToString := '';
	    UOM#THERMAL_POWER_BTU_PER_HOUR                  : UoM_ToString := '';
	    UOM#REFRIGERATION_POWER_KILOWATT                : UoM_ToString := '';
	    UOM#THERMAL_POWER_WATT                          : UoM_ToString := '';
	    UOM#ELECTRICAL_POWER_WATT                       : UoM_ToString := '';
	    UOM#JOULE                                       : UoM_ToString := '';
	    UOM#KILOJOULE                                   : UoM_ToString := '';
	    UOM#MEGAJOULE                                   : UoM_ToString := '';
	    UOM#JOULE_PER_KELVIN                            : UoM_ToString := '';
	    UOM#KILOJOULE_PER_KELVIN                        : UoM_ToString := '';
	    UOM#MEGAJOULE_PER_KELVIN                        : UoM_ToString := '';
	    UOM#JOULE_PER_KILOGRAM_KELVIN                   : UoM_ToString := '';
	    UOM#JOULE_SECOND                                : UoM_ToString := '';
	    UOM#JOULE_PER_SECOND                            : UoM_ToString := '';
	    UOM#JOULE_PER_GRAM                              : UoM_ToString := '';
	    UOM#JOULE_PER_KILOGRAM                          : UoM_ToString := '';
	    UOM#KILOJOULE_PER_KILOGRAM                      : UoM_ToString := '';
	    UOM#MEGAJOULE_PER_KILOGRAM                      : UoM_ToString := '';
	    UOM#BTU                                         : UoM_ToString := '';
	    UOM#KILOBTU                                     : UoM_ToString := '';
	    UOM#MEGABTU                                     : UoM_ToString := '';
	    UOM#KILOBTU_PER_HOUR                            : UoM_ToString := '';
	    UOM#BTU_PER_POUND                               : UoM_ToString := '';
	    UOM#BTU_PER_HOUR                                : UoM_ToString := '';
	    UOM#CALORIE                                     : UoM_ToString := '';
	    UOM#KILOCALORIE_PER_KILOGRAM                    : UoM_ToString := '';
	    UOM#LUMEN                                       : UoM_ToString := '';
	    UOM#LUX                                         : UoM_ToString := '';
	    UOM#FOOT_CANDLE                                 : UoM_ToString := '';
	    UOM#CANDELA                                     : UoM_ToString := '';
	    UOM#CANDELA_PER_SQUARE_METER                    : UoM_ToString := '';
	    UOM#GRAM_KELVIN                                 : UoM_ToString := '';
	    UOM#KILOGRAM_KELVIN                             : UoM_ToString := '';
	    UOM#ENTALPHY_KILOJOULE                          : UoM_ToString := '';
	    UOM#ENTALPHY_BTU                                : UoM_ToString := '';
	    UOM#DRY_AIR_KILOGRAM                            : UoM_ToString := '';
	    UOM#DRY_AIR_POUND                               : UoM_ToString := '';
	    UOM#KILOJOULE_PER_DRY_AIR_KILOGRAM              : UoM_ToString := '';
	    UOM#MEGAJOULE_PER_DRY_AIR_KILOGRAM              : UoM_ToString := '';
	    UOM#ENTALPHY_KILOJOULE_PER_KILOGRAM             : UoM_ToString := '';
	    UOM#ENTALPHY_BTU_PER_POUND                      : UoM_ToString := '';
	    UOM#JOULE_PER_DRY_AIR_KILOGRAM                  : UoM_ToString := '';
	    UOM#BTU_PER_DRY_AIR_POUND                       : UoM_ToString := '';
	    UOM#METER_PER_SECOND                            : UoM_ToString := '';
	    UOM#METER_PER_MINUTE                            : UoM_ToString := '';
	    UOM#KILOMETER_PER_HOUR                          : UoM_ToString := '';
	    UOM#FOOT_PER_SECOND                             : UoM_ToString := '';
	    UOM#FOOT_PER_MINUTE                             : UoM_ToString := '';
	    UOM#MILE_PER_HOUR                               : UoM_ToString := '';
	    UOM#RPS                                         : UoM_ToString := 'rps';
	    UOM#RPM                                         : UoM_ToString := 'rpm';
	    UOM#HERTZ                                       : UoM_ToString := 'Hz';
	    UOM#KILOHERTZ                                   : UoM_ToString := '';
	    UOM#MEGAHERTZ                                   : UoM_ToString := '';
	    UOM#CUBIC_METER_PER_SECOND                      : UoM_ToString := '';
	    UOM#CUBIC_METER_PER_MINUTE                      : UoM_ToString := '';
	    UOM#CUBIC_METER_PER_HOUR                        : UoM_ToString := '';
	    UOM#CUBIC_FOOT_PER_HOUR                         : UoM_ToString := '';
	    UOM#CUBIC_FOOT_PER_MINUTE                       : UoM_ToString := '';
	    UOM#CUBIC_FOOT_PER_SECOND                       : UoM_ToString := '';
	    UOM#IMPERIAL_GALLON_PER_SECOND                  : UoM_ToString := '';
	    UOM#IMPERIAL_GALLON_PER_MINUTE                  : UoM_ToString := '';
	    UOM#US_GALLON_PER_SECOND                        : UoM_ToString := '';
	    UOM#US_GALLON_PER_MINUTE                        : UoM_ToString := '';
	    UOM#US_GALLON_PER_HOUR                          : UoM_ToString := '';
	    UOM#LITER_PER_SECOND                            : UoM_ToString := '';
	    UOM#LITER_PER_MINUTE                            : UoM_ToString := '';
	    UOM#LITER_PER_HOUR                              : UoM_ToString := '';
	    UOM#TON_HOUR                                    : UoM_ToString := '';
	    UOM#TON_PER_HOUR                                : UoM_ToString := '';
	    UOM#GRAM_PER_SECOND                             : UoM_ToString := '';
	    UOM#GRAM_PER_MINUTE                             : UoM_ToString := '';
	    UOM#GRAM_PER_HOUR                               : UoM_ToString := '';
	    UOM#KILOGRAM_PER_SECOND                         : UoM_ToString := '';
	    UOM#KILOGRAM_PER_MINUTE                         : UoM_ToString := '';
	    UOM#KILOGRAM_PER_HOUR                           : UoM_ToString := '';
	    UOM#POUND_PER_MINUTE                            : UoM_ToString := '';
	    UOM#POUND_PER_HOUR                              : UoM_ToString := '';
	    UOM#GRAM_PER_KILOGRAM                           : UoM_ToString := '';
	    UOM#TENTHS_GRAM_PER_KILOGRAM                    : UoM_ToString := '';
	    UOM#KILOGRAM_PER_CUBIC_METER                    : UoM_ToString := '';
	    UOM#AIR_FLOW_CUBIC_METER                        : UoM_ToString := '';
	    UOM#AIR_FLOW_CUBIC_FOOT                         : UoM_ToString := '';
	    UOM#AIR_FLOW_CUBIC_METER_PER_HOUR               : UoM_ToString := '';
	    UOM#AIR_FLOW_CUBIC_FOOT_PER_MINUTE              : UoM_ToString := '';
	    UOM#WATER_KILOGRAM_PER_DRY_AIR_KILOGRAM         : UoM_ToString := '';
	    UOM#TENTHS_WATER_KILOGRAM_PER_DRY_AIR_KILOGRAM  : UoM_ToString := '';
	    UOM#PERCENT_rH                                  : UoM_ToString := '%rH';
	    UOM#TENTHS_PERCENT_rH                           : UoM_ToString := '';
	    UOM#WATER_KILOGRAM                              : UoM_ToString := '';
	    UOM#WATER_GRAM                                  : UoM_ToString := '';
	    UOM#WATER_GRAM_PER_DRY_AIR_KILOGRAM             : UoM_ToString := '';
	    UOM#TENTHS_WATER_GRAM_PER_DRY_AIR_KILOGRAM      : UoM_ToString := '';
	    UOM#DELTACELSIUS                                : UoM_ToString := '$008E';
	    UOM#HENRY                                       : UoM_ToString := '';
	    UOM#MILLIHENRY                                  : UoM_ToString := 'mH';
	    UOM#PPM                                         : UoM_ToString := 'ppm';
	    UOM#PPB                                         : UoM_ToString := 'ppb';
	    UOM#HERTZ_PER_SECOND                            : UoM_ToString := 'Hz/s';
	    UOM#CYCLE_PER_SECOND                            : UoM_ToString := '';
	    UOM#STEPS                                       : UoM_ToString := 'step';
    END_CASE;
END_FUNCTION