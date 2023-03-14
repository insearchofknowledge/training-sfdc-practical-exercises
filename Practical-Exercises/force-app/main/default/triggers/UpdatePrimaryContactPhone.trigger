trigger UpdatePrimaryContactPhone on Contact (before insert, before update) {
    
    Contact triggeringContact;
    String primaryContactPhone;
    List<Contact> preExistingPrimaryContacts = new List<Contact>();
    List<Contact> contactsToBeUpdated = new List<Contact>();
    
    if (Trigger.isInsert) {
        // Getting the newly added Primary Contact and making sure it is not a Private Contact
        for (Contact creatingNewPrimaryContact : Trigger.new ){
            if (creatingNewPrimaryContact.AccountId != null && creatingNewPrimaryContact.Is_Primary_Contact__c == true) {
                triggeringContact = creatingNewPrimaryContact;
            }
        }
        // Checking if the account already has a primary contact  
        if (triggeringContact != null){
        preExistingPrimaryContacts = [SELECT Id, Is_Primary_Contact__c, Primary_Contact_Phone__c, Phone FROM Contact 
                                      WHERE AccountId = :triggeringContact.AccountId 
                                      AND Is_Primary_Contact__c = true];
        }
    }

    if (Trigger.isUpdate) {
        for (Contact primaryContact : Trigger.new) {
            // Checking if a Secondary Contact has been updated to Primary Contact
            if (primaryContact.AccountId != null && primaryContact.Is_Primary_Contact__c == true && Trigger.oldMap.get(primaryContact.Id).Is_Primary_Contact__c == false) {
                triggeringContact = primaryContact;
            } 
        }     
    }

    // We should make sure that Primary Contacts have a phone number
    if (triggeringContact != null && triggeringContact.Phone == null) {
        triggeringContact.addError('Primary Contact must have a phone number');
    }

    // If the Account already has a Primary Contact we prevent the newly created Primary Contact from being added
    if (preExistingPrimaryContacts.size() > 0 ){
        triggeringContact.addError('This account already has a Primary Contact.');
    } 
    
    if (triggeringContact != null) {
    // Otherwise we will fetch all the secondary contacts for Primary_Contact_Phone__c update
        contactsToBeUpdated = [SELECT Id, Primary_Contact_Phone__c, Phone FROM Contact
                               WHERE AccountId = :triggeringContact.AccountId];
        primaryContactPhone = triggeringContact.Phone; 
    }
    
    // If we have Secondary Contacts that need update a new job will be created 
    if (contactsToBeUpdated.size() > 0) {
        UpdateSecondaryContacts updateSecondaryContactsJob = new UpdateSecondaryContacts(contactsToBeUpdated, primaryContactPhone);
        System.enqueueJob(updateSecondaryContactsJob);
    } 
}