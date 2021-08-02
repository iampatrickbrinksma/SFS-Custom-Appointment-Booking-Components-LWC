/**
 * Purpose: 
 * IMPORTANT: This code is not intended to be deployed to a Salesforce production environment.
 * It is intended as an example of how to book an appointment on a Salesforce Community / Experience Site
 * 
 * Author: Patrick Brinksma (Salesforce)
 * Source and inspiration: https://unofficialsf.com/flow-scheduler-enable-self-service-scheduling-for-field-service/
 * 
 */
// Class for input in Lightning Web Component
public class SelfServiceBookingSlot {
    // Grade of the time slot
    @AuraEnabled 
    public Decimal grade;
    // Start time of the time slot
    @AuraEnabled 
    public DateTime start;
    // End time of the time slot
    @AuraEnabled 
    public DateTime finish;
    
    // Constructors
    public SelfServiceBookingSlot(){}

    public SelfServiceBookingSlot(Decimal grade, Datetime start, DateTime finish) {
        this.grade = grade;
        this.start = start;
        this.finish = finish;
    }
}