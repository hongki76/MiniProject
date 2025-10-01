package com.model2.mvc.web.product;

import java.io.File;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.ServletContext;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.product.ProductService;

/**
 * ProductRestController
 * - URL Prefix : /product/json/*
 * - 목록 조회는 @RequestBody(JSON) 한 가지 방식만 사용
 */
@RestController
@RequestMapping("/product/*")
public class ProductRestController {

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    @Resource
    private ServletContext servletContext;

    @Value("#{commonProperties['pageUnit']}")
    int pageUnit;

    @Value("#{commonProperties['pageSize']}")
    int pageSize;

    public ProductRestController() {
        System.out.println("==> ProductRestController 실행됨 : " + this.getClass());
    }

    // =========================
    // Create
    // =========================

    /** 상품 등록(JSON) - 이미지 없이 */
    @PostMapping(
        value = "json/addProduct",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public boolean addProduct(@RequestBody Product product) throws Exception {
        System.out.println("/product/json/addProduct : POST(JSON)");
        productService.addProduct(product);
        return true;
    }

    /** 상품 등록(Multipart) - 이미지 포함 */
    @PostMapping(
        value = "json/addProductMultipart",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public boolean addProductMultipart(@ModelAttribute Product product,
                                       @RequestPart(name = "file", required = false) MultipartFile file) throws Exception {
        System.out.println("/product/json/addProductMultipart : POST(MULTIPART)");

        if (file != null && !file.isEmpty()) {
            String uploadDir = servletContext.getRealPath("/upload");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String original = file.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf('.') != -1)
                    ? original.substring(original.lastIndexOf('.')) : "";
            String savedName = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            file.transferTo(new File(dir, savedName));
            product.setFileName(savedName);
        }
        productService.addProduct(product);
        return true;
    }

    // =========================
    // Read
    // =========================

    /** 상품 상세 조회 */
    @GetMapping("json/getProduct/{prodNo}")
    public Product getProduct(@PathVariable int prodNo) throws Exception {
        System.out.println("/product/json/getProduct : GET, prodNo=" + prodNo);
        return productService.getProduct(prodNo);
    }

    // =========================
    // List (@RequestBody only)
    // =========================

    @PostMapping(
        value = "json/getProductList",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public Map<String, Object> getProductList(@RequestBody Search search) throws Exception {
        System.out.println("/product/json/getProductList : POST(JSON) -> " + search);

        if (search == null) search = new Search();
        // 기본값 보정
        if (search.getCurrentPage() < 1) search.setCurrentPage(1);
        if (search.getPageSize() <= 0)   search.setPageSize(pageSize);

        // 날짜 정규화/유지 (ProductController.getProductList 로직 반영)
        if ("2".equals(search.getSearchCondition())) {
            String norm = normalizeYYYYMMDD(nullToEmpty(search.getSearchKeyword()));
            search.setSearchKeyword(norm);
            search.setRegDateKeyword(norm);
        } else {
            String normHidden = normalizeYYYYMMDD(nullToEmpty(search.getRegDateKeyword()));
            search.setRegDateKeyword(normHidden);
        }

        return buildListResponse(search);
    }

    // =========================
    // Update
    // =========================

    /** 상품 수정(JSON) */
    @PostMapping(
        value = "json/updateProduct",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public boolean updateProduct(@RequestBody Product product) throws Exception {
        System.out.println("/product/json/updateProduct : POST, prodNo=" + product.getProdNo());
        productService.updateProduct(product);
        return true;
    }

    /** 상품 수정(Multipart) - 이미지 교체 포함 */
    @PostMapping(
        value = "json/updateProductMultipart",
        consumes = MediaType.MULTIPART_FORM_DATA_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public boolean updateProductMultipart(@ModelAttribute Product product,
                                          @RequestPart(name = "file", required = false) MultipartFile file) throws Exception {
        System.out.println("/product/json/updateProductMultipart : POST, prodNo=" + product.getProdNo());

        if (file != null && !file.isEmpty()) {
            String uploadDir = servletContext.getRealPath("/upload");
            File dir = new File(uploadDir);
            if (!dir.exists()) dir.mkdirs();

            String original = file.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf(".") != -1)
                    ? original.substring(original.lastIndexOf('.')) : "";
            String savedName = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            file.transferTo(new File(dir, savedName));
            product.setFileName(savedName);
        }
        productService.updateProduct(product);
        return true;
    }
    
    // ===== AutoComplete =====
    @PostMapping(
        value = "json/autoComplete",
        consumes = MediaType.APPLICATION_JSON_VALUE,
        produces = MediaType.APPLICATION_JSON_VALUE
    )
    public java.util.List<String> autoComplete(@RequestBody AutoCompleteRequest req) throws Exception {
        // 기본값
        int limit = (req.getLimit() != null && req.getLimit() > 0 && req.getLimit() <= 20) ? req.getLimit() : 10;
        String cond = req.getSearchCondition(); // "0"(상품명) | "2"(등록일)
        String keyword = req.getKeyword() == null ? "" : req.getKeyword().trim();

        if ("2".equals(cond)) {
            // 등록일 자동완성 (YYYYMMDD prefix)
            return productService.autoCompleteRegDate(keyword, limit);
        } else {
            // 기본: 상품명 자동완성
            return productService.autoCompleteProductName(keyword, limit);
        }
    }

    // =========================
    // Helpers
    // =========================

    /** list + resultPage 포맷 구성 */
    private Map<String, Object> buildListResponse(Search search) throws Exception {
        Map<String, Object> data = productService.getProductList(search);

        int totalCount = 0;
        Object tc = data.get("totalCount");
        if (tc instanceof Integer) totalCount = (Integer) tc;
        else if (tc instanceof Number) totalCount = ((Number) tc).intValue();

        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());

        Map<String, Object> resultPageMap = new HashMap<>();
        resultPageMap.put("currentPage", resultPage.getCurrentPage());
        resultPageMap.put("pageSize",    resultPage.getPageSize());
        resultPageMap.put("totalCount",  resultPage.getTotalCount());
        resultPageMap.put("pageUnit",    resultPage.getPageUnit());

        Map<String, Object> resp = new HashMap<>();
        resp.put("list", data.get("list"));
        resp.put("resultPage", resultPageMap);
        return resp;
    }

    private String nullToEmpty(String s) {
        return s == null ? "" : s;
    }

    /**
     * 입력 문자열을 YYYYMMDD로 정규화한다.
     * - 허용 예: "2025-09-01", "2025/09/01", "2025.09.01", "20250901", "25/09/01", "250901"
     * - 규칙: 6자리(YYMMDD)는 00–69 → 20YY, 70–99 → 19YY
     * - 유효하지 않은 날짜나 빈값은 null 반환
     */
    private String normalizeYYYYMMDD(String raw) {
        if (raw == null) return null;
        String digits = raw.replaceAll("\\D", "");
        if (digits.isEmpty()) return null;

        String yyyymmdd;
        if (digits.length() == 8) {
            yyyymmdd = digits;
        } else if (digits.length() == 6) {
            String yy = digits.substring(0, 2);
            String mm = digits.substring(2, 4);
            String dd = digits.substring(4, 6);
            int yyNum = Integer.parseInt(yy);
            int century = (yyNum <= 69) ? 2000 : 1900;
            yyyymmdd = String.valueOf(century + yyNum) + mm + dd;
        } else {
            return null;
        }

        try {
            LocalDate.parse(yyyymmdd, DateTimeFormatter.BASIC_ISO_DATE);
            return yyyymmdd;
        } catch (DateTimeParseException ex) {
            return null;
        }
    }
    
    // 간단 DTO
    public static class AutoCompleteRequest {
        private String searchCondition; // "0" or "2"
        private String keyword;         // 사용자가 입력한 값
        private Integer limit;          // 옵션

        public String getSearchCondition() { return searchCondition; }
        public void setSearchCondition(String v) { this.searchCondition = v; }
        public String getKeyword() { return keyword; }
        public void setKeyword(String v) { this.keyword = v; }
        public Integer getLimit() { return limit; }
        public void setLimit(Integer v) { this.limit = v; }
    }
}
