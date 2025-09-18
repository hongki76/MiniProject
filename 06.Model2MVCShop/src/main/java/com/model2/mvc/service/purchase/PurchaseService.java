package com.model2.mvc.service.purchase;

import java.util.HashMap;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;

public interface PurchaseService {
    void addPurchase(Purchase p) throws Exception;
    
    Purchase getPurchase(int tranNo) throws Exception;
    
    HashMap<String,Object> getPurchaseList(Search search, String buyerId) throws Exception;
    
    void updateTranCode(int tranNo, String tranStatusCode) throws Exception;
    
    void updateTranCodeByProduct(int prodNo, String tranStatusCode) throws Exception;
    
    String getTranCode(int prodNo) throws Exception;
}