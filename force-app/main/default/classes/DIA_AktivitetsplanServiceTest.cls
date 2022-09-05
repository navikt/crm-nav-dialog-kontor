@isTest
public with sharing class DIA_AktivitetsplanServiceTest {
    @isTest
    public static void getOppfolgingsInfoTest() {
        ApiMock.setTestMock('GET_AKTIVITETSPLAN_INFO', 200, 'OK');
        APlan_Oppfolgingsinfo info = DIA_AktivitetsplanService.getOppfolgingsInfo('test');
        System.assertEquals('Z999999', info.primaerVeileder);
        System.assertEquals(true, info.underOppfolging);
        ApiMock.setTestMock('GET_AKTIVITETSPLAN_INFO', 500, 'Serverfeil');
        try {
            DIA_AktivitetsplanService.getOppfolgingsInfo('test');
            System.assert(false, 'Exception expected.');
        } catch (DIA_AktivitetsplanService.getOppfolgingDataException e) {
            //
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception type');
        }
    }
}
