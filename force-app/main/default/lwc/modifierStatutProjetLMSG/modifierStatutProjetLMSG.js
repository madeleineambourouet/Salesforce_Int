import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import PROJECT_LMSG_OBJECT from '@salesforce/schema/Projet_LMSG__c';
import ID_FIELD from '@salesforce/schema/Projet_LMSG__c.Id';
import STATUT_FIELD from '@salesforce/schema/Projet_LMSG__c.Statut__c';
import SOUS_STATUT_FIELD from '@salesforce/schema/Projet_LMSG__c.Sous_statut__c';
import MOTIF_FIELD from '@salesforce/schema/Projet_LMSG__c.Motif__c';
import MOTIF_CLOTURE_FIELD from '@salesforce/schema/Projet_LMSG__c.Motif_cloture_projet__c';

const fields = [STATUT_FIELD, SOUS_STATUT_FIELD, MOTIF_FIELD, MOTIF_CLOTURE_FIELD];

export default class modifierStatutProjetLMSG extends LightningElement {

    @api projectId;
    @track sousStatutOptions;
    @track motifOptions;
    @track motifClotureOptions;
    @track Project ;
    @track disableDepose = true;
    @track disableCloture = true;
    @track ModifProjet = true;
    @track disableMotif = false;
    @track disableSousStatut = false;
    @track disableSave1 = false;
    @track SousStatutValue;

    @wire(getObjectInfo, { objectApiName: PROJECT_LMSG_OBJECT })
    projectInfo;

    @wire(getRecord, { recordId: '$projectId', fields })
        requete({data, error}){
            if(data) {
                this.Project = data;
                if(this.Project) {
                    let ssStatusVal = this.Project.fields.Sous_statut__c.value;
                    this.StatusLabel = this.Project.fields.Statut__c.displayValue;
                    if(this.Project.fields.Statut__c.value=='DRAFT') {
                        this.disableCloture = true;
                        this.disableSave1 = true;
                        this.disableDepose = false;
                        this.disableMotif = true;
                        this.disableSousStatut = true;
                    } else if(ssStatusVal=='Part_NRP_1' || ssStatusVal=='Part_NRP_2' || ssStatusVal=='Part_NRP_3') {
                        this.disableCloture = false;
                        this.disableSave1 = false;
                    }
                    this.SousStatutValue = ssStatusVal;
                }                
            } else if(error) {
                console.log('requete error', JSON.stringify(error));
            }
        }
        
