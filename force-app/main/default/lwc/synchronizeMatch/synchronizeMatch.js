import { LightningElement,track,api } from 'lwc';
import getMatchForSObject from '@salesforce/apex/MatchMethods.getMatchForSObject';
import getMatchNumber from '@salesforce/apex/MatchMethods.getMatchNumber';

const columns = [
    { label: 'Compte Pro',
      fieldName: 'AccountURL',
      type: 'url', 
      typeAttributes: {label: { fieldName: 'AccountName' }, target: '_self', tooltip: { fieldName: 'AccountName' }},
      sortable: true
    },
    { label: 'Projet', 
      fieldName: 'ProjectURL', 
      type: 'url' ,
      typeAttributes: {label: { fieldName: 'ProjectName' }, target: '_self', tooltip: { fieldName: 'ProjectName' } },
      sortable: true
    },
    { label: 'Besoin travaux', 
      fieldName: 'BesoinTravauxURL', 
      type: 'url' ,
      typeAttributes: {label: { fieldName: 'BesoinTravauxName' }, target: '_self', tooltip: { fieldName: 'BesoinTravauxName' } },
      sortable: true
    },
    { label: 'Statut du match', 
      fieldName: 'Status', 
      type: 'picklist', 
      sortable: true 
    },
    { label: 'Positionnabilité', 
      fieldName: 'positionable', 
      type: 'boolean', 
      sortable: true
    },
    { label: 'Visibilité', 
      fieldName: 'viewable', 
      type: 'boolean', 
      sortable: true
    },
    { label: 'Nombre de positionné', 
    fieldName: 'positionedCount', 
    type: 'Integer', 
    sortable: true
    },
    { label: 'Compte Part', 
      fieldName: 'PartURL', 
      type: 'url' ,
      typeAttributes: {label: { fieldName: 'PartName' }, target: '_self', tooltip: { fieldName: 'PartName' } },
      sortable: true
    },
    { label: 'Date du match', 
      fieldName: 'createdAt', 
      type: 'date', 
      typeAttributes: {day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false },        
      sortable: true
    },
 
];

export default class SynchronizeMatch extends LightningElement {
	
	@api recordId;
    @track showLoadingSpinner = true;
    @track showError = false;
    @track displayTable = false;
    @track iconName = 'progress-ring';
    @track data;
    @track error;
    @track columns = columns;
    @track sortBy;
    @track sortDirection;
    @track nombreDeMatch;

    connectedCallback() {
        getMatchForSObject({objectId : this.recordId})
            .then(result => {
                this.showLoadingSpinner = false;
                this.showError = false;
                this.displayTable = true;
                var str = JSON.stringify(this.recordId);
                if(str.indexOf('001') == 1) {
                    this.columns = this.columns.filter(col => col.fieldName != 'AccountURL');
                } else {
                    this.columns = this.columns.filter(col => col.fieldName != 'ProjectURL');                  
                    this.columns = this.columns.filter(col => col.fieldName != 'BesoinTravauxURL');       
                    this.columns = this.columns.filter(col => col.fieldName != 'positionedCount');       
                    this.columns = this.columns.filter(col => col.fieldName != 'PartURL');       
                }
                this.data = result;

                getMatchNumber({objectId : this.recordId})
                .then( result => { this.nombreDeMatch = result;
                    if(result == "  Nombre total de matchs : 0") {
                        this.displayTable = false;
                    }
                });
            })
            .catch(error => {
                this.error = error;
                this.showError = true;
                this.showLoadingSpinner = false;
                this.displayTable = false;
            });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }
}