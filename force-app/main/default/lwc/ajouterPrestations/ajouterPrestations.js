import { LightningElement, track, wire, api } from 'lwc';
import getCategoryPrestationMap from '@salesforce/apex/PrestationContactMethods.getCategoryPrestationMap';
import createPrestationContact  from '@salesforce/apex/PrestationContactMethods.createPrestationContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AjouterPrestations extends LightningElement {
    @api contactId;
    @track toggleIconName = 'utility:multi_select_checkbox';
    @track toggleButtonLabel = 'Tout sélectionner';
    @track saveIconName = 'utility:save';
    @track nextPage = false;
    @track noneSelected=true;
   // @tarck categoryList;
    @track category;
    @track error;
    @track catPrestMap=[];
    @track prestaList= {};
    @track prestaListIds=[];

    // get all categories :
    @wire(getCategoryPrestationMap, {contactId : '$contactId'}) 
    wiredResult(result) { 
        if (result.data) {
            var conts = result.data;
            //console.log(JSON.parse(result.data));
            for(var key in conts) {
                this.catPrestMap.push({key:key , value:conts[key]}); 
            }
        }
     }
 
    renderedCallback() {
        //console.log("rendered CB");
        if(this.prestaListIds == undefined || this.prestaListIds.length == 0)
            return;
        var options = this.template.querySelectorAll('option');
        options.forEach(opt => {
            if(this.prestaListIds.find(el => el == opt.value) != undefined) {
                opt.selected = true;
           }
        });
        this.onSelectChange();
    }
    handleNextPage() {
        //console.log("handleNextPage");
        if(this.nextPage == false) {
            // fill in the prestaList
            this.prestaMap = {};
            this.prestaList = [];
            this.prestaListIds= [];
            this.noneSelected = true;
            var elements = this.template.querySelectorAll('option');
            elements.forEach(element => {
                if(element.selected === true) {
                    this.noneSelected = false;
                    // supress end of category id str-112
                    let pos = element.id.indexOf('-');
                    let idx = pos;
                    while(pos !==-1) {
                        pos = element.id.indexOf('-', pos+1);
                        if(pos !==-1) {
                            idx = pos;
                        }
                    }
                    var labelp = element.id;
                    if(idx!==-1) {
                        labelp = element.id.substring(0, idx);
                    }
                    if(!this.prestaMap[labelp]) {this.prestaMap[labelp] = [];}
                    this.prestaMap[labelp].push(element.label);
                    this.prestaListIds.push(element.value);
               }
            });
            Object.entries(this.prestaMap).forEach(([key, value]) => {
                this.prestaList.push({key:key, value:value});
              });
            this.nextPage = true;
        } else {
            this.nextPage = false;
            this.onSelectChange();
        }
    }

    // Handles click on the 'Show/hide content' button
    handleToggleClick() {
        // if the current icon-name is `utility:preview` then change it to `utility:hide`
        //console.log("handleToggleClick");
        var select = true;
        this.prestaList = [];
        this.prestaListIds = [];
        if (this.toggleIconName == 'utility:multi_select_checkbox') {
            this.toggleIconName = 'utility:close';
            this.toggleButtonLabel = 'Tout désélectionner';
            select = true;
        } else {
            this.toggleIconName = 'utility:multi_select_checkbox';
            this.toggleButtonLabel = 'Tout sélectionner';
            select = false;
        }
        var elements = this.template.querySelectorAll('option');
        elements.forEach(elem => {
            elem.selected = select;
        });

        this.onSelectChange();
    }

    onSelectChange() {
        //console.log("onSelectChange call");
        // collect categories and number of selected option  
        var mapCatNumOpt = new Map();
        var optionList = this.template.querySelectorAll('option');
        optionList.forEach(optElem => {
            if(mapCatNumOpt.get(optElem.id) == undefined) {
                mapCatNumOpt.set(optElem.id, 0);
            } 

            if(optElem.selected == true) {
                var numSel = mapCatNumOpt.get(optElem.id);
                mapCatNumOpt.set(optElem.id, numSel + 1);
            }
        });
        
        var btnList = this.template.querySelectorAll('lightning-button');
        btnList.forEach(btnElem => {
            var numSelected = mapCatNumOpt.get(btnElem.id);
            if(numSelected != undefined) {
                if( numSelected != 0) {
                    if(numSelected == 1) {
                        btnElem.label = numSelected + " sélection";
                    } else {
                        btnElem.label = numSelected + " sélections";
                    }
                } else {
                    btnElem.label = "0 sélection";
                }
            }
        });
    }

    // create prestation contact for contactId
    handleSave() {
        var msg = 'SUCCESS';
        createPrestationContact({contactId : this.contactId ,
                                 prestaList : JSON.stringify(this.prestaListIds)})
        .then(result => { 
            msg = result;
        })
        .catch(error => { 
            const evt = new ShowToastEvent({
                title: 'La création des prestations a échouée',
                message: 'Merci de vérifier la liste des prestations existante',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        if(msg == 'SUCCESS') {
            const evt = new ShowToastEvent({
                title: 'Les prestations ont été crées',
                message: 'Merci de rafraîchir la fenêtre',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        if(msg == 'FAILED') {
            const evt = new ShowToastEvent({
                title: 'La création des prestations a échouée',
                message: 'Merci de vérifier la liste des prestations existante',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }
}