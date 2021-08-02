// SelfServiceShowBookingSlots.js
import { LightningElement, api, wire, track } from 'lwc';

// Import to use component in Flow
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

// Support timezones
import USER_TIMEZONE from '@salesforce/i18n/timeZone';

// Import custom labels
import customlabelNoSlotsAvailable from '@salesforce/label/c.No_Slots_Available';
import customlabelSlotsInTimeZone from '@salesforce/label/c.Slots_Are_In_Timezone';

// Constants 
const ITEM_CLASS = 'timeslot';
const SELECTED_CLASS = 'selected';

export default class SelfServiceShowBookingSlots extends LightningElement {

    /**
     * In- and Output properties from Flow
     */

    // Error message
    // Input variable from Flow
    @api error;

    // Slots 
    // Input variable from Flow
    @api slots = [];

    // Timezone
    // Input variable from Flow
    @api timezoneId;
    @api timezoneName;

    // Number of days to show in the day picker
    // Input variable from Flow
    @api showNumberOfDays = 7;

    // Selected start- and endtime
    // Output variables for Flow
    @api startTime;
    @api endTime;

    /**
     * Custom labels
     */
    
    // Expose the labels to use in the template
    label = {
        customlabelNoSlotsAvailable,
        customlabelSlotsInTimeZone
    }; 

    /**
     * Properties
     */

    // A clone of slots, as once the FlowAttributeChangeEvent event is dispatched
    // it seems that slots returns to its original value of when the component was
    // build up (connectedCallback). Not sure if that is expected behavior.
    @track timeslots = [];

    // Selected time slot
    @track selectedSlot;

    // Days to display for selection
    @track timeSlotDays;

    // Total number of days for which timeslots are available
    totalNumOfDays;

    // Index for pagination
    timeSlotDaysIndex = 0;

    // Day that is selected
    selectedDay;   
    
    // Selected time slot
    get selectedSlotIndex() {
        return this._selectedSlotIndex;
    }
    set selectedSlotIndex(value) {
        this._selectedSlotIndex = value;
        this.selectedSlot = value ? this.timeslots[value] : null;
    }
    _selectedSlotIndex;

    // Return the time slots that 
    // are part of the selected day
    get displayedSlots() {
        let slots = [];
        for (let timeslot of this.timeslots){
            if (timeslot.day === this.selectedDay){
                slots.push(timeslot);
            }
        }
        return slots;
    }

    // Indicates if there are time slots
    // covering multiple days
    get multipleDays(){
        return this.totalNumOfDays > 1;
    }

    // When to show the previous days navigation
    get showPrevDaysNav(){
        return this.timeSlotDaysIndex >= this.showNumberOfDays;
    }

    // When to show the next days navigation
    get showNextDaysNav(){
        return this.timeSlotDaysIndex + this.showNumberOfDays < this.totalNumOfDays;
    }

    // User time zone
    get userTimezone() {
        return USER_TIMEZONE;
    }

    // Display time zone when User and Service territory have different time zones
    get displayTimeZone(){
        return String(USER_TIMEZONE) !== String(this.timezoneId);
    }

    /**
     * Component Lifecycle
     */

    connectedCallback() {
        // Build timeslots object from the input slots
        // Create a clone from the input as once the FlowAttributeChangeEvent event is dispatched
        // this.slots returns to its original value
        this.timeslots = [...this.slots];
        let tempSlots = [];
        // Enricht slots with additional information
        for (let i = 0; i < this.timeslots.length; i++) {
            let tempSlot = {
                index: i,
                day: this.convertDateTimeString(new Date(this.timeslots[i].start)),     // Day in string format YYYYMMDD
                firstInDay: i===0 || new Date(this.timeslots[i].start).getDate() !== new Date(this.timeslots[i-1].start).getDate(),
            }
            tempSlots.push(Object.assign(tempSlot, this.timeslots[i]));
        }
        this.timeslots = tempSlots;

        // select first day as default
        if (this.timeslots.length) {
            this.selectedDay = this.timeslots[0].day;
            this.setTimeSlotDays();
        }
    }    

    /**
     * Functions
     */

    // Flow validation which is executed when
    // the user presses the Next button
    // see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_flow_validate_user_input_for_custom_components

    // For this example, the validate is not used, so we can validate the output in Flow and act accordingly
    /*
    @api
    validate() {
        // If a slot is selected, or there are not slots available
        if (this.selectedSlot || 
            (this.timeslots.length && this.timeslots.length == 0)) {
            return { 
                isValid: true 
            };
        } else {
            // Return error message to display (Flow)
            return { 
                isValid: false,
                errorMessage: this.label.customlabelPleaseSelectASlot
            };
        }
    }
    */

    // Converts a datetime string to YYYYMMDD
    convertDateTimeString(dtAsString){
        let dt = new Date(dtAsString);
        var mm = dt.getMonth() + 1; // getMonth() is zero-based
        var dd = dt.getDate();
      
        return [dt.getFullYear(),
                (mm>9 ? '' : '0') + mm,
                (dd>9 ? '' : '0') + dd
               ].join('');        
    }

    // Days during which there are available time slots
    setTimeSlotDays() {
        let horizonDays = [];
        for (let i = 0; i < this.timeslots.length; i++) {
            if (i===0 || this.timeslots[i].day !== this.timeslots[i-1].day){
                horizonDays.push(
                    {
                        day: new Date(this.timeslots[i].start),
                        dayDate: this.timeslots[i].day,
                        isSelected: this.timeslots[i].day === this.selectedDay
                    }
                );
            }
        }
        this.totalNumOfDays = horizonDays.length;
        this.timeSlotDays = horizonDays.slice(this.timeSlotDaysIndex, this.timeSlotDaysIndex + this.showNumberOfDays);
    }    

    // When a time slot is selected remember the
    // selected index, the selected slot and update the
    // Flow properties. Also make sure only the selected
    // time slot has the selected class to highlight the slot
    handleSelectSlot(event){
        let selectedIndex = event.target.dataset.index;
        if (this.selectedSlotIndex === selectedIndex) {
            this.selectedSlotIndex = null;
        } else {
            this.selectedSlotIndex = selectedIndex;       
        }

        this.template.querySelectorAll('div.' + ITEM_CLASS).forEach(item => {
            if (item.dataset.index === this.selectedSlotIndex){
                item.classList.add(SELECTED_CLASS);
            } else {
                item.classList.remove(SELECTED_CLASS);
            }
        });

        // Dispatch Flow Attribute changes
        this.dispatchEvent(new FlowAttributeChangeEvent('startTime', this.selectedSlot ? this.selectedSlot.start : null));
        this.dispatchEvent(new FlowAttributeChangeEvent('endTime', this.selectedSlot ? this.selectedSlot.finish : null));
    }

    // Select a specfic day
    selectTimeslotDay(event){
        // Use currentTarget as there are multiple instances of the same element (span)
        this.selectedDay = event.currentTarget.dataset.day;
        // As another day is selected, rebuild
        this.setTimeSlotDays();
    }

    showPrevDays(){
        if (this.timeSlotDaysIndex - this.showNumberOfDays >= 0){
            this.timeSlotDaysIndex = this.timeSlotDaysIndex - this.showNumberOfDays;
            this.setTimeSlotDays();
        }
    }

    showNextDays(){
        if (this.timeSlotDaysIndex + this.showNumberOfDays < this.totalNumOfDays){
            this.timeSlotDaysIndex = this.timeSlotDaysIndex + this.showNumberOfDays;
            this.setTimeSlotDays();
        }
    }

}