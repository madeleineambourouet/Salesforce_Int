import { track, api, LightningElement } from 'lwc';
import callProjectPlaceFrontProjectStatus from '@salesforce/apex/ProjectPlaceWS.callProjectPlaceFrontProjectStatus';

export default class StatutFrontProjetLMSG extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track status;

    connectedCallback() {
        callProjectPlaceFrontProjectStatus({recordId : this.recordId, objectApiName : this.objectApiName })
            .then(result => {
                this.status = result;
            })
            .catch(error => {
                this.status = 'Le statut visible par l\'utilisateur n\'a pu être calculé '
            });
    }
}