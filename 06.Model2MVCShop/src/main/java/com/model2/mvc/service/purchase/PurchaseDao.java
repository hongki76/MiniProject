package com.model2.mvc.service.purchase;

import java.util.List;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;

public interface PurchaseDao {
    void addPurchase(Purchase p) throws Exception;
    
    Purchase getPurchase(int tranNo) throws Exception;

    List<Purchase> getPurchaseList(Search search, String buyerId) throws Exception;
    
    int getTotalCount(String buyerId) throws Exception;

    void updateTranCode(int tranNo, String tranStatusCode) throws Exception;
    
    int updateTranCodeByProduct(int prodNo, String tranStatusCode) throws Exception;
    
    String getTranCode(int prodNo) throws Exception;
    
    int selectTranStatusCode(int tranNo) throws Exception;
    
    int deleteByTranNo(int tranNo) throws Exception;
}