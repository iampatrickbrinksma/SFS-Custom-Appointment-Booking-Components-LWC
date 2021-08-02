/**
 * Purpose: 
 * IMPORTANT: This code is not intended to be deployed to a Salesforce production environment.
 * It is intended as an example of how to book an appointment on a Salesforce Community / Experience Site
 * 
 * Author: Patrick Brinksma (Salesforce)
 * Source and inspiration: https://unofficialsf.com/flow-scheduler-enable-self-service-scheduling-for-field-service/
 * 
 */
// Class to schedule an appointment via an Apex Action in Flow. 
public without sharing class SelfServiceScheduleAppointment {

    // Invocable method to call from a flow to schedule an appointment
    @InvocableMethod(label='Schedule Appointment')
    public static List<ScheduleResponse> scheduleAppointment(List<ScheduleRequest> requests) {

        ScheduleRequest request = requests[0];
        ScheduleResponse response = new ScheduleResponse();

        FSL.ScheduleResult scheduleResult = FSL.ScheduleService.schedule(request.schedulingPolicyId, request.serviceAppointmentId);

        if (scheduleResult != null){
            response.status = String.valueOf(scheduleResult);

            ServiceTerritory territory = SelfServiceUtil.getTerritory(scheduleResult.Service.ServiceTerritoryId);
            Timezone tz = TimeZone.getTimeZone(territory.OperatingHours.TimeZone);

            response.schedStart = scheduleResult.Service.SchedStartTime;
            response.schedEnd = scheduleResult.Service.SchedEndTime;
            response.arrWinStart = scheduleResult.Service.ArrivalWindowStartTime;
            response.arrWinEnd = scheduleResult.Service.ArrivalWindowEndTime;
        }

        return new List<ScheduleResponse>{response};
    }

    // Request structure
    public class ScheduleRequest {
        @InvocableVariable (label='1. Service Appointment ID' required=true)
        public String serviceAppointmentId;

        @InvocableVariable (label='2. Scheduling Policy ID' description='Provide a specific Scheduling Policy' required=true)
        public String schedulingPolicyId;
    }

    // Response structure
    public class ScheduleResponse {
        @InvocableVariable (label='1. Result of scheduling the appointment. If null, appointment could not be scheduled!')
        public String status;

        @InvocableVariable (label='2. Scheduled Start')
        public Datetime schedStart;

        @InvocableVariable (label='3. Scheduled End')
        public Datetime schedEnd;
        
        @InvocableVariable (label='4. Arrival Window Start')
        public Datetime arrWinStart;

        @InvocableVariable (label='4. Arrival Window End')
        public Datetime arrWinEnd;
    }
}