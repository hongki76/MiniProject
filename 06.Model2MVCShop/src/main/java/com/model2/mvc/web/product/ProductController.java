package com.model2.mvc.web.product;

import java.io.File;
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

    // ====== Update ======
    @RequestMapping(value = "updateProductView", method = { RequestMethod.GET, RequestMethod.POST })
    public String updateProductView(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
        Product product = productService.getProduct(prodNo);
        model.addAttribute("product", product);
        return "/product/updateProduct.jsp";
    }

 // 클래스 레벨이 @RequestMapping("/product") 라고 가정
    @PostMapping(value = "updateProduct", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public String updateProduct(@ModelAttribute("product") Product product,
                                @RequestParam(value = "uploadFile", required = false) org.springframework.web.multipart.MultipartFile file,
                                @RequestParam(value = "oldFileName", required = false) String oldFileName,
                                javax.servlet.http.HttpServletRequest request) throws Exception {

        // 1) manuDate 정규화(매퍼가 'YYYYMMDD'면 숫자만 남기기)
        if (product.getManuDate() != null) {
            product.setManuDate(product.getManuDate().replaceAll("\\D", ""));
        }

        // 2) 업로드 디렉터리 준비
        String uploadDir = request.getServletContext().getRealPath("/upload");
        java.io.File dir = new java.io.File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        // 3) 새 파일이 있으면 저장 + fileName 교체
        if (file != null && !file.isEmpty()) {
            String original = file.getOriginalFilename();
            String ext = (original != null && original.lastIndexOf(".") != -1)
                       ? original.substring(original.lastIndexOf(".")) : "";
            String saved = java.util.UUID.randomUUID().toString().replace("-", "") + ext;

            file.transferTo(new java.io.File(dir, saved));
            // DB 저장용 파일명 세팅
            product.setFileName(saved);

            // (선택) 기존 파일 삭제
            if (oldFileName != null && !oldFileName.isEmpty() && !oldFileName.equals(saved)) {
                java.io.File old = new java.io.File(dir, oldFileName);
                if (old.isFile()) try { old.delete(); } catch (Exception ignore) {}
            }
        } else {
            // 4) 새 파일이 없으면 기존 파일 유지
            if (product.getFileName() == null || product.getFileName().isEmpty()) {
                if (oldFileName != null && !oldFileName.isEmpty()) {
                    product.setFileName(oldFileName);
                } else {
                    // (폴백) DB에서 조회해 유지
                    com.model2.mvc.service.domain.Product db = productService.getProduct(product.getProdNo());
                    if (db != null) product.setFileName(db.getFileName());
                }
            }
        }

        // 5) 업데이트
        productService.updateProduct(product);

        // 6) 상세 화면으로 이동(파라미터 필요)
        //return "redirect:/product/getProduct?prodNo=" + product.getProdNo();
        return "forward:/product/getProduct";
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
