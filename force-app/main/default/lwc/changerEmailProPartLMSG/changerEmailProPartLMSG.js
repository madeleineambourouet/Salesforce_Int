import { LightningElement, api, track } from 'lwc';
import callProjectPlaceEmailChange from '@salesforce/apex/ProjectPlaceWS.callProjectPlaceEmailChange';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class changerEmailProPartLMSG extends LightningElement {

    @api recordId;

    changeEmailCB() {
        var msg = 'null';
        var field = this.template.querySelector('lightning-input');
        var newEmail = field.value;

        callProjectPlaceEmailChange({  recordId : this.recordId ,
                                       newEmail : newEmail})
        .then(result => {
            msg = result;
            if(msg == 'SUCCESS') {
                const evt = new ShowToastEvent({
                    title: 'Le changement a été demadé avec succès',
                    message: 'L\'utilisateur (Pro/Part) va recevoir un email de validation de la modification. Une fois la validation effectuée, le changement sera effectif',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            } else {
                if(msg == 'USERNAME_ALREADY_IN_USE') {
                    const evt = new ShowToastEvent({
                        title: 'Le changement d\'email a échoué',
                        message: 'L\'adresse email est déjà utilisé',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                } else {
                    const evt = new ShowToastEvent({
                    title: 'Le changement d\'email a échoué',
                    message: 'Merci de réesseyer ou de contacter votre support IT (' + msg + ')' ,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                }
            }
            const closeQA = new CustomEvent('close');
            this.dispatchEvent(closeQA);
        })
        .catch(error => { 
            const evt = new ShowToastEvent({
                title: 'Le changement d\'email a échoué',
                message: msg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
       
    }
}