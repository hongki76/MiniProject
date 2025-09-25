package com.model2.mvc.web.product;

import java.io.File;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;

// 상품관리 Controller
@Controller
@RequestMapping("/product/*")
public class ProductController {

    // ====== Field ======
    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    @Resource
    private ServletContext servletContext;

	@Value("#{commonProperties['pageUnit']}")
	int pageUnit;
	
	@Value("#{commonProperties['pageSize']}")
	int pageSize;

    // ====== Create ======
	@RequestMapping(value = "addProduct", method = RequestMethod.GET)
	public String addProduct() {
		System.out.println("ProductController.addProduct() - GET");
	    return "/product/addProductView.jsp";
	}

	@RequestMapping(value="addProduct", method=RequestMethod.POST)
	public String addProduct(
	        @ModelAttribute Product product,
	        @RequestParam(value="uploadFile", required=false) MultipartFile file,
	        HttpServletRequest req) throws Exception {

	    if (file != null && !file.isEmpty()) {
	        String uploadDir = req.getServletContext().getRealPath("/upload");
	        File dir = new File(uploadDir);
	        if (!dir.exists()) dir.mkdirs();

	        String original = file.getOriginalFilename();
	        String ext = (original != null && original.lastIndexOf(".") != -1)
	                   ? original.substring(original.lastIndexOf(".")) : "";
	        String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;
	        file.transferTo(new java.io.File(dir, saved));

	        product.setFileName(saved); // ✅ 여기서만 fileName 세팅
	    }

	    // 나머지 필드(prodName, price, manuDate, prodDetail...)는 @ModelAttribute로 바인딩
	    productService.addProduct(product);
	    return "redirect:/product/getProductList";
	}


    // ====== Read ======
    @RequestMapping(value = "getProduct", method = RequestMethod.POST)
    public String getProduct(@RequestParam("prodNo") int prodNo, Model model) throws Exception {   	
    	Product product = productService.getProduct(prodNo);
        model.addAttribute("product", product);
        return "/product/getProduct.jsp";
    }

    // ====== UpdateView ======
    @RequestMapping(value = "updateProductView", method = { RequestMethod.GET, RequestMethod.POST })
    public String updateProductView(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
        Product product = productService.getProduct(prodNo);
        model.addAttribute("product", product);
        return "/product/updateProduct.jsp";
    }

    // ====== Update ======
    @PostMapping(value = "updateProduct", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public String updateProduct(@ModelAttribute("product") Product product,
                                @RequestParam(value = "uploadFile", required = false) MultipartFile file,
                                @RequestParam(value = "oldFileName", required = false) String oldFileName,
                                HttpServletRequest request) throws Exception {

        // 1) manuDate 정규화: 모든 구분자 제거 + YYMMDD → YYYYMMDD 확장 + 유효성 검증
        product.setManuDate(normalizeYYYYMMDD(product.getManuDate()));

        // 2) 업로드 디렉터리 준비
        String uploadDir = request.getServletContext().getRealPath("/upload");
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        // 3) 새 파일 저장
        if (file != null && !file.isEmpty()) {
            String original = file.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf(".") != -1)
                       ? original.substring(original.lastIndexOf(".")) : "";
            String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;
            file.transferTo(new File(dir, saved));
            product.setFileName(saved);

            if (oldFileName != null && !oldFileName.isEmpty() && !oldFileName.equals(saved)) {
                File old = new File(dir, oldFileName);
                if (old.isFile()) try { old.delete(); } catch (Exception ignore) {}
            }
        } else {
            // 4) 새 파일 없으면 기존 유지
            if (product.getFileName() == null || product.getFileName().isEmpty()) {
                if (oldFileName != null && !oldFileName.isEmpty()) {
                    product.setFileName(oldFileName);
                } else {
                    Product db = productService.getProduct(product.getProdNo());
                    if (db != null) product.setFileName(db.getFileName());
                }
            }
        }

        // 5) 업데이트
        productService.updateProduct(product);

        // 6) 상세로
        return "forward:/product/getProduct";
    }

