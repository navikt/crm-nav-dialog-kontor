public with sharing class DIA_AktivitetsplanService {
    private static final String API_CONFIG_NAME = 'AKTIVITETSPLAN_API';
    private static final Map<String, String> SERVICE_NAME = new Map<String, String>{
        'info' => 'GET_AKTIVITETSPLAN_INFO',
        'perioder' => 'GET_AKTIVITETSPLAN_PERIODER'
    };
    private static final String SERVICE_AUTH_HEADER = 'Aktivitetsplan';
    public static HttpResponse getOppfolgingsInfoService(String ident) {
        Map<String, String> queryParams = new Map<String, String>{ 'aktorId' => ident };
        ApiController apiCtrl = new ApiController();
        apiCtrl.initRequest(API_CONFIG_NAME, SERVICE_NAME.get('info'));
        apiCtrl.addServiceAuthHeader(SERVICE_AUTH_HEADER);
        apiCtrl.addHeader('Content-Type', 'application/json');
        apiCtrl.setUrlParams(queryParams);
        apiCtrl.doCallout();
        return apiCtrl.getResponse();
    }

    @AuraEnabled
    public static APlan_Oppfolgingsinfo getOppfolgingsInfo(String ident) {
        HttpResponse response = getOppfolgingsInfoService(ident);
        if (response.getStatusCode() == 200 || response.getStatusCode() == 204) {
            return (APlan_Oppfolgingsinfo) JSON.deserialize(response.getBody(), APlan_Oppfolgingsinfo.class);
        }
        String errorRef = logError(response, 'Error from getOppfolgingsInfo.');
        throw new getOppfolgingDataException('Feil henting oppfolgingsinfo: ' + errorRef);
    }
    public static HttpResponse getOppfolgingsPerioderService(String ident) {
        Map<String, String> queryParams = new Map<String, String>{ 'aktorId' => ident };
        ApiController apiCtrl = new ApiController();
        apiCtrl.initRequest(API_CONFIG_NAME, SERVICE_NAME.get('perioder'));
        apiCtrl.addServiceAuthHeader(SERVICE_AUTH_HEADER);
        apiCtrl.addHeader('Content-Type', 'application/json');
        apiCtrl.setUrlParams(queryParams);
        apiCtrl.doCallout();
        return apiCtrl.getResponse();
    }
    public static APlan_Oppfolgingsperioder getOppfolgingsPerioder(String ident) {
        HttpResponse response = getOppfolgingsPerioderService(ident);
        if (response.getStatusCode() == 200) {
            return (APlan_Oppfolgingsperioder) JSON.deserialize(response.getBody(), APlan_Oppfolgingsperioder.class);
        }
        String errorRef = logError(response, 'Error from getOppfolgingsperioder.');
        throw new getOppfolgingDataException('Feil henting oppfolgingsperioder: ' + errorRef);
    }
    private static String logError(HttpResponse resp, String message) {
        String errorRef = '';

        LoggerUtility logger = new LoggerUtility('NKS');
        logger.httpError(message, resp, null, null);
        errorRef = logger.peek().UUID__c;
        logger.publish();

        return errorRef;
    }
    public class getOppfolgingDataException extends Exception {
    }
}
