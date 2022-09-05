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
    @isTest
    public static void getOppfolgingsPerioderTest() {
        ApiMock.setTestMock('GET_AKTIVITETSPLAN_PERIODER', 200, 'OK');
        APlan_Oppfolgingsperioder perioder = DIA_AktivitetsplanService.getOppfolgingsPerioder('test');
        System.assertEquals(true, perioder?.oppfolgingsperioder != null);
        System.assertEquals(true, perioder.oppfolgingsperioder.size() > 0);
        System.assertEquals(
            Datetime.newInstanceGMT(2021, 2, 25, 8 - 2, 0, 0),
            perioder.oppfolgingsperioder[0].startDato
        ); //+02:00gmt

        //Test coverage getters and comparable
        perioder.oppfolgingsperioder.sort();
        System.debug(perioder.oppfolgingsperioder[0].activePeriod);
        System.debug(perioder.oppfolgingsperioder[0].startDatoString);
        System.debug(perioder.oppfolgingsperioder[0].sluttDatoString);
        System.debug(perioder.oppfolgingsperioder[0].dialoger[0].meldinger);

        System.debug(perioder.oppfolgingsperioder[0].aktiviteter[0].friendlyStatus);
        System.debug(perioder.oppfolgingsperioder[0].aktiviteter[0].status_enum);
        System.debug(perioder.oppfolgingsperioder[0].aktiviteter[0].aktivitet_type_enum);
        System.debug(perioder.oppfolgingsperioder[0].aktiviteter[0].uniqueKey);

        ApiMock.setTestMock('GET_AKTIVITETSPLAN_PERIODER', 500, 'Serverfeil');
        try {
            DIA_AktivitetsplanService.getOppfolgingsPerioder('test');
            System.assert(false, 'Exception expected.');
        } catch (DIA_AktivitetsplanService.getOppfolgingDataException e) {
            //
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception type');
        }
    }
}
