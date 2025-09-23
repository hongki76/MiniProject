package com.model2.mvc.service.purchase.impl;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.purchase.PurchaseDao;
import com.model2.mvc.service.purchase.PurchaseService;

@Service("purchaseServiceImpl")
public class PurchaseServiceImpl implements PurchaseService {

    @Autowired
    @Qualifier("purchaseDaoImpl")
    private PurchaseDao purchaseDao;

    @Override
    public void addPurchase(Purchase p) throws Exception {
        purchaseDao.addPurchase(p);
    }

    @Override
    public Purchase getPurchase(int tranNo) throws Exception {
        return purchaseDao.getPurchase(tranNo);
    }

    @Override
    public HashMap<String, Object> getPurchaseList(Search search, String buyerId) throws Exception {
    	System.out.println("### PurchaseServiceImpl.getPurchaseList() - search.StartRownNum(" + search.getStartRowNum() + ")");
    	System.out.println("### PurchaseServiceImpl.getPurchaseList() - search.EndRowNum(" + search.getEndRowNum() + ")");
    	System.out.println("### PurchaseServiceImpl.getPurchaseList() - buyerId(" + buyerId + ")");
    	
        List<Purchase> list = purchaseDao.getPurchaseList(search, buyerId);
        int totalCount = purchaseDao.getTotalCount(buyerId);
        HashMap<String,Object> map = new HashMap<>();
        map.put("list", list);
        map.put("totalCount", totalCount);
        return map;
    }

    @Override
    public void updateTranCode(int tranNo, String tranStatusCode) throws Exception {
        purchaseDao.updateTranCode(tranNo, tranStatusCode);
    }
    
    @Override
    public int updateTranCodeByProduct(int prodNo, String tranStatusCode) throws Exception {
        return purchaseDao.updateTranCodeByProduct(prodNo, tranStatusCode);
    }

    @Override
    public String getTranCode(int prodNo) throws Exception {
        return purchaseDao.getTranCode(prodNo);
    }
}