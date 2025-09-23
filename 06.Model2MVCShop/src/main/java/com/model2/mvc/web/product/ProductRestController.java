package com.model2.mvc.web.product;

import java.io.File;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.product.ProductService;

/**
 * ProductRestController.java
 * 상품 관리를 위한 RESTful API 컨트롤러
 * URL Prefix : /product/json/
 */
@RestController
@RequestMapping("/product/*")
public class ProductRestController {

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    @Resource
    private ServletContext servletContext;

    public ProductRestController() {
        System.out.println("==> ProductRestController 실행됨 : " + this.getClass());
    }

    /**
     * 상품 등록 (JSON 전송: 이미지 없이)
     * Content-Type: application/json
     */
    @PostMapping(value = "json/addProduct", consumes = MediaType.APPLICATION_JSON_VALUE)
    public boolean addProduct(@RequestBody Product product) throws Exception {
        System.out.println("/product/json/addProduct : POST(JSON) 호출됨");
        // 이미지가 없다면 fileName은 null 또는 프론트에서 보내준 값 사용
        productService.addProduct(product);
        return true;
    }

    /**
     * 상품 등록 (멀티파트 전송: 이미지 포함)
     * Content-Type: multipart/form-data
     * - product : JSON 직렬화된 문자열이 아니라, 필드별 전송 시 @ModelAttribute Product 사용
     * - file    : 이미지 파일 (선택)
     */
    @PostMapping(value = "json/addProductMultipart", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public boolean addProductMultipart(@ModelAttribute Product product,
                                       @RequestPart(name = "file", required = false) MultipartFile file) throws Exception {
        System.out.println("/product/json/addProductMultipart : POST(MULTIPART) 호출됨");

        if (file != null && !file.isEmpty()) {
            String uploadDir = servletContext.getRealPath("/upload");
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                boolean mk = dir.mkdirs();
                System.out.println("  - 업로드 디렉토리 생성 : " + mk + " (" + uploadDir + ")");
            }

            String original = file.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf(".") != -1)
                    ? original.substring(original.lastIndexOf("."))
                    : "";
            String savedName = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            file.transferTo(new File(dir, savedName));
            product.setFileName(savedName);
        }

        productService.addProduct(product);
        return true;
    }

    /**
     * 상품 상세 조회
     */
    @GetMapping("json/getProduct/{prodNo}")
    public Product getProduct(@PathVariable int prodNo) throws Exception {
        System.out.println("/product/json/getProduct : GET 호출됨, prodNo=" + prodNo);
        return productService.getProduct(prodNo);
    }

    /**
     * 상품 리스트 조회 (검색 + 페이징)
     * Content-Type: application/json
     * Body: Search { currentPage, pageSize, searchCondition, searchKeyword, orderByPriceAsc }
     *
     * 반환: { list: List<Product>, totalCount: int, ... }
     */
    @PostMapping(value = "json/getProductList", consumes = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> getProductList(@RequestBody Search search) throws Exception {
        System.out.println("/product/json/getProductList : POST 호출됨 -> " + search);
        return productService.getProductList(search);
    }

    /**
     * 상품 수정
     * Content-Type: application/json
     */
    @PostMapping(value = "json/updateProduct", consumes = MediaType.APPLICATION_JSON_VALUE)
    public boolean updateProduct(@RequestBody Product product) throws Exception {
        System.out.println("/product/json/updateProduct : POST 호출됨, prodNo=" + product.getProdNo());
        productService.updateProduct(product);
        return true;
    }

    /**
     * 상품 수정 (멀티파트: 이미지 교체 포함)
     * 필요 시 사용. 파일이 없으면 기존 파일명 유지되도록 프론트에서 제어하거나,
     * 여기서도 null 체크 후 미전송 시 기존 값을 유지하도록 처리 가능.
     */
    @PostMapping(value = "json/updateProductMultipart", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public boolean updateProductMultipart(@ModelAttribute Product product,
                                          @RequestPart(name = "file", required = false) MultipartFile file) throws Exception {
        System.out.println("/product/json/updateProductMultipart : POST 호출됨, prodNo=" + product.getProdNo());

        if (file != null && !file.isEmpty()) {
            String uploadDir = servletContext.getRealPath("/upload");
            File dir = new File(uploadDir);
            if (!dir.exists()) {
                boolean mk = dir.mkdirs();
                System.out.println("  - 업로드 디렉토리 생성 : " + mk + " (" + uploadDir + ")");
            }

            String original = file.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf(".") != -1)
                    ? original.substring(original.lastIndexOf("."))
                    : "";
            String savedName = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            file.transferTo(new File(dir, savedName));
            product.setFileName(savedName);
        }
        // file이 없을 경우: product.getFileName() 이 null이면 기존 파일 유지 로직은
        // Service/DAO 단에서 필요 시 보완 (select 후 merge 등)

        productService.updateProduct(product);
        return true;
    }
}
