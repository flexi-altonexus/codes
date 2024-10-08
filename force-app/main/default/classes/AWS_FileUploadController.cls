/*
*   @Class  		: AWS_FileUploadController
*
*   @Author         : Vanessa Lopes <vanessa.lopes@empaua.com>
*   @Created        : 12 may 2017
*   @Description    : Methods for DocumentUpload page
*
*   Modification Log
*   --------------------------------------------------------------------------------------
*   #       Developer           Date            Description
*   --------------------------------------------------------------------------------------
*   1       Vanessa Lopes       12 may 2017     Creation
*
*/

public with sharing class AWS_FileUploadController {

    public     String                       parentId                {Get; Set;}
    public     String                       parentName              {Get; Set;}
    public     List<ContainerClass>         listaCC                 {Get; Set;}
    public     String                       idImg                   {Get; Set;}
    public     String                       urlImg                  {Get; Set;}
    public     String                       obj                     {Get; Set;}
    public     String                       secret                  {Get; Set;}
    public     String                       key                     {Get; Set;}
    public     String                       region                  {Get; Set;}
    public     String                       bucket                  {Get; Set;}
    public     String                       host                    {Get; Set;}
    public     String                       imagePrefix             {Get; Set;}
    public     Boolean                      isImage                 {Get; set;}
    public     String                       currentFileName         {Get; set;}
    public     String                       salesforceInstance      {Get; set;}
  

    private    Integer                      orderMax;

    public AWS_FileUploadController(ApexPages.StandardController controller) {
        parentId = ApexPages.currentPage().getParameters().get('id');
        salesforceInstance = Url.getOrgDomainUrl().toExternalForm();
        salesforceInstance =  salesforceInstance.replace('my.salesforce.com','lightning.force.com');

        obj = AWS_Files__c.getSObjectType().getDescribe().getLabelPlural();
        parentName = AccountName();
        listaCC = new List<ContainerClass>();
        //renderErr = new Map<String,String>();
        getS3Conf();
        getImageData();
    }

    public AWS_FileUploadController(){
        parentId = ApexPages.currentPage().getParameters().get('id');
        salesforceInstance = Url.getOrgDomainUrl().toExternalForm();
        salesforceInstance =  salesforceInstance.replace('my.salesforce.com','lightning.force.com');
        getS3Conf();
        listaCC = new List<ContainerClass>();
        System.debug('GC_s3Upload_Controller parentId: '+parentId);
        getImageData();
    }

    public class ContainerClass{
        public AWS_Files__c  image    {Get;Set;}
        public Boolean       toDelete {Get;Set;}

        public ContainerClass(){
            toDelete = false;
            image = new AWS_Files__c();
        }
    }

    public class AWSResultClass{
        public List<AWSError> Errors;
        public List<AWSDeleted> Deleted;
    }

    public class AWSError{
        public String Id;
        public String Message;
    }

    public class AWSDeleted{
        public String Id;
    }

     /*
     * @Method          :   AccountName
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   24 Mar 2017
     * @Description     :   Get current record name
     * @Params          :   -
     * @Returns         :   String
     * @MaxSoqls        :   1
     * @MaxDmls         :   -
     */

    private String AccountName(){
        System.debug('--- GC_s3Upload_Controller >> AccountName');
        try{
            List<Account> inmLst = [SELECT Name FROM Account WHERE Id = :parentId LIMIT 1];
            return inmLst[0].Name;
        } catch(Exception e){
            System.debug('Error get Account Name on Salesforce Query: '+parentId);
            return null;
        }

    }

    /*
     * @Method          :   refreshData
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   01 Jul 2019
     * @Description     :   Refresh data to show
     * @Params          :   -
     * @Returns         :   PageReference
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */

    public PageReference refreshData(){
        System.debug('--- GC_s3Upload_Controller >> refreshData');
        getImageData();
        return NULL;
    }

    /*
     * @Method          :   getS3Conf
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   01 Jul 2019
     * @Description     :   Retrieve s3 bucket config
     * @Params          :   -
     * @Returns         :   void
     * @MaxSoqls        :   0
     * @MaxDmls         :   -
     */

    private void getS3Conf(){
    	
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
        
    }

    /*
     * @Method          :   getImageData
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   01 Jul 2019
     * @Description     :   Retrieve GC_Imagen__c list for current GC_Inmueble__c
     * @Params          :   -
     * @Returns         :   void
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */

    private void getImageData(){
        System.debug('--- GC_s3Upload_Controller >> getImageData');
        List<ContainerClass> listaContainer = new List<ContainerClass>();
       
        try{
         
            List<AWS_Files__c> lImages = [SELECT URL__c, Description__c, Tittle__c 
                                            FROM AWS_Files__c
                                            WHERE Business_Centre__c =: parentId 
                                            ORDER BY CreatedDate DESC NULLS LAST];

            for(AWS_Files__c image : lImages){
                
                ContainerClass contImg = new ContainerClass();
                contImg.image = image;
                listaContainer.add(contImg);
               
            }

            listaCC = listaContainer;
            //System.debug(renderErr);
        }catch(Exception e){
            System.debug('\n\nError en getImageData: '+e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading, please try again'));
        }
    }

    /*
     * @Method          :   createImg
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   01 Jul 2019
     * @Description     :   Retrieve Image list for current Inmueble__c
     * @Params          :   -
     * @Returns         :   PageReference
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */

    public PageReference createImg(){
        System.debug('createImg');
        try{
            AWS_Files__c img = new AWS_Files__c();
            img.Business_Centre__c = parentId;
            img.URL__c = urlImg;
            img.Name = currentFileName;
            img.Tittle__c = currentFileName;
            
            insert img;
                       
            ContainerClass contImg = new ContainerClass();
            contImg.image = img;
            listaCC.add(contImg);

            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Upload completed: ' + img.Tittle__c));
            
            list<AWS_Files__c> existingFiles = new list<AWS_Files__c>([select id from AWS_Files__c where Business_Centre__c =:parentId]);
            if(existingFiles.size() < 2){
                return new PageReference('/lightning/r/Account/'+parentId+'/view');
            }else{
                return null;
            }
           

        } catch(Exception e){
            System.debug('\n\nError en createImg: '+e.getMessage()+'\n'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading, please try again'));
            return NULL;
        }
        
    }

    /*
     * @Method          :   deleteFile
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   01 Jul 2019
     * @Description     :   Deletes image on AWS S3 and AWS_Files__c record
     * @Params          :   -
     * @Returns         :   PageReference
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */

    /*
    public PageReference deleteFile(){
        System.debug(' deleteFile');
        List<AWS_Files__c> imgDelLst = new List<AWS_Files__c>();
        String errMsg = 'Error deleting file: ';
        String errLst = '';
        //System.debug('json: '+idImg);
        AWSResultClass test = (AWSResultClass)JSON.deserialize(idImg,AWSResultClass.class);

        try{
            if(!test.Deleted.isEmpty()){

                for(AWSDeleted del : test.Deleted){
                    AWS_Files__c im = new AWS_Files__c();
                    im.Id = del.Id;

                    imgDelLst.add(im);
                }

                delete imgDelLst;
                getImageData();

                if(test.Errors.isEmpty()){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The file was delete'));
                    return NULL;
                }
            }

            if(!test.Errors.isEmpty()){
                Map<Id, ContainerClass> ccMap = new Map<Id, ContainerClass>();

                for(ContainerClass cc : listaCC){
                    ccMap.put(cc.image.Id, cc);
                }


                for(AWSError err : test.Errors){
                    //renderErr.put(err.Id,err.Message);
                    if(errLst != ''){
                        errLst += ', ';
                    }
                    errLst += ccMap.get(err.Id).image.Tittle__c + '(Id: '+err.Id+')';
                    System.debug('Error deleteFile: Id image: '+err.Id+', Error S3: '+err.Message);
                }

                if(errLst.contains(',')){
                    errMsg = 'These files has not been deleted: ';
                }
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg + errLst));
            }

            return NULL;

        } catch(Exception ex){
            System.debug(ex);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error deleting files'));
            return NULL;
        }
    }*/

    /*
     * @Method          :   save
     * @Author          :   Vanessa Lopes <vanessa.lopes@empaua.com>
     * @Created         :   01 Jul 2019
     * @Description     :   Updates Documentacion records
     * @Params          :   -
     * @Returns         :   PageReference
     * @MaxSoqls        :   -
     * @MaxDmls         :   -
     */

    public PageReference saveData(){
        System.debug(' saveData');
        List<AWS_Files__c> imgList = new List<AWS_Files__c>();
        Set<Decimal> orderValues = new Set<Decimal>();

        try{
            for(ContainerClass cc : listaCC){
                if(cc.image.get('Id') != NULL){
                   imgList.add(cc.image);
                }
            }

            update imgList;

            getImageData();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved'));
            return NULL;

        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error saving data. Try again...'));
            return NULL;
        }
    }
}