public class UpdateSecondaryContacts implements Queueable {
    
    private List<Contact> secondaryContacts;
    private String primaryContactPhone;
    public UpdateSecondaryContacts(List<Contact> secondaryContacts, String primaryContactPhone) {
        this.secondaryContacts = secondaryContacts;
        this.primaryContactPhone = primaryContactPhone;
    }

    public void execute(QueueableContext context) {
        for (Contact contact : secondaryContacts){
            contact.Primary_Contact_Phone__c = primaryContactPhone;
        }
        Database.saveResult[] results = Database.update(secondaryContacts, false);
        System.debug(results);
    }
}