public with sharing class SummarizeOpportunityAmounts implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bContext) {
        // Select Accounts with their related Opportunities and Primary contacts.
        // Will select only Accounts that have had Opportunities this month and also have a Primary Contact with an existing email address.
        return Database.getQueryLocator(
                        'SELECT Id, Name, ' +
                        '(SELECT AccountId, StageName, Amount, Probability FROM Opportunities WHERE CreatedDate = THIS_MONTH OR LastModifiedDate = THIS_MONTH), ' +
                        '(SELECT AccountId, Email FROM Contacts WHERE Email != null AND Is_Primary_Contact__c = true) ' +
                        'FROM Account ' +
                        'WHERE Id IN (SELECT AccountId FROM Opportunity WHERE CreatedDate = THIS_MONTH OR LastModifiedDate = THIS_MONTH) ' +
                        'AND Id IN (SELECT AccountId FROM Contact WHERE Is_Primary_Contact__c = true)');
    }

    public void execute(Database.BatchableContext bContext, List<Account> scope) {
        // List for contact who will be the recipients
        List<Contact> recipients = new List<Contact>();
        //  Id     Acc.Name  Opp.status Amount    creating Map<AccountId, <Map<Account.Name, <Opportunity.StageName, Amount>>>  
        Map<Id, Map<String, Map<String, Integer>>> mappedAccsWithOpps = new  Map<Id, Map<String, Map<String, Integer>>>();
        
        //Filling up the Contact List 
        for (Account account : scope) {
            for (Contact recipient : account.Contacts) {
                recipients.add(recipient);
            }
        }

        // Extracting data from the Scope into the Map
        for (Account fetchedAccount : scope) {
            
            // Setting up the key - value pairs. Setting initial amount values to 0;
            mappedAccsWithOpps.put(fetchedAccount.Id, new Map<String, Map<String, Integer>>{fetchedAccount.Name => new Map<String, Integer>{'Open' => 0, 'Closed Won' => 0, 'Closed Lost' => 0}});
            
            // Assign the sum of individual Amounts to the coresponding keys
            for (Opportunity opportunity : fetchedAccount.Opportunities) {
                // If Opportunity StageName is not 'Closed Won' and is not 'Closed Lost' then it will be treated as Open and it's Amount will be added to the value of Open key
                if (opportunity.StageName != 'Closed Won' && opportunity.StageName != 'Closed Lost') {
                    mappedAccsWithOpps.get(fetchedAccount.Id).get(fetchedAccount.Name).put('Open', mappedAccsWithOpps.get(fetchedAccount.Id).get(fetchedAccount.Name).get('Open') + (Integer)opportunity.Amount);
                } else {
                    // Otherwise the ammount will be added to the value of one of the remaining keys
                    mappedAccsWithOpps.get(fetchedAccount.Id).get(fetchedAccount.Name).put(opportunity.StageName, mappedAccsWithOpps.get(fetchedAccount.Id).get(fetchedAccount.Name).get(opportunity.StageName) + (Integer)opportunity.Amount);
                }
            }
        }
        // We hand the collections over    
        EmailSummarizedOpportunityAmounts.sendEmail(recipients, mappedAccsWithOpps);
    }   

    public void finish(Database.BatchableContext bContext) {}
}