    /**
     * 입력 문자열을 YYYYMMDD로 정규화한다.
     * - 허용 예: "2025-09-01", "2025/09/01", "2025.09.01", "20250901", "25/09/01", "250901"
     * - 규칙: 6자리(YYMMDD)는 00–69 → 20YY, 70–99 → 19YY
     * - 유효하지 않은 날짜나 빈값은 null 반환(= mapper에서 컬럼 유지)
     */
    private String normalizeYYYYMMDD(String raw) {
        if (raw == null) return null;
        String digits = raw.replaceAll("\\D", ""); // 숫자만
        if (digits.isEmpty()) return null;

        String yyyymmdd;
        if (digits.length() == 8) {
            yyyymmdd = digits;
        } else if (digits.length() == 6) {
            String yy = digits.substring(0, 2);
            String mm = digits.substring(2, 4);
            String dd = digits.substring(4, 6);
            int yyNum = Integer.parseInt(yy);
            int century = (yyNum <= 69) ? 2000 : 1900;  // 00–69 => 20xx, 70–99 => 19xx
            yyyymmdd = String.valueOf(century + yyNum) + mm + dd;
        } else {
            return null; // 지원하지 않는 길이 → 컬럼 유지
        }

        // 날짜 유효성 검증 (존재하는 날짜인지 체크)
        try {
            LocalDate.parse(yyyymmdd, DateTimeFormatter.BASIC_ISO_DATE); // yyyyMMdd
            return yyyymmdd;
        } catch (DateTimeParseException ex) {
            return null; // 잘못된 날짜 → 컬럼 유지
        }
    }


    // ====== List ======
    @RequestMapping(value = "getProductList", method = { RequestMethod.GET, RequestMethod.POST })
    public String getProductList(
            @RequestParam(value = "currentPage", required = false, defaultValue = "1") int currentPage,
            @RequestParam(value = "searchCondition", required = false) String searchCondition, // 0:name, 1:detail
            @RequestParam(value = "searchKeyword", required = false) String searchKeyword,
            @RequestParam(value="orderByPriceAsc", required=false) String orderByPriceAsc,
            HttpSession session,
            Model model) throws Exception {

        // Search 세팅
        Search search = new Search();
        search.setCurrentPage(currentPage);
        search.setPageSize(pageSize);
        search.setSearchCondition(searchCondition);
        search.setSearchKeyword(searchKeyword);
        search.setOrderByPriceAsc(orderByPriceAsc);

        Map<String, Object> map = productService.getProductList(search);

        @SuppressWarnings("unchecked")
        List<Product> list = (List<Product>) map.get("list");

        Integer totalCount = (Integer) map.get("totalCount");
        if (totalCount == null) {
            Object alt = map.get("count");
            totalCount = (alt instanceof Integer) ? (Integer) alt : 0;
        }

        // tranState 맵에 담기
        Map<Integer, String> tranStateMap = new HashMap<>();
        if (list != null) {
            for (Product p : list) {
                int proTranCode = 0;

                try {
                    String t = p.getProTranCode();
                    if (t != null) proTranCode = Integer.parseInt(t.trim());
                } catch (Exception ignore) { /* default 0 */ }

                String proTranState = resolveTranState(session, proTranCode);
                tranStateMap.put(p.getProdNo(), proTranState);
                p.setProTranState(proTranState);
            }
        }

        Page resultPage = new Page(currentPage, totalCount, pageUnit, pageSize);

        model.addAttribute("list", list);
        model.addAttribute("tranStateMap", tranStateMap);
        model.addAttribute("resultPage", resultPage);
        model.addAttribute("search", search);

        return "/product/listProduct.jsp";
    }

    // Helper Method
    private String resolveTranState(HttpSession session, int proTranCode) {
        User user = (User)session.getAttribute("user");

        boolean isAdmin = (user != null && "admin".equalsIgnoreCase(user.getRole()));

        if (isAdmin) {
            switch (proTranCode) {
                case 1:  return "구매완료";
                case 2:  return "배송중";
                case 3:  return "배송완료";
                default: return "판매중"; // 0이거나 알 수 없는 코드 포함
            }
        } else {
            return (proTranCode == 0) ? "판매중" : "재고 없음";
        }
    }
}
