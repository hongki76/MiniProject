package com.model2.mvc.web.purchase;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;

@Controller
public class PurchaseController {

    // ===== Config =====
    @Value("#{commonProperties['pageUnit'] ?: 5}")
    int pageUnit;

    @Value("#{commonProperties['pageSize'] ?: 3}")
    int pageSize;

    // ===== Service =====
    @Autowired
    @Qualifier("purchaseServiceImpl")
    private PurchaseService purchaseService;
    
    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    // ------------------------------------------------------
    // 1-1) 구매 등록 View
    // ------------------------------------------------------
    @RequestMapping(value = "/addPurchaseView.do", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView addPurchaseView(@RequestParam("prodNo") int prodNo) throws Exception {
        Product product = productService.getProduct(prodNo);

        ModelAndView mav = new ModelAndView();
        mav.setViewName("/purchase/addPurchaseView.jsp");
        mav.addObject("product", product);
        return mav;
    }

    
    // ------------------------------------------------------
    // 1-2) 구매 등록
    // ------------------------------------------------------
    @RequestMapping(value = "/addPurchase.do", method = RequestMethod.POST)
    public ModelAndView addPurchase(
            @ModelAttribute("purchase") Purchase purchase,
            @RequestParam("prodNo") int prodNo,
            HttpSession session) throws Exception {

    	// tranCode 입력: 구매완료
    	purchase.setTranCode("1");
    	
        // prodNo를 도메인에 주입
        Product prod = new Product();
        prod.setProdNo(prodNo);
        purchase.setPurchaseProd(prod);
        
        // 세션 사용자 주입(구매자)
        User buyer = (User)session.getAttribute("user");
        if (buyer != null) {
            purchase.setBuyer(buyer);
        }

        purchaseService.addPurchase(purchase);

        ModelAndView mav = new ModelAndView();
        mav.addObject("purchase", purchase);
        mav.setViewName("/purchase/addPurchase.jsp");
        return mav;
    }

    // ------------------------------------------------------
    // 2) 구매 상세
    // ------------------------------------------------------
    @RequestMapping(value = "/getPurchase.do", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView getPurchase(
            @RequestParam("tranNo") int tranNo,
            HttpSession session) throws Exception {

        ModelAndView mav = new ModelAndView();

        Purchase purchase = purchaseService.getPurchase(tranNo);
        mav.addObject("purchase", purchase);

        int code = toIntSafe(purchase != null ? purchase.getTranCode() : null);
        mav.addObject("tranState", resolveTranState(session, code));

        mav.setViewName("/purchase/getPurchase.jsp");
        return mav;
    }

    // ------------------------------------------------------
    // 3) (구매자 기준) 구매 목록
    // ------------------------------------------------------
    @RequestMapping(value = "/getPurchaseList.do", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView getPurchaseList(
            @RequestParam(value = "currentPage", required = false, defaultValue = "1") int currentPage,
            HttpSession session) throws Exception {

        ModelAndView mav = new ModelAndView();

        User buyer = (User)session.getAttribute("user");
        String buyerId = (buyer != null) ? buyer.getUserId() : null;

        // Search 세팅
        Search search = new Search();
        search.setCurrentPage(currentPage);
        search.setPageSize(pageSize);

        // 서비스에서 Map(list,totalCount) 반환
        Map<String, Object> map = purchaseService.getPurchaseList(search, buyerId);

        @SuppressWarnings("unchecked")
        List<Purchase> list = (List<Purchase>) map.get("list");

        Integer totalCount = (Integer) map.get("totalCount");
        if (totalCount == null) { // 키 명이 다를 경우 대비
            Object alt = map.get("count");
            totalCount = (alt instanceof Integer) ? (Integer) alt : 0;
        }

        // 상태 문자열 맵 생성 (tranNo -> tranState)
        Map<Integer, String> tranStateMap = new HashMap<>();
        if (list != null) {
            for (Purchase p : list) {
                int code = toIntSafe(p != null ? p.getTranCode() : null);
                tranStateMap.put(p.getTranNo(), resolveTranState(session, code));
            }
        }

        Page resultPage = new Page(currentPage, totalCount, pageUnit, pageSize);
        int baseRowNo = totalCount - ((currentPage - 1) * pageSize);
        resultPage.setBaseRowNo(baseRowNo);
        
        mav.addObject("list", list);
        mav.addObject("tranStateMap", tranStateMap);
        mav.addObject("resultPage", resultPage);
        mav.addObject("search", search);

        mav.setViewName("/purchase/listPurchase.jsp");
        return mav;
    }
    
    // ------------------------------------------------------
    // 4-1) 상품별 상태코드 변경 - 구매목록
    // ------------------------------------------------------
    @RequestMapping(value = "/updateTranCode.do", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView updateTranCode(
            @RequestParam("tranNo") int tranNo,
            @RequestParam("tranStatusCode") String tranStatusCode,
            HttpSession session) throws Exception {

    	System.out.println("### PurchaseController.updateTranCode() - tranNo(" + tranNo + "), tranStatusCode(" + tranStatusCode + ")");
        purchaseService.updateTranCode(tranNo, tranStatusCode);

        ModelAndView mav = new ModelAndView();
        mav.setViewName("redirect:/getPurchaseList.do");
        return mav;
    }

    // ------------------------------------------------------
    // 4-2) 상품별 상태코드 변경 - 상품목록
    // ------------------------------------------------------
    @RequestMapping(value = "/updateTranCodeByProduct.do", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView updateTranCodeByProduct(
            @RequestParam("prodNo") int prodNo,
            @RequestParam("tranStatusCode") String tranStatusCode,
            HttpSession session) throws Exception {

    	System.out.println("### PurchaseController.updateTranCodeByProduct() - prodNo(" + prodNo + "), tranStatusCode(" + tranStatusCode + ")");
        purchaseService.updateTranCodeByProduct(prodNo, tranStatusCode);

        ModelAndView mav = new ModelAndView();
        mav.setViewName("redirect:/getProductList.do");
        return mav;
    }

    // ------------------------------------------------------
    // 5) 상품별 현재 상태코드 조회 
    // ------------------------------------------------------
    @RequestMapping(value = "/getTranCodeByProd.do", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView getTranCode(
            @RequestParam("prodNo") int prodNo,
            HttpSession session) throws Exception {

        String codeStr = purchaseService.getTranCode(prodNo);
        int code = toIntSafe(codeStr);

        Map<String, Object> res = new HashMap<>();
        res.put("prodNo", prodNo);
        res.put("tranStatusCode", codeStr != null ? codeStr : "0");
        res.put("tranState", resolveTranState(session, code));

        ModelAndView mav = new ModelAndView();

        // (A) jsonView 사용 시
        // mav.setViewName("jsonView");
        // mav.addAllObjects(res);

        // (B) JSP 로 JSON 렌더링 시
        mav.setViewName("/common/jsonView.jsp");
        mav.addObject("json", res);

        return mav;
    }

    /**
     * 거래상태 헬퍼
     * @param session     현재 세션(없어도 동작)
     * @param proTranCode 0:판매중, 1:구매완료, 2:배송중, 3:배송완료
     */
    private String resolveTranState(HttpSession session, int tranCode) {
            switch (tranCode) {
                case 2:  return "배송중";
                case 3:  return "배송완료";
                default: return "구매완료";
            }
    }

    private int toIntSafe(String code) {
        try {
            return (code == null) ? 0 : Integer.parseInt(code.trim());
        } catch (Exception ignore) { return 0; }
    }
}
