# SFS Custom Appointment Booking Components

An example of how to allow users to book an appointment on a Salesforce Experience Site (formerly known as Communities). This example uses a combination of Flow, Apex and a Lightning Web Component to allow the user to select an available time slot and schedule the appointment.

## How To Use

The Flow "Self Service Appointment Booking" can be exposed in an Experience Site by adding the Quick Action "Book Appointment (Self Service)" to the page layout assigned to the experience site user. The flow will guide the user through the process after performing some data validations to make sure the user has access to the right data. The scheduling policy and operating hours that are used to get available time slots and schedule the appointment can be provided to the flow as input parameters. The result of the flow is a scheduled appointment with the arrival window as the selected time slots.

### Components

Type | Name | Description
--- | --- | ---
Flow | Self Service Appointment Booking | Screen Flow that guides the user throught the process of appointment booking. The Flow runs in the "System Context Without Sharing—Access All Data" context to allow the user to access the necessary data.
QuickAction | Book Appointment (Self Service) | Action on the Service Appointment object to run the Self Sevice Appointment Booking screen flow.
Apex Class | SelfServiceBookingSlot | Class that defines the structure of an Appointment Booking time slot. This serves as an input parameter for the Lightning Web Component for Flow.
Apex Class | SelfServiceUtil | Utility class with some helper methods
Apex Class | SelfServiceGetSlots | Contains an invocable method that can be called from an Apex Action in Flow to get the available time slots for an appointment
Apex Class | SelfServiceUpdateServiceAppointment | Contains an invocable method that can be called from an Apex Action in Flow to update the appointment Arrival Window with the selected time slot. This is done separate from the actual scheduling to allow for a callout as part of scheduling which enables SLR or P2P to be used for travel time calculation
Apex Class | SelfServiceScheduleAppointment | Contains an invocable method that can be called from an Apex Action in Flow to get schedule an appointment
Lightning Web Component | selfServiceShowBookingSlots | Flow screen component that shows the available slots and allows the user to select a slot
Custom Label | No_Slots_Available | When no slots are passed to the component, display this message.
Custom Label | Slots_Are_In_Timezone | When the user's time zone differs from the service territory operating hours time zone, a message is displayed indicating in which time zone the slots are displayed

### Permissions

The Field Service Managed Package as part of SFS delivers a set of permission sets for the different Field Service personas. One of them is the "Field Service Self Service Permissions" permission set, which provides the necessary permissions for a user with a Community license to book an appointment. 
This example solution has been tested with a user with a profile which is an exact clone of the standard "Customer Community User" profile and the "Field Service Self Service Permissions" permission set assigned.
The user's profile and permission set only provide access to objects and fields. Access to the records needs to be provided either via the sharing capabilities of the platform and/or by running the Flow in the "System Context Without Sharing—Access All Data" context, which is used in this example solution.
To expose the appointment in the Experience Site, a Sharing Set was created including both the Service Appointment and Work Order object providing Read / Write access level on records where the user is the contact person.
