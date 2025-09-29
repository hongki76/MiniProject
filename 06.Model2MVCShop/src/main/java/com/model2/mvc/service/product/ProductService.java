package com.model2.mvc.service.product;

import java.util.HashMap;
import java.util.List;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductFile;

public interface ProductService {

    public void addProduct(Product product) throws Exception;

    public Product getProduct(int prodNo) throws Exception;

    public HashMap<String, Object> getProductList(Search search) throws Exception;

    public void updateProduct(Product product) throws Exception;
    
    public  void addProductFile(int prodNo, String fileName) throws Exception;
    
    public List<ProductFile> getProductFileList(int prodNo) throws Exception;
    
    public void deleteProductFile(int fileNo) throws Exception;
    
    public ProductFile getProductFile(int fileNo) throws Exception;
    
}