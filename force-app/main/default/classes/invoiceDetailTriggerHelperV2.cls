Public with sharing class invoiceDetailTriggerHelperV2 {
    Public static voId invoiceDetailTriggerHelper(list<invoice_detail__c> Invoices){
        Map<String,Map<Id,InvoiceMargins>> EvaluatedInvoicesByOpportunity = New Map<String,Map<Id,InvoiceMargins>>();
        Map<String,Map<Id,InvoiceMargins>> EvaluatedInvoicesByaccount = New Map<String,Map<Id,InvoiceMargins>>();
        Set<Id> OpportunityIds = New Set<Id>();
        Set<Id> AccountIds = New Set<Id>();
        List<OpportunitySplit> OpportunitySplits = New List<OpportunitySplit>();
        
        Map<string,Map<Id,list<Splits>>> SplitByOppViaProfiles = New Map<string,Map<Id,list<Splits>>>();
        Map<string,Map<Id,list<Splits>>> SplitByAccViaProfiles = New Map<string,Map<Id,list<Splits>>>();

        String oldDate;
        for(invoice_detail__c itr : Invoices)
        {
            date current_date = itr.invoice_date__c;
            
            String datee = CommissionCalculatorConstants.monthByNumber.get(current_date.month())+ '-'+ String.valueOf(current_date.year());
            if(itr.Opportunity__c != null)
            {
                if(EvaluatedInvoicesByOpportunity.containsKey(datee))
                {
                    if(EvaluatedInvoicesByOpportunity.get(datee).containsKey(itr.Opportunity__c))
                    {
                        EvaluatedInvoicesByOpportunity.Get(datee).Put(itr.Opportunity__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(EvaluatedInvoicesByOpportunity.get(datee).get(itr.Opportunity__c),itr));    
                    }
                    else {

                        OpportunityIds.add(itr.Opportunity__c);

                        EvaluatedInvoicesByOpportunity.Get(datee).Put(itr.Opportunity__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));    
                    }
                }
                else {
                    OpportunityIds.add(itr.Opportunity__c);
                    //Map<Id,InvoiceMargins> InvoiceDetail = New Map<Id,InvoiceMargins>();
                    //InvoiceDetail.put(itr.Opportunity__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));
                    EvaluatedInvoicesByOpportunity.put(datee , new map<Id,InvoiceMargins>{itr.Opportunity__c => invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr)});
                }
            }
            // If Opportunity Id does Not Exist
            else 
            {
                if(EvaluatedInvoicesByaccount.containsKey(datee))
                {
                    if(EvaluatedInvoicesByaccount.get(datee).containsKey(itr.Account__c))
                    {
                        EvaluatedInvoicesByaccount.Get(datee).Put(itr.Account__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(EvaluatedInvoicesByaccount.get(datee).get(itr.Account__c),itr));    
                    }
                    else {
                        OpportunityIds.add(itr.Account__c);
                        EvaluatedInvoicesByaccount.Get(datee).Put(itr.Account__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));    
                    }
                }
                else {
                    OpportunityIds.add(itr.Account__c);
                    //Map<Id,InvoiceMargins> InvoiceDetail = New Map<Id,InvoiceMargins>();
                    //InvoiceDetail.put(itr.Account__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));
                    //EvaluatedInvoicesByaccount.put(datee , InvoiceDetail);
                    EvaluatedInvoicesByaccount.put(datee , new map<Id,InvoiceMargins>{itr.Account__c => invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr)});
                }
            }
        }
        system.debug('All Invoices By Dates And Opportunity : '+EvaluatedInvoicesByOpportunity );
        OpportunitySplits = OpportunitySplitSelector.GetOpportunitySplitByOpportunity(OpportunityIds);
        list<id> Repportunityids = new list<id>();
        for(OpportunitySplit split :OpportunitySplits){
            if(OpportunityIds.contains(split.OpportunityId))
            {
                Repportunityids.add(split.OpportunityId);
            }
            if(SplitByOppViaProfiles.containsKey(split.SplitOwner.Profile.Name))
            {
                if(SplitByOppViaProfiles.Get(split.SplitOwner.Profile.Name).containsKey(split.OpportunityId))
                {
                    SplitByOppViaProfiles.Get(split.SplitOwner.Profile.Name).get(split.OpportunityId).add( New Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage));   
                }
                else {
                    SplitByOppViaProfiles.Get(split.SplitOwner.Profile.Name).put(split.OpportunityId , New  List<Splits> {new Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage)});   
                }
            }
            else {
                SplitByOppViaProfiles.Put(split.SplitOwner.Profile.Name ,new map<id,list<Splits>>{split.OpportunityId => New List<Splits>{New Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage)}});
            }
        }
        OpportunityIds.removeAll(Repportunityids);
        
        for(Opportunity Opportunity :OpportunitySelector.GetOpportunitiesById(opportunityIds))
        {
            if(SplitByOppViaProfiles.containsKey(Opportunity.owner.profile.Name))
            {
                if(SplitByOppViaProfiles.Get(Opportunity.owner.profile.Name).containsKey(Opportunity.id))
                {
                    SplitByOppViaProfiles.Get(Opportunity.owner.profile.Name).get(Opportunity.id).add( New Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100));   
                } 
                else{
                    SplitByOppViaProfiles.Get(Opportunity.owner.profile.Name).put(Opportunity.id , New  List<Splits> {new Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100)});   
                }
            }
            else {
                SplitByOppViaProfiles.Put(Opportunity.owner.profile.Name ,new map<id,list<Splits>>{opportunity.id => New List<Splits>{New Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100)}});
            }
        }
        system.debug('All Profiles By  Opportunity : '+SplitByOppViaProfiles );
    }
    Public class Splits{
        Public Id ownerId;
        Public String ownerProfile;
        Public Decimal split;
        Public splits(Id ownerId,String ownerProfile,Decimal split){
            This.ownerId = ownerId;
            This.ownerProfile = ownerProfile;
            This.split = split;
        }
    }   
}