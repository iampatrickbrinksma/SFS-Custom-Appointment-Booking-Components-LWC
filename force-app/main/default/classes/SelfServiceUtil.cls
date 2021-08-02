/**
 * Purpose: 
 * IMPORTANT: This code is not intended to be deployed to a Salesforce production environment.
 * It is intended as an example of how to book an appointment on a Salesforce Community / Experience Site
 * 
 * Author: Patrick Brinksma (Salesforce)
 * Source and inspiration: https://unofficialsf.com/flow-scheduler-enable-self-service-scheduling-for-field-service/
 * 
 */
public class SelfServiceUtil {

    // Custom exception class
    public class SelfServiceException extends Exception {}

    // Retrieve Service Territor details provided an Id
    // It returns a single Service Territory record including the Timezone of the related Operating Hours
    // which are used for Appointment Booking
    public static ServiceTerritory getTerritory(String serviceTerritoryId) {
        // Validate input
        if (String.isBlank(serviceTerritoryId)) {
            throw new SelfServiceException('No Service Territory Id entered');
        }
        // Retrieve Territory information
        List<ServiceTerritory> territories = [SELECT OperatingHoursId, OperatingHours.Timezone FROM ServiceTerritory WHERE Id =: serviceTerritoryId];        
        // If we didn't find a valid Service Territory, throw an exception
        if (territories.isEmpty()) {
            throw new SelfServiceException('Service Territory with Id ' + serviceTerritoryId + ' not found');
        }
        // Return territory
        return territories[0];
    }

    // Convert datetime to GMT value according to provided timezone
    public static DateTime changeTimeZoneToGmt(DateTime dt, TimeZone tz) {
        Integer offset = tz.getOffset(dt);
        return DateTime.newInstance(dt.getTime() - offset);
    }

    // Calculate new datetime provided the timezone offset
    public static DateTime getDateTimeForTimeZone(DateTime dt, TimeZone tz) {
        Integer offset = tz.getOffset(dt);
        return DateTime.newInstance(dt.getTime() + offset);
    }

    // Convert DateTime to String according to timezone and format
    public static String convertDateTimeToString(DateTime dt, String format, TimeZone tz){
        String tzId = tz.getID();
        return dt.format(format, tzId);
    }

    // Convert the datetime into the given timezone
    // so the user on the community is presented with slots
    // in the user's timezone
    public static DateTime convertStringToDateTimeGmt(String timeString) {
        return DateTime.valueOfGmt(String.valueOf(JSON.deserialize('"'+ timeString +'"', Datetime.class)));
    }

}