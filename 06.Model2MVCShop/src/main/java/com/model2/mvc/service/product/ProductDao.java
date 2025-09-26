package com.model2.mvc.service.product;

import java.util.List;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.ProductFile;

public interface ProductDao {

    public void addProduct(Product product) throws Exception;

    public Product getProduct(int prodNo) throws Exception;

    public List<Product> getProductList(Search search) throws Exception;

    public int getTotalCount(Search search) throws Exception;

    public void updateProduct(Product product) throws Exception;
    
    public  void addProductFile(ProductFile productFile) throws Exception;

    public List<ProductFile> getProductFileList(int prodNo) throws Exception;
    
    void deleteProductFile(int fileNo) throws Exception;
    
    ProductFile getProductFile(int fileNo) throws Exception;
}