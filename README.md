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

### Flow Parameters

The main component is the "Self Service Appointment Booking" screen flow which has the following input variables. Most of them have default values, which you can adjust or overwrite by providing values:

Name | Type | Purpose | Default value
--- | --- | --- | ---
recordId | Text | Record Id of the Service Appointment. This is automatically passed in to the Flow when the Quick Action is put on the object's page layout. | 
VAR_ExtendHorizonWithNumberOfDays | Number | Number of days with which the scheduling horizon is extended if no available time slots are found, which results in the Earliest Start Permited and Due Date of the Service Appointment to be increased with this value. | 7
VAR_MaxAllowedHorizonExtensions | Number  | Number of allowed extensions of the scheduling horizon. If this number is exceeded, a message is displayed. | 3
VAR_OperatingHoursName | Text | Name of the Operating Hours to use for the available time slots. As the name field is not unique, when multiple records exist, the first one is used. | Gold Appointments Calendar
VAR_SchedulingPolicyName | Text | Scheduling Policy used to get available time slots and schedule the appointment. As the name field is not unique, when multiple records exist, the first one is used. | Customer First
VAR_ServiceAppointmentId | Text | Record Id of the Service Appointment. This value is overwitten by the recordId variable. | 
VAR_ShowNumberOfDays | Number | Number of days to show in the day picker in the LWC component | 7
VAR_UseExactAppointments | Boolean | Use exact appointments when getting available time slots and scheduling the appointment | FALSE

### How To Use

The following screenshots show an example of how to use the screen flow in an Experience Site with an authenticated user which has the permissions as described earlier in this document. The Experience Site is a very basic setup exposing the Service Appointments on which the user is the contact person. The Service Appointment Page Layout shows the button to start the flow as shown in the screenshot below.

![image](https://user-images.githubusercontent.com/78381570/127971717-d29eec58-87b5-405d-8cb6-8a2ded1f129f.png)

The flow will first perform some Get Record(s) actions to retrieve data that is needed to show available time slots and schedule the appointment. If a record cannot be found, a message is shown what data could not be found. The flow retrieves the following information:

* Service Appointment - including a validation if the Service Appointment has a Service Territory
* Scheduling Policy
* Operating Hours

If all the data can be found, a screen is shown to indicate that available time slots will be retrieved and the planned duration of the appointment.

![image](https://user-images.githubusercontent.com/78381570/127971808-b80f2fa8-75e7-444b-9c11-726bfe14fef3.png)

In the next screen the available time slots are shown. This is a Lightning Web Component which can be tailored to the customer's specific requirements. In this example solution the days which have available time slots are shown on the top, and the user can select a day and see which time slots are available. The number of days shown at once can be configured by the Flow parameter "VAR_ShowNumberOfDays", and if more days are shown than fit in the screen, the user can scroll to the right and left. The arrows can be used to see days in the future or navigate back to earlier days.

*Note: The number of days for which available time slots are retrieved are determined by the time horizon on the appointment (Earliest Start Permitted and Due Date) and the value of the "Maximum days to get candidates or to book an appointment" setting (Field Service Settings → Scheduling → General Logic).*

![image](https://user-images.githubusercontent.com/78381570/127972086-8655d7fa-d74d-470c-ba94-068bf6c8a904.png)

The user can select a time slot by clicking on it. When the user clicks Next, the flow will update the Service Appointment record Arrival Window Start and Arrival Window End fields with the selected times and schedule the appointment. This is performed in two separate steps to allow the schedule logic to run in its own transaction. This allows Field Service to make a callout to perform travel time calculations for SLR or P2P.
If the user's time zone differs from that of the service territory assigned to the service appointment, a message is displayed below the time slots indicating in which time zone the slots are displayed.
The "Extend search for available time slots" allows the user to extend the time horizon to a date in the future. How many days in the future is determined by the flow input variable "VAR_ExtendHorizonWithNumberOfDays". Furthermore, the maximum number of times the user can extend the search can be configured by setting the flow input variable "VAR_MaxAllowedHorizonExtensions".

Once the appointment is scheduled a screen is shown with the confirmation of when a technician will arrive at the customer.

![image](https://user-images.githubusercontent.com/78381570/127972348-b43e643b-d6b5-4f65-99c7-28dc19f3d68b.png)

In the scenario where there are no available time slots, the following screen is shown allowing the user to extend the search into the future. There is also "Debug" which can be extended to allow for debugging why no time slots where found. In the example solution it only confirms if the service territory has any members, but this can be extended to additional validations.

![image](https://user-images.githubusercontent.com/78381570/127972553-6c3f6e71-6c33-4181-85a4-71c44aebd208.png)

If the user has extended the search more times than allowed, the following screen will be shown.

![image](https://user-images.githubusercontent.com/78381570/127972598-55085ccd-98b0-4ccd-b028-84311ca769ec.png)

If the user has selected a time slot and then schedules the appointment, and the time slot is not available anymore (in case appointments are scheduled concurrently), the following screen will be shown providing the user with the choice to select a different time slot. The flow will retrieve available time slots again and present them.

![image](https://user-images.githubusercontent.com/78381570/127972640-61af05a0-156c-4acd-a2e0-9419ac8931d9.png)

## Considerations

* To be able to access the necessary data for scheduling, the flow runs in the "System Context Without Sharing—Access All Data" context. This means that any service appointment record can be accessed providing that a valid record id is passed to the flow. Take into consideration any additional validations that can be included in the flow to validate if the user can actually book the appointment.
* When extending the search, the flow updates the Earliest Start Permitted and the Due Date of the service appointment. The flow does remember the original values, and will update them back if the user steps through the flow steps. If the user decides to exit the flow, consider that the field values are not updated to their original values.
* Field Service makes a callout to calculate travel times when using SLR or P2P. It does that when using the on-platform scheduling actions (Book Appointment, Candidates, Emergency, Schedule on Gantt) or when using the methods which are part of the Apex Classes in the FSL Namespace (https://developer.salesforce.com/docs/atlas.en-us.field_service_dev.meta/field_service_dev/apex_namespace_FSL.htm): AppointmentBookingService, GradeSlotsService and ScheduleService. The Salesforce platform does not allow a callout when there are pending transactions (e.g. DML). This is the reason that the action to update the arrival window on the appointment and the action to schedule the appointment are separated. Salesforce Flow provides the ability to commit changes before executing an Apex Action. Both the GetSlots and Schedule Apex Actions are starting a new transaction to allow travel time calculations.
* This example solution has not been thoroughly tested with users in different time zones. The Apex Classes do consider time zones, and convert date time values accordingly. 
* This example solution has not been tested on a mobile device. The responsiveness of the Lightning Web Component needs to be tested and adjusted accordingly.
* This example solution is not production-ready. For example, Apex Test classes need to be written for code coverage.





