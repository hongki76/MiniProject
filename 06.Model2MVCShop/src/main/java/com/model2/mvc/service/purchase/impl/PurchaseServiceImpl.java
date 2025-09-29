package com.model2.mvc.service.purchase.impl;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
    
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelPurchase(int tranNo) throws Exception {
        int status = purchaseDao.selectTranStatusCode(tranNo);

        // 0(판매중), 1(구매완료)만 취소 허용
        if (status != 0 && status != 1) {
        	System.out.println("### PurchaseServiceImpl.cancelPurchase() - status(" + status + ")");
            throw new IllegalStateException("현재 상태에서는 주문 취소가 불가합니다. (status=" + status + ")");
        }

        int deleted = purchaseDao.deleteByTranNo(tranNo);
        if (deleted != 1) {
        	System.out.println("### PurchaseServiceImpl.cancelPurchase() - deleted(" + deleted + ")");        	
            throw new IllegalStateException("주문 취소 처리에 실패했습니다. 삭제된 행 수=" + deleted);
        }
        
        System.out.println("### PurchaseServiceImpl.cancelPurchase() - deleted(" + deleted + ")");
    }
}