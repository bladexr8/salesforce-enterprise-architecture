import { LightningElement, track, api, wire } from 'lwc';
import RACE_OBJECT from '@salesforce/schema/Race__c';
import STATUS_FIELD from '@salesforce/schema/Race__c.Status__c';
import FASTESTLAPBY_FIELD from '@salesforce/schema/Race__c.FastestLapBy__c';
import getRace from '@salesforce/apex/FLSDemoController.getRace';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class FlsDemo extends LightningElement {

  raceObject = RACE_OBJECT;
  statusField = STATUS_FIELD;
  fastestLapByField = FASTESTLAPBY_FIELD;
  @api recordId;
  @api objectApiName;
  @track activeSections = ['A', 'B', 'C', 'D', 'E', 'F'];
  @track race = {STATUS_FIELD: null, FASTESTLAPBY_FIELD: null};
  @track status;
  @track fastestLapBy;
  @wire(getObjectInfo, { objectApiName: RACE_OBJECT}) objectInfo;

  

}