global class LeadHandler {
  global static Map<Id, Lead> mapMembersLeads;

  /*
   * @Method          :   beforeInsert
   * @Author          :   Lisis Rodriguez <lisis.rodriguez@empaua.com>
   * @Created         :   3 April 2019
   * @Description     :   Call the actions that handle the before insert trigger
   */    
  global  void beforeInsert(List<Lead> listNew){
    
    //Round robin owner assignment
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Flexioffices Search' LIMIT 1];
        Id currentUserId = UserInfo.getUserId();
        if(currentUserId == userList[0].Id) {
      mapMembersLeads = new Map<Id, Lead> ();
            LeadAssignmentHelper.assignLead(listNew);
      LeadHelper.roundRobinLeadsAssigment(listNew,mapMembersLeads);
    }

    LeadHelper.checkIfGoogleAnalyticsCode(listNew);
  }

  /*
   * @Method          :   beforeUpdate
   * @Author          :   
   * @Created         :   
   * @Description     :   Call the actions that handle the before update trigger
   */    
  public void beforeUpdate(Map<Id, Lead> mapNew,Map<Id, Lead> mapOld){
    LeadHelper.updateGATypeOnUpdate(mapNew,mapOld);
  }

  /*
   * @Method          :   beforeDelete
   * @Author          :   
   * @Created         :   
   * @Description     :   Call the actions that handle the before delete trigger
   */
  //public  void beforeDelete(List<Lead> listOld, Map<Id, Lead> mapOld){
  //}

  /*
   * @Method          :   afterInsert
   * @Author          :   
   * @Created         :   
   * @Description     :   Call the actions that handle the after insert trigger
   */    
  global  void afterInsert(List<Lead> listNew,Map<Id, Lead> mapNew){
    
    //Round robin update members
        List<User> userList = [SELECT Id FROM User WHERE Name = 'Flexioffices Search' LIMIT 1];
        Id currentUserId = UserInfo.getUserId();
        if(currentUserId == userList[0].Id) {
      LeadHelper.updateMembers(mapMembersLeads);
    }
    
    //CallBack to Mitel
    LeadHelper.sendCallBack(listNew);
    
  //  LeadHelper.GAAPiTracking(mapNew, mapOld);
  }

  /*
   * @Method          :   afterUpdate
   * @Author          :   
   * @Created         :   
   * @Description     :   Call the actions that handle the after update trigger
   */    
  global void afterUpdate(List<Lead> listNew, Map<Id, Lead> mapNew, List<Lead> lstOld, Map<Id, Lead> mapOld) {

    LeadHelper.GAAPiTracking(mapNew,mapOld);
    LeadHelper.DCAPiTracking(mapNew,mapOld);
    
  }
  /*
   * @Method          :   afterDelete
   * @Author          :   
   * @Created         :   
   * @Description     :   Call the actions that handle the after delete trigger
   */    
  /*public  void afterDelete(List<Lead> listOld, Map<Id, Lead> mapOld){


  }

  /*
   * @Method          :   unDelete
   * @Author          :   
   * @Created         :   
   * @Description     :   Call the actions that handle the undelete trigger
   */    
  //public void OnUndelete(List<Lead> lstOld){
  //}
}