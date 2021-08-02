/**
 * Purpose: 
 * IMPORTANT: This code is not intended to be deployed to a Salesforce production environment.
 * It is intended as an example of how to book an appointment on a Salesforce Community / Experience Site
 * 
 * Author: Patrick Brinksma (Salesforce)
 * Source and inspiration: https://unofficialsf.com/flow-scheduler-enable-self-service-scheduling-for-field-service/
 * 
 */
// Class for updating the Service Appointment via Apex in Flow
// Furthermore, the datetime values get converted to the right time zone
public without sharing class SelfServiceUpdateServiceAppointment {

    @InvocableMethod(label='Update Service Appointment Arrival Window')
    public static void updateAppointment(List<Request> requests) {

        Request request = requests[0];
        
        ServiceAppointment appointment = new ServiceAppointment(Id = request.serviceAppointmentId);
        appointment.ArrivalWindowStartTime = SelfServiceUtil.convertStringToDateTimeGmt(request.startTimeString);
        appointment.ArrivalWindowEndTime = SelfServiceUtil.convertStringToDateTimeGmt(request.endTimeString);
        update appointment;
        
    }

    public class Request {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;

        @InvocableVariable (label= '2. Arrival Window Start Time' description='Get from the output of the Display Booking Slots screen component' required=true)
        public String startTimeString;

        @InvocableVariable (label= '3. Arrival Window End Time' description='Get from the output of the Display Booking Slots screen component' required=true)
        public String endTimeString;
    }

    public class Response {
        @InvocableVariable public String status;
    }

}