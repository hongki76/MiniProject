package com.model2.mvc.service.product.impl;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductFile;
import com.model2.mvc.service.product.ProductDao;
import com.model2.mvc.service.product.ProductService;

@Service("productServiceImpl")
public class ProductServiceImpl implements ProductService {

    @Autowired
    @Qualifier("productDaoImpl")
    private ProductDao productDao;

    @Override
    public void addProduct(Product product) throws Exception {
        productDao.addProduct(product);
    }

    @Override
    public Product getProduct(int prodNo) throws Exception {
        return productDao.getProduct(prodNo);
    }

    @Override
    public HashMap<String, Object> getProductList(Search search) throws Exception {
        List<Product> list = productDao.getProductList(search);
        int totalCount = productDao.getTotalCount(search);
        HashMap<String,Object> map = new HashMap<>();
        map.put("list", list);
        map.put("totalCount", totalCount);
        return map;
    }

    @Override
    public void updateProduct(Product product) throws Exception {
        productDao.updateProduct(product);
    }

    @Override
    public  void addProductFile(int prodNo, String fileName) throws Exception {
        ProductFile productFile = new ProductFile();
        productFile.setProdNo(prodNo);
        productFile.setFileName(fileName);
        productDao.addProductFile(productFile);
    }

    @Override
    public List<ProductFile> getProductFileList(int prodNo) throws Exception {
        return productDao.getProductFileList(prodNo);
    }
    
    @Override
    public void deleteProductFile(int fileNo) throws Exception {
        productDao.deleteProductFile(fileNo);
    }
    
    @Override
    public ProductFile getProductFile(int fileNo) throws Exception {
        return productDao.getProductFile(fileNo);
    }

    @Override
    public List<String> autoCompleteProductName(String prefix, int limit) throws Exception {
    	return productDao.autoCompleteProductName(prefix, limit);
	}

    @Override
    public List<String> autoCompleteRegDate(String prefixYYYYMMDD, int limit) throws Exception {
    	return productDao.autoCompleteRegDate(prefixYYYYMMDD, limit);
	}

}