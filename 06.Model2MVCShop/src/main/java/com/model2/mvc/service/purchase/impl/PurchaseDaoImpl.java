package com.model2.mvc.service.purchase.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.purchase.PurchaseDao;

@Repository("purchaseDaoImpl")
public class PurchaseDaoImpl implements PurchaseDao {

    @Autowired
    @Qualifier("sqlSessionTemplate")
    private SqlSession sqlSession;

    @Override
    public void addPurchase(Purchase p) throws Exception {
        sqlSession.insert("PurchaseMapper.addPurchase", p);
    }

    @Override
    public Purchase getPurchase(int tranNo) throws Exception {
        return sqlSession.selectOne("PurchaseMapper.getPurchase", tranNo);
    }

    @Override
    public List<Purchase> getPurchaseList(Search search, String buyerId) throws Exception {
        Map<String,Object> map = new HashMap<>();
        map.put("buyerId", buyerId);
        map.put("search", search);
        return sqlSession.selectList("PurchaseMapper.getPurchaseList", map);
    }

    @Override
    public int getTotalCount(String buyerId) throws Exception {
        return sqlSession.selectOne("PurchaseMapper.getTotalCount", buyerId);
    }

    @Override
    public void updateTranCode(int tranNo, String tranStatusCode) throws Exception {
        Map<String,Object> map = new HashMap<>();
        map.put("tranNo", tranNo);
        map.put("tranStatusCode", tranStatusCode);
        sqlSession.update("PurchaseMapper.updateTranCode", map);
    }
    
	    @Override
	    public int updateTranCodeByProduct(int prodNo, String tranStatusCode) throws Exception {
	        Map<String,Object> map = new HashMap<>();
	        map.put("prodNo", prodNo);
	        map.put("tranStatusCode", tranStatusCode);
	        return sqlSession.update("PurchaseMapper.updateTranCodeByProduct", map);
	    }

    @Override
    public String getTranCode(int prodNo) throws Exception {
        return sqlSession.selectOne("PurchaseMapper.getTranCode", prodNo);
    }
}