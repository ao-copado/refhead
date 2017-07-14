public with sharing class Utilities{
    
    public static void resetStatuses(String dId, boolean allJobs){
        Step__c[] steps = [select Id, Status__c, Deployment__c from Step__c where Deployment__c = :EncodingUtil.urlEncode(dId,'UTF-8') order by order__c, createddate limit 10000];
        Deployment_Job__c[] jobs = [select Id, Status__c, Step__r.Deployment__c, Deployed__c from Deployment_Job__c where Step__r.Deployment__c = :EncodingUtil.urlEncode(dId,'UTF-8') limit 10000];
        Destination_Org__c [] dos = [select Id, Status__c, Deployment__c from Destination_Org__c where Deployment__c = :EncodingUtil.urlEncode(dId,'UTF-8') limit 10000];
        Integer i=0;
        for(Step__c s : steps){ 
            s.Status__c  = 'Not started';
            i++;
            s.order__c = i;
        }
        for(Destination_Org__c d : dos){ d.Status__c  = 'Not started'; }
        for(Deployment_Job__c o : jobs){ 
            if(allJobs || o.Status__c!='Success'){
            	o.Status__c = 'Pending';
                if(allJobs)o.Early_Completion_Status__c = 'Pending';
                o.Deployed__c = 0;    
            }
        }
        
        Utilities.Secure_DML(steps, Utilities.DML_Action.UPD, schema.Sobjecttype.Step__c);
        Utilities.Secure_DML(jobs, Utilities.DML_Action.UPD, schema.Sobjecttype.Deployment_Job__c);
        Utilities.Secure_DML(dos, Utilities.DML_Action.UPD, schema.Sobjecttype.Destination_Org__c);
        Utilities.Secure_DML(new Deployment__c(Id=dId, Deployment_command_sent__c=null), Utilities.DML_Action.UPD, schema.Sobjecttype.Deployment__c);
    }
    public HerokuResult httpGet(String url){
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            DeployAPI.setAuthHeaders(req);//to authenticate agains heroku servers
            req.setEndpoint(url);
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            String r = res.getBody(); 
            return new HerokuResult(true, r, null);
        }
        catch(System.Exception ex){
            return new HerokuResult(false, null, ex.getMessage());
        }
    }
    
    // START FIELD methods 
    public static string describeFields(string sObjectName){
        string availableQueryFields = '';
        try{
            Map<String,Schema.SObjectType> schemaMap = new Map<String,Schema.SObjectType>();
            schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield = sfield.getDescribe();
                if(String.isBlank(availableQueryFields)){
                    availableQueryFields = dfield.getName();
                }
                else{
                    availableQueryFields += ','+dfield.getName();
                }
            }
            return availableQueryFields;
        }
        catch(Exception ex){
            return null;
        }        
    }
    // END FIELD methods
    
    
    public static Attachment insertAttachment(blob body, string name, string contentType, string parentId){
        Attachment att = new Attachment();
        att.Body = body;
        att.Name = name;
        att.ContentType=contentType;  
        att.IsPrivate = false;
        att.ParentId = parentId;
        Utilities.Secure_DML(att, Utilities.DML_Action.INS, schema.Sobjecttype.Attachment);
        return att;
    }
    
    // QUERIES START
    public static Org__c[] getAllOrgs(){
        Org__c[] o = [select id,Test_Frequency__c,name,username__c,password__c, token__c, org_type__c, sfdc_org_id__c, validated_date__c, error__c, Disable_Validation__c from Org__c limit 10000];
        return o;
    }
    
    public static Git_Repository__c getGitById(string recordId){
        SObject so = queryAllfields('Git_Repository__c', recordId);
        if(so == null)return null;
        Git_Repository__c o = (Git_Repository__c) so;
        return o;
    }

    public static External_CI_Setting__c getCISettingById(string recordId){
        SObject so = queryAllfields('External_CI_Setting__c', recordId);
        if(so == null)return null;
        External_CI_Setting__c o = (External_CI_Setting__c) so;
        return o;
    }

    public static External_CI_Job__c getCIJobById(string recordId){
        SObject so = queryAllfields('External_CI_Job__c', recordId);
        if(so == null)return null;
        External_CI_Job__c o = (External_CI_Job__c) so;
        return o;
    }

    public static Git_Backup__c getGitBackupById(string recordId){
        SObject so = queryAllfields('Git_Backup__c', recordId);
        if(so == null)return null;
        Git_Backup__c o = (Git_Backup__c) so;
        return o;
    }

    public static Promotion__c getPromotionById(string recordId){
        SObject so = queryAllfields('Promotion__c', recordId);
        if(so == null)return null;
        Promotion__c o = (Promotion__c) so;
        return o;
    }

    public static User_Story__c getUserStoryById(string recordId){
        SObject so = queryAllfields('User_Story__c', recordId);
        if(so == null)return null;
        User_Story__c o = (User_Story__c) so;
        return o;
    }

    public static PermissionSet getPermissionSetById(string recordId){
        SObject so = queryAllfields('PermissionSet', recordId);
        if(so == null)return null;
        PermissionSet o = (PermissionSet) so;
        return o;
    }   

    public static Org__c getOrgById(string recordId){
        Org__c o = [select id,name, Test_Frequency__c, username__c,
            password__c,Metadata_Types__c, token__c, org_type__c, 
            sfdc_org_id__c, validated_date__c, error__c, 
            Disable_Validation__c, Oauth_Signature__c ,
            Validated_Status__c,
            Last_Apex_Tests_Datetime__c,
            Last_Apex_Tests_Status__c,
            Last_Git_Backup_Datetime__c,
            Last_Git_Backup_Status__c,
            Custom_Domain__c,
            Environment__c,
            Default_Credential__c
            from Org__c where Id =:EncodingUtil.urlEncode(recordId,'UTF-8') limit 1];
        return o;
    }
    public static Deployment__c getDeploymentById(string recordId){
        Deployment__c deployment = [SELECT Count_Completed__c, Completed__c, Deployed__c, CreatedById, CreatedDate, Date__c, IsDeleted, Deployment_Jobs_Count__c, Name, Deployment_command_sent__c, From_Org__c, LastActivityDate, LastModifiedById, LastModifiedDate, OwnerId, Id, SUM_Deployed__c, Schedule__c, Server_URL__c, Status__c, SystemModstamp FROM Deployment__c where Id =:EncodingUtil.urlEncode(recordId,'UTF-8')];
        return deployment;
    }
    public static Step__c[] getStepsByDeploymentId(string recordId){
        Step__c[] steps = [select Id, Name, Order__c, Deployment__c, Type__c,dataJson__c, Status__c, CheckOnly__c, Status_Flag__c, Deployment__r.From_Org__c, Branch__c, Commit_Id__c,Commit_Name__c , Git_Repository__c, Git_Repository__r.Name, Run_all_tests__c from Step__c where Deployment__c = :recordId order by Order__c ASC limit 10000];
        return steps;
    }
    public static Step__c getStepById(string recordId){
        Step__c s = [select Id, Name, Order__c, Deployment__c, Type__c,dataJson__c, Status__c, CheckOnly__c, Status_Flag__c, Deployment__r.From_Org__c from Step__c where Id = :EncodingUtil.urlEncode(recordId,'UTF-8') limit 1];
        return s;
    }
    public static Destination_Org__c[] getDestinationOrgsByDeploymentId(string recordId){
        Destination_Org__c[] dos = [select Id, Name, Status__c, Deployment__c, To_Org__c,
         To_Org__r.Name, To_Org_Name__c, To_Org__r.Validated_Date__c,To_Org__r.Validated_Status__c,
         To_Org__r.Last_Apex_Tests_Datetime__c,To_Org__r.Last_Apex_Tests_Status__c,
         To_Org__r.Last_Git_Backup_Datetime__c,To_Org__r.Last_Git_Backup_Status__c
         from Destination_Org__c where Deployment__c = :EncodingUtil.urlEncode(recordId,'UTF-8') order by Name ASC limit 10000];
        return dos;
    }
    public static Destination_Org__c getDestinationOrgsById(string recordId){
         Destination_Org__c dorg = [select Id, Name, Status__c, Deployment__c, To_Org__c, 
            To_Org__r.Name,  To_Org__r.Last_Apex_Tests_Status__c, To_Org__r.Last_Apex_Tests_Datetime__c, 
            To_Org__r.Last_Git_Backup_Status__c,  To_Org__r.Last_Git_Backup_Datetime__c 
            from Destination_Org__c where Id = :EncodingUtil.urlEncode(recordId,'UTF-8') limit 1];
        return dorg;
    }
    //public static List<Add_on__c> getAllAddons(){
    //    Add_on__c[] addons = [select Id, Name, Description__c, Package_Name__c, Visualforce_page__c from Add_on__c order by Name DESC];
    //    return addons;
    //}
    // QUERIES END
    
    public class HerokuResult {
        public boolean success {get;set;}
        public string response {get;set;}
        public string errorMessage {get;set;}
        
        public HerokuResult(boolean b, string r, string em){
            this.success = b;
            this.response = r;
            this.errorMessage = em;
        }
    }
    public class IsufficientAccessException extends Exception{
    }
    public enum DML_Action {INS, UPD, DEL, UPS}
    public static List<SObject> Secure_DML(List<SObject> sobjects, DML_Action action, Schema.DescribeSObjectResult stype){
    	boolean isUpdateable = stype.isUpdateable();
    	boolean isCreateable = stype.isCreateable();
    	boolean isDeleteable = stype.isDeletable();
    	try{
    		if (action == DML_Action.INS){
    			if(!isCreateable)throw new IsufficientAccessException(Label.INSUFFICENT_ACCESS + ': ' +stype.getName());
    			Database.insert(sobjects);
    		}
    		else if(action == DML_Action.UPD){
    			if(!isUpdateable)throw new IsufficientAccessException(Label.INSUFFICENT_ACCESS + ': ' +stype.getName());
    			Database.update(sobjects);
    		}
    		else if(action == DML_Action.DEL){
    			if(!isDeleteable)throw new IsufficientAccessException(Label.INSUFFICENT_ACCESS + ': ' +stype.getName());
    			Database.delete(sobjects);
    		}
    		else if(action == DML_Action.UPS){
    			if(!isCreateable)throw new IsufficientAccessException(Label.INSUFFICENT_ACCESS + ': ' +stype.getName());
    			if(!isUpdateable)throw new IsufficientAccessException(Label.INSUFFICENT_ACCESS + ': ' +stype.getName());
    			List<SObject> upds = new List<SObject>();
    			List<SObject> ins = new List<SObject>();
    			for(SObject s:sobjects){
    				if(s.id == null){ins.add(s);}
    				else{upds.add(s);}
    			}
    			if(upds.size()>0)Database.update(upds);
    			if(ins.size()>0)Database.insert(ins);
    		}
    		return sobjects;
    	}
    	catch (DmlException e){
    		 //in case of a VF context
    		 if(ApexPages.currentPage() != null){
    		 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
    		 }
    		 else{
    		 	System.debug(e.getMessage());
    		 }
    	}
    	return null;
    }
    public static SObject Secure_DML(SObject sob, DML_Action action, Schema.DescribeSObjectResult stype){
    	List<SObject> r = Secure_DML(new List<SObject>{ sob}, action, stype);
    	if(r !=null)return r[0];
    	return null;
    }
    public static SObject Secure_DML(SObject sob, DML_Action action, Schema.DescribeSObjectResult stype, Schema.Describefieldresult fld){
    	SObject r = Secure_DML(sob, action, stype);
    	return r;
    }
    public static List<SObject> Secure_DML(List<SObject> sobjects, DML_Action action, Schema.DescribeSObjectResult stype, Schema.Describefieldresult fld){
    	return Secure_DML(sobjects, action, stype);
    }
    public static Integer randomInteger(Integer min, Integer max)
    {
            Integer i = Math.mod(Integer.valueof(math.random()* 10 * (max+''.length())),max);
                WHILE(i<min)
                    {
                    i += min;
                    if(i>max) i -= max;
                    }
                return i;
    }
    public static void sendEmail(String toAddress, String subject, String body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {toAddress}; 
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName(UserInfo.getName());
        mail.setSubject(subject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static Map<String,String> getAllFields(String sObjectName){
        System.debug(loggingLevel.Error, '*** sObjectName: ' + sObjectName);
        System.debug(loggingLevel.Error, '*** Settings.ns: ' + Settings.ns);
        //Ignore the PermissionSet object for the PermissionSet Explorer
        if (sObjectName != Label.PERMISSION_SET_SOBJECT_NAME) sObjectName = Settings.ns + sObjectName;
        Map<String,String> result = new Map<String,String>();
        if(!Schema.getGlobalDescribe().containsKey(sObjectName)){
            System.debug('INVALID OBJECT ' + sObjectName);
            return null;
        }
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().SObjectType.getDescribe().fields.getMap();
  
        List<String> accessiblefields = new List<String>();
  
        for(Schema.SObjectField field : fields.values()){
            if (field.getDescribe().isAccessible()) {
                accessiblefields.add(field.getDescribe().getName());
            }
        }
  
        String allfields='';
  
        for(String fieldname : accessiblefields)
            allfields += fieldname+',';
  
        allfields = allfields.subString(0,allfields.length()-1);
        
        result.put(Label.OBJECT,sObjectName);
        result.put(Label.FIELDS,allfields);
        return result;
    }

    public static SObject queryAllfields(String sObjectName, String recordId){
        recordId = EncodingUtil.urlEncode(recordId,'UTF-8');
        Map<String,String> d = getAllFields(sObjectName);
        System.debug(loggingLevel.Error, '*** d: ' + d);
        String queryStr = 'SELECT ' + d.get(Label.FIELDS) + ' FROM '+d.get(Label.OBJECT)+' WHERE ID =:recordId';
        System.debug('QUERY: ' + queryStr);
        List<SObject> sos = Database.query(queryStr);
        if(sos.size()>0) return sos.get(0);
        return null;
    }

    public static List<String> getPicklistValues(String sObjectName,String Field_name) { 

        sObjectName = Settings.ns + sObjectName;
        List<String> lstPickvals=new List<String>();
        System.Debug('sObjectName = ' + sObjectName + ' -- Field name = ' + Field_name);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectName);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.add(a.getValue());
        }

        return lstPickvals;
    }
}