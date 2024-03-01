import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import refreshRaceResults from '@salesforce/messageChannel/RefreshRaceResults__c';
import getRaceCalendar from '@salesforce/apex/RaceCalendarComponentController.getRaceCalendar';

export default class RaceCalendar extends LightningElement {

  @wire(getRaceCalendar)
  calendar;
  currentlySelectedRace;
  @wire(MessageContext)
  messageContext;

  handleSelect(event) {
    console.log('***Race Selected...');
    // Determine selected Race details
    const raceId = event.detail;
    const selectedRace = this.calendar.data.find(race => race.Id === raceId);
    const raceName = selectedRace.Name;
    console.log(raceId);
    console.log(selectedRace);
    console.log(raceName);
    // Toggle selected race
    if (this.currentlySelectedRace != null) {
      this.currentlySelectedRace.selected = false;
    }
    this.currentlySelectedRace = event.currentTarget;
    this.currentlySelectedRace.selected = true;
    // Send refreshRaceResults component message 
    const payload = { raceId: raceId, raceName: raceName };
    console.log(payload)
;    publish(this.messageContext, refreshRaceResults, payload);
  }
}