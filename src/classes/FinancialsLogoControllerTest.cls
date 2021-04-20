@IsTest
    public class FinancialsLogoControllerTest {
        
        @IsTest
        private static void test1() {
            Account acc = new Account(Name = 'Canapi');
            insert acc;
            FinancialsLogoController.getAccData();

        }

    }