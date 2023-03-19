public with sharing class AccountControllerExtensionForWeather {
    
    // my API key
    private final String API ='09d6ea17a4b68bc6ef1d45d1d33fdc29';
    public Account account {get; set;}
    public OpenWeatherWrapper openWeatherWrapper{get; set;}
    public String description {get; set;}
    public Double temperature {get; set;}
    public String weatherIcon {get; set;}
    
    // If one of these is false error PageBlockMessage will be displayed
    public Boolean hasAddress {get; set;}
    public Boolean isResponseSuccess {get; set;}

    // Title and contend of the error message
    public String errorBLockTitle {get; set;}
    public String errorMessage {get; set;}

    public AccountControllerExtensionForWeather(ApexPages.StandardController controller) {
        this.account = (Account)controller.getRecord();
    }

    public void getWeather() {
        // Account should have Billing City  
        if(account.BillingCity != null) {
            // setting hasAddress field to true -> prevent error message from being displayed
            hasAddress = true;

            // Creating and making the HTTP call
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.openweathermap.org/data/2.5/weather?q=' + account.BillingCity + '&appid=' + API);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            
            // if success we deserialize the retrieved response and extract the needed data
            if (response.getStatusCode() == 200) {
                isResponseSuccess = true;
                openWeatherWrapper = (OpenWeatherWrapper)(JSON.deserialize(response.getBody(), OpenWeatherWrapper.class));
                description = openWeatherWrapper.weather[0].description;
                temperature = openWeatherWrapper.Main.temp;
                weatherIcon = 'https://openweathermap.org/img/wn/' + openWeatherWrapper.weather[0].icon + '.png';
            } else {
                // there's a response error we display error message
                isResponseSuccess = false;
                errorBlockTitle = 'Response Error:'; 
                errorMessage = 'Response error please try again later. If error persists please contact support.';
            }
        } else {
            // if the account doesn't have a Billing City set we display error message
            hasAddress = false;
            errorBlockTitle = 'Error: Account Billing Address missing';
            errorMessage = 'Account has no Billing Address. Please add billing address.';
        }
    }
}