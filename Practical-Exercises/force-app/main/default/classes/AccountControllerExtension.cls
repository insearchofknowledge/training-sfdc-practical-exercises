public with sharing class AccountControllerExtension {
    
    private final Account account;
    private String accId;
    public String inputSearchName{get; set;}
    public String contactName {get; set;}
    public String futurePrimaryContactId{get; set;}

    List<Contact> oldPrimaryContacts;
    
    public Integer currentPosition = 0;
    public Integer tableSize {get; set;}
    public Integer numberOfRecords{get; set;}
    public Integer pageNumber {get; set;}


    public AccountControllerExtension(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
        this.accId = account.Id;
        this.pageNumber = 1;
        this.tableSize = 5;
        this.oldPrimaryContacts = new List<Contact>();
    }
 
    // For displaying contacts related to the selected Account
    public List<Contact> getRelatedContacts(){
        // All contacts should be displayed if there is no user input in the search field
        if (this.inputSearchName == null){
            this.inputSearchName = '';
        }
        // If there is input from user, it should be added into the query
        this.contactName = '%' + this.inputSearchName + '%';
    
        List<Contact> relatedContacts = new List<Contact>();
        relatedContacts = [SELECT Id, Name, Title, Phone, Is_Primary_Contact__c
                           FROM Contact 
                           WHERE AccountId = :account.Id AND Name LIKE :contactName
                           ORDER BY Name ASC
                           LIMIT :tableSize
                           OFFSET :currentPosition];
        
        // Refresh the number of records after searching contacts by name                    
        this.numberOfRecords = [SELECT COUNT() FROM Contact
                                WHERE AccountId = :account.Id AND Name LIKE : contactName];
        return relatedContacts;
    }

    // For setting a new primary contact from related contacts list
    public void updateAsPrimaryContact(){
        
            // We fetch the selected contact from the DB and we set the Is_Primary_Contact__c field = true
            List<Contact> result = [SELECT Id, Name, Is_Primary_Contact__c
                                    FROM Contact 
                                    WHERE Id = :futurePrimaryContactId];
            Contact futurePrimaryContact = result[0];
            futurePrimaryContact.Is_Primary_Contact__c = true;
        
            // We check if there are other primary contacts
            oldPrimaryContacts = [SELECT Id, Name, Is_Primary_Contact__c
                                  FROM Contact 
                                  WHERE AccountId = :accId AND Is_Primary_Contact__C = true];
        
            // If there are we set the primary contact field to false (using a list helps us make sure no contact escapes from the update)
            if (oldPrimaryContacts.size() > 0){
                for (Contact oldPrimaryContact : oldPrimaryContacts){
                    oldPrimaryContact.Is_Primary_Contact__c = false;
                }
                // Updating old primary contact to secondary 
                update oldPrimaryContacts;
            }
            // Updating newly assigned primary contact
            update futurePrimaryContact;
    }

    // Pagination
    // First page
    public void firstPage(){
        this.currentPosition = 0;
        this.pageNumber = 1;
    }

    // Last page
    public void lastPage(){
        this.currentPosition = numberOfRecords - tableSize;
        this.pageNumber = numberOfRecords / tableSize;
    }

    // Prebious page
    public void previous(){
        this.currentPosition -= tableSize;
        this.pageNumber -= 1;
    }

    // Next page
    public void next(){
        this.currentPosition += tableSize;
        this.pageNumber += 1;
    }

    // Checking if we are at the beginning of the list. If we are at the beginning of the list the Previous Page button is desabled.
    public boolean getHasPrevious(){
        return(currentPosition > 0 ? true : false);
    }

    // Checking if we have more records for a new page. If we reached the end of the list the Next Page button is desabled.
    public boolean getHasNext(){
        return((currentPosition + tableSize) < numberOfRecords ? true : false);
    }

    // We need to reset some pagination variables when we search contacts by name or when we modify the number of records per page in order to avoid errors
    public void resetPagination() {
        this.pageNumber = 1;
        this.currentPosition = 0;
    }
}