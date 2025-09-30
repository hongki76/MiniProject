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
import com.model2.mvc.service.domain.ProductFile;
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
	        @RequestParam(value="productFile", required=false) MultipartFile[] productFiles,
	        HttpServletRequest req) throws Exception {

		// 상품정보 DB 저장
	    productService.addProduct(product);

	    // 상품 파일명 DB 저장
	    if (productFiles != null && productFiles.length > 0) {
	        addProductFiles(product.getProdNo(), req, productFiles);
	    }
	    
	    return "redirect:/product/getProductList";
	}

	private void addProductFiles(int prodNo,
	                             HttpServletRequest req,
	                             MultipartFile[]... fileGroups) throws Exception {

	    // 0) 병합/평탄화
	    java.util.List<MultipartFile> files = new java.util.ArrayList<>();
	    if (fileGroups != null) {
	        for (MultipartFile[] grp : fileGroups) {
	            if (grp == null) continue;
	            for (MultipartFile f : grp) {
	                if (f != null && !f.isEmpty()) files.add(f);
	            }
	        }
	    }
	    if (files.isEmpty()) return;

	    // 1) 저장 경로 준비
	    String uploadDir = req.getServletContext().getRealPath("/upload");
	    File dir = new File(uploadDir);
	    if (!dir.exists()) dir.mkdirs();

	    // (선택) 제한/필터 — 필요 없으면 제거
	    final int MAX_COUNT = 100;        // 최대 개수
	    final long MAX_SIZE = 50L * 1024 * 1024; // 총 50MB
	    long total = 0L;
	    if (files.size() > MAX_COUNT) {
	        throw new IllegalArgumentException("첨부파일은 최대 " + MAX_COUNT + "개까지 가능합니다.");
	    }

	    // 2) 저장 + DB 등록
	    for (MultipartFile f : files) {
	        total += f.getSize();
	        if (total > MAX_SIZE) {
	            throw new IllegalArgumentException("첨부 총 용량이 " + (MAX_SIZE / (1024*1024)) + "MB를 초과했습니다.");
	        }

	        String original = f.getOriginalFilename();
	        String ext = (original != null && original.lastIndexOf('.') != -1)
	                   ? original.substring(original.lastIndexOf('.')) : "";
	        String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

	        f.transferTo(new File(dir, saved));

	        // PRODUCT_FILE insert
	        productService.addProductFile(prodNo, saved);
	    }
	}

    // ====== Read ======
	@RequestMapping(value = "getProduct", method = RequestMethod.POST)
	public String getProduct(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
	    Product product = productService.getProduct(prodNo);
	    model.addAttribute("product", product);

	    List<ProductFile> fileList = productService.getProductFileList(prodNo);
	    model.addAttribute("fileList", fileList);
	    return "/product/getProduct.jsp";
	}

	// ====== UpdateView ======
	@RequestMapping(value = "updateProductView", method = { RequestMethod.GET, RequestMethod.POST })
	public String updateProductView(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
	    // 1) 상품
	    Product product = productService.getProduct(prodNo);
	    model.addAttribute("product", product);

	    // 2) 기존 첨부파일 목록
	    java.util.List<com.model2.mvc.service.domain.ProductFile> fileList =
	            productService.getProductFileList(prodNo);
	    model.addAttribute("fileList", fileList);

	    // 3) 뷰
	    return "/product/updateProduct.jsp";
	}


	// ====== Update ======
	@PostMapping(value = "updateProduct", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
	public String updateProduct(@ModelAttribute("product") Product product,
	                            @RequestParam(value = "productFile", required = false) MultipartFile[] productFiles, // ✅ 새 첨부(복수)
	                            @RequestParam(value = "deleteFileNo", required = false) Integer[] deleteFileNo,       // ✅ 기존 첨부 삭제 체크
	                            HttpServletRequest request) throws Exception {

	    // 1) manuDate 정규화
	    product.setManuDate(normalizeYYYYMMDD(product.getManuDate()));

	    // 2) 상품 기본정보 업데이트(대표이미지 개념 없음)
	    productService.updateProduct(product);

	    // 3) 기존 첨부 삭제
	    if (deleteFileNo != null && deleteFileNo.length > 0) {
	        String uploadDir = request.getServletContext().getRealPath("/upload");
	        java.io.File dir = new java.io.File(uploadDir);
	        if (!dir.exists()) dir.mkdirs();

	        for (Integer fileNo : deleteFileNo) {
	            if (fileNo == null) continue;

	            // 파일명 조회
	            com.model2.mvc.service.domain.ProductFile pf = productService.getProductFile(fileNo);
	            if (pf != null) {
	                // 물리파일 삭제(있으면)
	                if (pf.getFileName() != null && !pf.getFileName().isEmpty()) {
	                    java.io.File disk = new java.io.File(dir, pf.getFileName());
	                    if (disk.isFile()) try { disk.delete(); } catch (Exception ignore) {}
	                }
	                // DB 삭제
	                productService.deleteProductFile(fileNo);
	            }
	        }
	    }

	    // 4) 새 첨부 추가(멀티)
	    if (productFiles != null && productFiles.length > 0) {
	        addProductFiles(product.getProdNo(), request, productFiles); // ✅ 이전에 만든 varargs 헬퍼 사용
	    }

	    // 5) 상세보기로
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
            @RequestParam(value = "searchCondition", required = false) String searchCondition,
            @RequestParam(value = "searchKeyword", required = false) String searchKeyword,
            @RequestParam(value = "orderByPriceAsc", required = false) String orderByPriceAsc,
            @RequestParam(value = "minPrice", required = false) Integer minPrice,
            @RequestParam(value = "maxPrice", required = false) Integer maxPrice,
            HttpSession session,
            Model model) throws Exception {

        Search search = new Search();
        search.setCurrentPage(currentPage);
        search.setPageSize(pageSize);
        search.setSearchCondition(searchCondition);
        search.setSearchKeyword(searchKeyword);
        search.setOrderByPriceAsc(orderByPriceAsc);
        search.setMinPrice(minPrice);
        search.setMaxPrice(maxPrice);

        Map<String, Object> map = productService.getProductList(search);

        @SuppressWarnings("unchecked")
        List<Product> list = (List<Product>) map.get("list");

        Integer totalCount = (Integer) map.get("totalCount");
        if (totalCount == null) {
            Object alt = map.get("count");
            totalCount = (alt instanceof Integer) ? (Integer) alt : 0;
        }

        Map<Integer, String> tranStateMap = new HashMap<>();
        if (list != null) {
            for (Product p : list) {
                int proTranCode = 0;
                try {
                    String t = p.getProTranCode();
                    if (t != null) proTranCode = Integer.parseInt(t.trim());
                } catch (Exception ignore) {}
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
