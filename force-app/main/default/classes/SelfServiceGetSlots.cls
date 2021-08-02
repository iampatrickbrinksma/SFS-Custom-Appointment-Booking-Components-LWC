/**
 * Purpose: 
 * IMPORTANT: This code is not intended to be deployed to a Salesforce production environment.
 * It is intended as an example of how to book an appointment on a Salesforce Community / Experience Site
 * 
 * Author: Patrick Brinksma (Salesforce)
 * Source and inspiration: https://unofficialsf.com/flow-scheduler-enable-self-service-scheduling-for-field-service/
 * 
 */
// Class is without sharing to avoid data sharing issues for community user
public without sharing class SelfServiceGetSlots {

    // Invocable method to be used in a Salesforce Flow to get booking slots
    // for a given appointment and parameters
    @InvocableMethod(label='Get Booking Slots using FSL.AppointmentBookingService.getSlots')
    public static List<GetSlotsResponse> getSlots(List<GetSlotsRequest> requests) {
        // Response;
        GetSlotsResponse response; 
        try {
            // This method will NOT run in bulk, so getting the single request
            GetSlotsRequest request = requests[0];
            // Timezone for the AppointmentBookingService
            TimeZone tz;
            // If no Service Territory was provided, use the current running user's timezone
            // otherwise get it from the Service Territory!
            if (request.serviceTerritoryId == null || request.serviceTerritoryId == '' || String.isBlank(request.serviceTerritoryId)){
                tz = Userinfo.getTimeZone();
            } else {
                ServiceTerritory territory = SelfServiceUtil.getTerritory(request.serviceTerritoryId);
                tz = TimeZone.getTimeZone(territory.OperatingHours.TimeZone);
            }
            // Retrieve the booking slots using the AppointmentBookingService class in the FSL Namespace
            // See: https://developer.salesforce.com/docs/atlas.en-us.field_service_dev.meta/field_service_dev/apex_class_FSL_AppointmentBookingService.htm#apex_class_FSL_AppointmentBookingService
            List<FSL.AppointmentBookingSlot> slots = FSL.AppointmentBookingService.getSlots(
                request.serviceAppointmentId, 
                request.schedulingPolicyId, 
                request.operatingHoursId, 
                tz, 
                request.useExactAppointment
            );
            // Process response
            List<SelfServiceBookingSlot> returnSlots = new List<SelfServiceBookingSlot>();       
            // If no slots were found, return a message
            // Otherwise convert the slots into a format that is used by the LWC
            if (slots.size() == 0){
                response = new GetSlotsResponse();
            } else {
                for (FSL.AppointmentBookingSlot slot : slots) {
                    returnSlots.add(new SelfServiceBookingSlot(
                        slot.grade,
                        SelfServiceUtil.changeTimeZoneToGmt(slot.interval.start, tz),
                        SelfServiceUtil.changeTimeZoneToGmt(slot.interval.finish, tz)
                    ));
                }
                // Construct response
                response = new GetSlotsResponse(returnSlots, tz);
            }
            return new List<GetSlotsResponse>{response};
        } catch (SelfServiceUtil.SelfServiceException e) {
            // return error
            response = new GetSlotsResponse(e.getMessage());
            return new List<GetSlotsResponse>{response};
        }
    }
    
    // Request structure
    public class GetSlotsRequest {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;

        @InvocableVariable (label='2. Service Territory ID' required=false)
        public String serviceTerritoryId;

        @InvocableVariable (label='3. Scheduling Policy ID' required=true)
        public String schedulingPolicyId;

        @InvocableVariable (label='4. Operating Hours ID' required=true)
        public String operatingHoursId;

        @InvocableVariable (label='5. Use Exact Appointment' required=true)
        public Boolean useExactAppointment;        
    }

    // Response structure
    public class GetSlotsResponse {
        @InvocableVariable(label='Matching Slots') 
        public List<SelfServiceBookingSlot> slots;

        @InvocableVariable(label='Timezone Id')
        public String timeZoneId;

        @InvocableVariable(label='Timezone Name')
        public String timeZoneName;

        @InvocableVariable(label='Error message')
        public String error;

        public GetSlotsResponse() {}

        public GetSlotsResponse(List<SelfServiceBookingSlot> slots, TimeZone tz) {
            this.slots = slots;
            this.timeZoneId = tz.getID();
            this.timeZoneName = tz.getDisplayName();
        }

        public GetSlotsResponse(String error) {
            this.error = error;
        }
    }
}