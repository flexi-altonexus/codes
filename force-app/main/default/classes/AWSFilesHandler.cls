public class AWSFilesHandler {

    public static String secret{Get; Set;}
    public static String key{Get; Set;}
    public static String region{Get; Set;}
    public static String bucket{Get; Set;}
    public static String host{Get; Set;}
    public static String imagePrefix{Get; Set;}

    public AWSFilesHandler() {
        
    }

    public void deleteFiles(List<AWS_Files__c> files){

        Set<Id> fileIds = new Set<Id>();
        for(AWS_Files__c file : files){
            fileIds.add(file.Id);
        }
        deleteFilesFuture(fileIds);
    }

    @future (callout=true)
    public static void deleteFilesFuture(Set<Id> fileIds){

        List<AWS_Files__c> files = [SELECT Id, Name, URL__c FROM AWS_Files__c WHERE Id IN: fileIds AND IsDeleted= true ALL ROWS];
        try{
            bucket = AmazonS3__c.getValues('AWSS3').Bucket__c;
            region = AmazonS3__c.getValues('AWSS3').Region__c;
            secret = AmazonS3__c.getValues('AWSS3').Secret_Access_Key__c;
            key = AmazonS3__c.getValues('AWSS3').Access_Key_ID__c;
            host = AmazonS3__c.getValues('AWSS3').Host__c;
            imagePrefix = AmazonS3__c.getValues('AWSS3').Image_prefix__c;
        } catch(Exception e){
            System.debug('Error on settings S3: '+e.getMessage());
        }

        AwsSdk.Connector connector = new AwsSdk.Connector(key,secret);
        AwsSdk.S3.Bucket bucket = connector.s3(region).bucket(bucket);
        
        for(AWS_Files__c file : files){
            List<String> fileNames = file.URL__c.split(imagePrefix + '/');
            String fileName = fileNames[fileNames.size()-1];
            HttpResponse res = new HttpResponse();
            if(!Test.isRunningTest()){
                res = bucket.deleteContent(imagePrefix + '/' + fileName);
            }
            system.debug(imagePrefix + '/' + fileName);
            system.debug(res);
        }
        
    }
}