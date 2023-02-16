Public with sharing class invoiceDetailTriggerHelperV2 {
    Public static voId invoiceDetailTriggerHelper(Map<Id,invoice_detail__c> Invoices){
        
        Map<String,Map<Id,InvoiceMargins>> oldEvaluatedInvoicesByOpportunity = New Map<String,Map<Id,InvoiceMargins>>();
        Map<Id,InvoiceMargins> NewEvaluatedInvoicesByOpportunity = New Map<Id,InvoiceMargins>();
        Map<String,Map<Id,InvoiceMargins>> oldEvaluatedInvoicesByaccount = New Map<String,Map<Id,InvoiceMargins>>();
        Map<Id,InvoiceMargins> NewEvaluatedInvoicesByaccount = New Map<Id,InvoiceMargins>();

        Set<Id> oldOpportunityIds = New Set<Id>();
        Set<Id> NewOpportunityIds = New Set<Id>();

        List<OpportunitySplit> oldOpportunitySplits = New List<OpportunitySplit>();
        List<OpportunitySplit> NewOpportunitySplits = New List<OpportunitySplit>();
        
        Map<Id,list<Splits>> oldSplitByOpp = New Map<Id,list<Splits>>();
        Map<Id,list<Splits>> NewSplitByOpp = New Map<Id,list<Splits>>();

        Double totalSales =0;
        Double tileSales =0;
        Double AncillarySales =0;
        Double tileMargin =0;
        Double AncillaryMargin =0;
        Double tileMarginPercentage =0;
        Double ancillaryMarginPercentage =0;
        String oldDate;
        for(invoice_detail__c itr : Invoices.values())
        {
            date current_date = itr.invoice_date__c;
            String datee = String.valueOf(current_date.month())+ ' '+ String.valueOf(current_date.year());
            
            if(itr.Opportunity__c != null)
            {
                if(current_date.year() < date.today().year() || current_date.month() < date.today().month())
                {
                    oldDate = datee;
                    // Handeling Old month and year invoives detail  data Via opp
                    if(oldEvaluatedInvoicesByOpportunity.containsKey(datee) == NULL)
                    {
                        Map<Id,InvoiceMargins> oldInvoiceDetail = New Map<Id,InvoiceMargins>();
                        oldInvoiceDetail.Put(itr.Opportunity__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));
                        oldEvaluatedInvoicesByOpportunity.Put(datee , oldInvoiceDetail);
                    }
                    else {
                        if(oldEvaluatedInvoicesByOpportunity.Get(datee).containsKey(itr.opportunity__c)== NULL)
                        {
                            oldEvaluatedInvoicesByOpportunity.Get(datee).Put(itr.Opportunity__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));    
                        }
                        else {
                            oldEvaluatedInvoicesByOpportunity.Get(datee).Put(itr.Opportunity__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(oldEvaluatedInvoicesByOpportunity.Get(datee).Get(itr.opportunity__c),itr));    
                        }
                        
                    }
                }
                // Handeling New month and year invoives detail  data Via opp
                else {
                    
                    if(NewEvaluatedInvoicesByOpportunity.Get(itr.opportunity__c) != NULL)
                    {
                        NewEvaluatedInvoicesByOpportunity.Put(itr.opportunity__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations( NewEvaluatedInvoicesByOpportunity.Get(itr.opportunity__c) ,itr));
                    }
                    else {
                        NewEvaluatedInvoicesByOpportunity.Put(itr.opportunity__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));   
                    }
                }
            }
            // If Opportunity Id does Not Exixst
            else 
            {
                if(current_date.year() < date.today().year() || current_date.month() < date.today().month()){
                    
                    // Handeling Old month and year invoives detail  data Via opp
                    if(oldEvaluatedInvoicesByAccount.containsKey(datee) == NULL)
                    {
                        Map<Id,InvoiceMargins> oldInvoiceDetail = New Map<Id,InvoiceMargins>();
                        oldInvoiceDetail.Put(itr.Account__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));
                        oldEvaluatedInvoicesByAccount.Put(datee , oldInvoiceDetail);
                    }
                    else {
                        if(oldEvaluatedInvoicesByAccount.Get(datee).containsKey(itr.Account__c)== NULL)
                        {
                            oldEvaluatedInvoicesByAccount.Get(datee).Put(itr.Account__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));    
                        }
                        else {
                            oldEvaluatedInvoicesByAccount.Get(datee).Put(itr.Account__c,invoiceDetailTriggerHandlerService.invoiceMarginCalculations(oldEvaluatedInvoicesByAccount.Get(datee).Get(itr.Account__c),itr));    
                        }
                        
                    }
                }
                // Handeling New month and year invoives detail  data Via opp
                else {
                    
                    if(NewEvaluatedInvoicesByAccount.Get(itr.Account__c) != NULL)
                    {
                        NewEvaluatedInvoicesByAccount.Put(itr.Account__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations( NewEvaluatedInvoicesByAccount.Get(itr.Account__c) ,itr));
                    }
                    else {
                        NewEvaluatedInvoicesByAccount.Put(itr.Account__c , invoiceDetailTriggerHandlerService.invoiceMarginCalculations(New InvoiceMargins(),itr));   
                    }
                }   
            }
        }
        oldOpportunityIds = oldEvaluatedInvoicesByOpportunity.Get(oldDate).keySet();
        oldOpportunitySplits = OpportunitySplitSelector.GetOpportunitySplitByOpportunity(oldOpportunityIds);
        
        NewOpportunityIds = NewEvaluatedInvoicesByOpportunity.keySet();
        NewOpportunitySplits = OpportunitySplitSelector.GetOpportunitySplitByOpportunity(NewOpportunityIds);
        
        for(OpportunitySplit split :NewOpportunitySplits){
            if(NewOpportunityIds.contains(split.opportunity))
            {
                NewOpportunityIds.removeAll( New list<Id>{split.opportunity});
            }
            if(NewSplitByOpp.containsKey(split.opportunity))
            {
                NewSplitByOpp.Get(split.opportunity).add( New Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage));
            }
            else {
                NewSplitByOpp.Put(split.opportunity ,New List<Splits>{New Splits(split.SplitOwnerId,split.SplitOwner.Profile.Name,split.SplitPercentage)} );
            }
        }
        for(Opportunity Opportunity :OpportunitySelector.GetOpportunitiesById(opportunityIds)){
            if(NewSplitByOpp.containsKey(Opportunity.Id)){
                NewSplitByOpp.Get(Opportunity.Id).add(New Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100));
            }
            else{
                NewSplitByOpp.Put(Opportunity.Id,New List<Splits>{New Splits(Opportunity.OwnerId,Opportunity.owner.profile.name,100)});
            }
        }
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