package com.model2.mvc.service.product.impl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductFile;
import com.model2.mvc.service.product.ProductDao;

@Repository("productDaoImpl")
public class ProductDaoImpl implements ProductDao {

    @Autowired
    @Qualifier("sqlSessionTemplate")
    private SqlSession sqlSession;

    @Override
    public void addProduct(Product product) throws Exception {
        sqlSession.insert("ProductMapper.addProduct", product);
    }

    @Override
    public Product getProduct(int prodNo) throws Exception {
        return sqlSession.selectOne("ProductMapper.getProduct", prodNo);
    }

    @Override
    public List<Product> getProductList(Search search) throws Exception {
        return sqlSession.selectList("ProductMapper.getProductList", search);
    }

    @Override
    public int getTotalCount(Search search) throws Exception {
        return sqlSession.selectOne("ProductMapper.getTotalCount", search);
    }

    @Override
    public void updateProduct(Product product) throws Exception {
        sqlSession.update("ProductMapper.updateProduct", product);
    }

    @Override
    public  void addProductFile(ProductFile productFile) throws Exception {
    	sqlSession.insert("ProductMapper.addProductFile", productFile);
    }

    @Override
    public List<ProductFile> getProductFileList(int prodNo) throws Exception {
    	return sqlSession.selectList("ProductMapper.getProductFileList", prodNo);
    }
    
    @Override
    public void deleteProductFile(int fileNo) throws Exception {
        sqlSession.delete("ProductMapper.deleteProductFile", fileNo);
    }
    
    @Override
    public ProductFile getProductFile(int fileNo) throws Exception {
        return sqlSession.selectOne("ProductMapper.getProductFile", fileNo);
    }
    
    // =========================
    // AutoComplete: 상품명
    // =========================
    @Override
    public List<String> autoCompleteProductName(String prefix, int limit) {
        Map<String, Object> param = new HashMap<>();
        param.put("keywordEsc", escapeLike(prefix)); // %/_/\ 이스케이프
        param.put("limit",  limit);                  // 0 또는 음수 ⇒ 전부
        return sqlSession.selectList("ProductMapper.autoCompleteProductName", param);
    }

    /** LIKE ESCAPE '\' 대비: %, _ , \ 를 이스케이프 */
    private static String escapeLike(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("%",  "\\%")
                .replace("_",  "\\_");
    }

    // =========================
    // AutoComplete: 등록일
    // =========================
    @Override
    public List<String> autoCompleteRegDate(String prefixYYYYMMDD, int limit) {
        Map<String, Object> param = new HashMap<>();
        param.put("prefix", prefixYYYYMMDD);
        param.put("limit",  limit);
        return sqlSession.selectList("ProductMapper.autoCompleteRegDate", param);
    }
}