    get defMotifValue() {
        if(this.Project) {
            return this.Project.fields.Motif__c.value;
        }
    }
    get defMotifClotureValue() {
        if(this.Project) {
            return this.Project.fields.Motif_cloture_projet__c.value;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$projectInfo.data.defaultRecordTypeId', fieldApiName: SOUS_STATUT_FIELD })
    sousStatutFieldInfo({ data, error }) {
        if (data && this.Project) {
            let key = data.controllerValues[this.Project.fields.Statut__c.value];
            this.sousStatutOptions = data.values.filter(opt => opt.validFor.includes(key));
        } else if(error) {
            console.log('sousStatutFieldInfo error', JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$projectInfo.data.defaultRecordTypeId', fieldApiName: MOTIF_FIELD })
    motifFieldInfo({ data, error }) {
        if (data && this.Project) { 
            this.motifData = data;
            let key = data.controllerValues[this.Project.fields.Sous_statut__c.value];
            this.motifOptions = data.values.filter(opt => opt.validFor.includes(key));
        } else if(error) {
            console.log('motifFieldInfo error', JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$projectInfo.data.defaultRecordTypeId', fieldApiName: MOTIF_CLOTURE_FIELD })
    motifClotureFieldInfo({ data, error }) {
        if (data && this.Project) {      
            this.motifClotureData = data;
            let key = data.controllerValues[this.Project.fields.Sous_statut__c.value];
            this.motifClotureOptions = data.values.filter(opt => opt.validFor.includes(key));
        } else if(error) {
            console.log('motifClotureFieldInfo error', JSON.stringify(error));
        }
    }

    handleSSChange(event) {
        let key = this.motifData.controllerValues[event.target.value];
        this.motifOptions = this.motifData.values.filter(opt => opt.validFor.includes(key));
        key = this.motifClotureData.controllerValues[event.target.value];
        this.motifClotureOptions = this.motifClotureData.values.filter(opt => opt.validFor.includes(key));

        if(event.target.value=='Part_NRP_1' || event.target.value=='Part_NRP_2' || event.target.value=='Part_NRP_3') {
            this.disableCloture = false;
        } else {
            this.disableCloture = true;
        }
    }

    updateProject(Statut) {
        const fieldsToUpdate = {};
        fieldsToUpdate[ID_FIELD.fieldApiName] = this.projectId;
        if(Statut=='VALIDATING') {
            fieldsToUpdate[STATUT_FIELD.fieldApiName] = Statut;
            fieldsToUpdate[SOUS_STATUT_FIELD.fieldApiName] = 'Nouveau';
            fieldsToUpdate[MOTIF_FIELD.fieldApiName] = '';
            fieldsToUpdate[MOTIF_CLOTURE_FIELD.fieldApiName] = '';
        } else if(Statut == 'DRAFT') {
            fieldsToUpdate[STATUT_FIELD.fieldApiName] = Statut;
            fieldsToUpdate[SOUS_STATUT_FIELD.fieldApiName] = this.template.querySelector("[data-field='SousStatutVal']").value;
            fieldsToUpdate[MOTIF_CLOTURE_FIELD.fieldApiName] = this.template.querySelector("[data-field='MotifCloVal']").value;
        } else {
            fieldsToUpdate[SOUS_STATUT_FIELD.fieldApiName] = this.template.querySelector("[data-field='SousStatutVal']").value;
            fieldsToUpdate[MOTIF_FIELD.fieldApiName] = this.template.querySelector("[data-field='MotifVal']").value;
        }
       
        const recordInput = {};
        recordInput['fields'] = fieldsToUpdate ;
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Projet mis à jour',
                        variant: 'success'
                    })
                );
                const closeQA = new CustomEvent('close');
                this.dispatchEvent(closeQA);
            })
            .catch(error => {
                this.errorMsg = 'Unknown error';
                console.log(error);
                if(Array.isArray(error.body.output.fieldErrors.Sous_statut__c)) {
                    this.errorMsg = error.body.output.fieldErrors.Sous_statut__c.map(e => e.message).join(', ');
                } else  if(Array.isArray(error.body.output.errors) && Array.isArray(error.body.output.errors).length!=0) {
                    this.errorMsg = error.body.output.errors.map(e => e.message).join(', ');
                } else if(typeof error.body.message === 'string') {
                    this.errorMsg = error.body.message;
                }
                if(this.errorMsg=='') {
                    this.errorMsg = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur lors de la mise à jour du projet',
                        message: this.errorMsg,
                        variant: 'error'
                    })
                );
            });
    }
    cloturerCB() {
        this.ClotureProjet = true;
        this.ModifProjet = false;
    }
    deposerCB() {
        this.updateProject('VALIDATING');
    }
    backCB() {
        let ssStatusVal = this.template.querySelector("[data-field='SousStatutVal']").value;
        if(ssStatusVal =='Part_NRP_1' || ssStatusVal=='Part_NRP_2' || ssStatusVal=='Part_NRP_3') {
            this.disableCloture = false;
        } else {
            this.disableCloture = true;
        }
        this.ClotureProjet = false;
        this.ModifProjet = true;
        this.disableSave1 = false;
    }
    saveCB() {
        if(this.ClotureProjet==true) {
            let ssStatusVal = this.template.querySelector("[data-field='SousStatutVal']").value;
            if(ssStatusVal=='Part_NRP_1' || ssStatusVal=='Part_NRP_2' || ssStatusVal=='Part_NRP_3') {
                let motif = this.template.querySelector("[data-field='MotifCloVal']").value;
                if(motif) {
                    this.updateProject('DRAFT');
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erreur : ',
                            message: 'Le motif de clôture manuelle est obligatoire',
                            variant: 'error'
                        })
                    );   
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erreur : ',
                        message: 'Le Sous Statut doit être à NRP1, NRP2 ou NRP3 pour clôturer manuellement le projet',
                        variant: 'error'
                    })
                ); 
            }
        } else {
            this.updateProject(undefined);
        }
    }
}