package com.model2.mvc.web.product;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;

/**
 * ProductController (String return type)
 * - 기존 로직/구조는 유지하고, 반환형만 String 으로 변경
 */
@Controller
public class ProductController {

    // ====== Field ======
    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    @Resource
    private ServletContext servletContext; // pageUnit/pageSize init-param 사용

    // ====== Helpers ======
	//==> classpath:config/common.properties  ,  classpath:config/commonservice.xml 참조 할것
	@Value("#{commonProperties['pageUnit'] ?: 3}")
	int pageUnit;
	
	@Value("#{commonProperties['pageSize'] ?: 2}")
	int pageSize;

    // ====== Create ======
	@RequestMapping(value = "/addProductView.do", method = { RequestMethod.GET, RequestMethod.POST })
	public String addProductView() {
	    return "/product/addProductView.jsp";
	}

    @RequestMapping(value = "/addProduct.do", method = RequestMethod.POST)
    public String addProduct(@ModelAttribute("product") Product product) throws Exception {
        productService.addProduct(product);
        return "redirect:/getProductList.do";
    }

    // ====== Read ======
    @RequestMapping(value = "/getProduct.do", method = RequestMethod.POST)
    public String getProduct(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
        Product product = productService.getProduct(prodNo);
        model.addAttribute("product", product);
        return "/product/getProduct.jsp";
    }

    // ====== Update ======
    @RequestMapping(value = "/updateProductView.do", method = { RequestMethod.GET, RequestMethod.POST })
    public String updateProductView(@RequestParam("prodNo") int prodNo, Model model) throws Exception {
        Product product = productService.getProduct(prodNo);
        model.addAttribute("product", product);
        return "/product/updateProduct.jsp";
    }

    @RequestMapping(value = "/updateProduct.do", method = RequestMethod.POST)
    public String updateProduct(@ModelAttribute("product") Product product) throws Exception {
        productService.updateProduct(product);
        return "forward:/getProduct.do";
    }

    // ====== List ======
    @RequestMapping(value = "/getProductList.do", method = { RequestMethod.GET, RequestMethod.POST })
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
                System.out.println("##### [Debug] ProductController.getProductList() - prodNo:" + p.getProdNo() 
                	+ ", proTranCode: " + p.getProTranCode() + ", proTranState: " + p.getProTranState());
            }
        }

        Page resultPage = new Page(currentPage, totalCount, pageUnit, pageSize);

        model.addAttribute("list", list);
        model.addAttribute("tranStateMap", tranStateMap); // ★ 추가
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
