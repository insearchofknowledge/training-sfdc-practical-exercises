public with sharing class EmailSummarizedOpportunityAmounts {
    
    public static void sendEmail(List<Contact> recipients, Map<Id, Map<String, Map<String, Integer>>> mappedAccsWithOpps) {

        // List for the single emails that will be created
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        // Current month and Subject for the email subject
        DateTime currentDate = DateTime.now();
        String subject = 'Summarized opportunities for: '+ currentDate.format('MMMM');

        // Generating email for each Primary Contact
        for (Contact recipient : recipients) {

            // Defining address, subject, body/table for each email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] address = new String[] {recipient.Email};
            String table ='';
            String extractedCompanyNameAsKeySet = mappedAccsWithOpps.get(recipient.AccountId).keySet().toString();
            String companyName = extractedCompanyNameAsKeySet.substring(1, extractedCompanyNameAsKeySet.length()-1); // Since i got the AccountName as keySet 
            table = '<p>Below is a table of opportunities related to the account: '+ companyName +' </p>' +          // I had to trim the curly braces xD
                    '<br/>' + 
            '<table border="1">' +
                '<tr>' +
                    '<th bgColor="#D3D3D3" align="center">Account</th>' +
                    '<th bgColor="#D3D3D3" align="center">Stage</th>' +
                    '<th bgColor="#D3D3D3" align="center">Amount</th>' +
                '</tr>';
            // Account name    
            for (String accountName : mappedAccsWithOpps.get(recipient.AccountId).keySet()) {
                // Stage Status and Amount
                for (String stageStatus : mappedAccsWithOpps.get(recipient.AccountId).get(accountName).keySet()) {
                    String amount = mappedAccsWithOpps.get(recipient.AccountId).get(accountName).get(stageStatus).format();
                    table += '<tr>' +
                                '<td>' + accountName + '</td>' +
                                '<td>' + stageStatus + '</td>' +
                                '<td>' + (amount != '0' ? amount : '') + '</td>' + // Still need to figure out how to add the currency symbol to the amount without hardcoding it
                             '</tr>';
                }
            }
            table += '</table>';

            // Adding all of the components to the email
            mail.setToAddresses(address);
            mail.setSubject(subject);
            mail.setHtmlBody(table);
            // Adding the emails to the list
            mails.add(mail);
        }

        // Sending the emails
        if (mails.size() > 0) {
        Messaging.sendEmail(mails, false);
        }
    }
}