({
    invoke: function (component, event, helper) {
        let workspaceAPI = component.find('workspace');
        workspaceAPI
        // Get all info about all open tabs
            .getAllTabInfo()
            .then((tabInfo) => {
                //Loop through all open tabs and closes the ones with the objectapiName Account
               tabInfo.forEach((subtab) => {
                if(subtab.pageReference.attributes.objectApiName == 'Account'){
                    workspaceAPI
                    .closeTab({ tabId: subtab.tabId })
                    .then((response) => {
                        //Success
                    })
                    .catch((error) => {
                        console.log(JSON.stringify(error, null, 2));
                    });
                }; 
             })
        })
            .catch((error) => {
                console.log(JSON.stringify(error, null, 2));
            });
    }
});