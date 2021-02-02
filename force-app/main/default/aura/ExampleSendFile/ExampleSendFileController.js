({
   
    handleFilesChange : function(component,event) {
        var MAX_FILE_SIZE = 4500000;// 4500000; //Max file size 4.5 MB ou 750000,      //Chunk Max size 750Kb 
      
        
        var fileContents = null;
        var base64Mark = null;
        var dataStart = null;
        
       // var rectarget = event.currentTarget;
        //var whichOne = rectarget.getAttribute("id");
        
        var fileInput = component.find('file').getElement();
    	var file = fileInput.files[0];
        
        //alert(whichOne);
        if (file.size > MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' +
    	          'Selected file size: ' + file.size);
    	    return;
        }
    
        var fr = new FileReader();
        var self = this;
       	fr.onload = function(self) {
            var fileContents = fr.result; 
            var mimeType = null;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            component.set('v.fileContents', fileContents); 
            component.set('v.fileName', file.name); 
            component.set('v.fileType', file.type); 
            //alert(fileContents);
        };

        fr.readAsDataURL(file); 
    },
    save : function(component) {
        var fieldSelect = component.find('typeDocument').getElement();
        var fileInput = component.find('file').getElement();
    	var file = fileInput.files[0];
        if(file == null || file == undefined) {
        	alert('Veuillez ajouter un fichier'); 
        }
        else if(fieldSelect == null || fieldSelect == undefined || fieldSelect.value == ''){
        	alert('Veuillez choisir un type de fichier');
        }
        else {
            var action = component.get("c.saveTheFile"); 
            action.setParams({
                fileName: component.get('v.fileName'),
                base64Data: component.get('v.fileContents'), 
                mimeType: component.get('v.fileType'),
                sobjecttype: component.get('v.sobjecttype'),
                recordId: component.get('v.recordId'), 
                typeDocument: fieldSelect.value
            });
           
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Traitement!",
                        "message": response.getReturnValue()
                    });
                    toastEvent.fire();
                } 
            });
          
            $A.enqueueAction(action);  
        }
    },
})