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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;

@Controller
@RequestMapping("/purchase/*")
public class PurchaseController {

    // ===== Config =====
    @Value("#{commonProperties['pageUnit']}")
    int pageUnit;

    @Value("#{commonProperties['pageSize']}")
    int pageSize;

    // ===== Service =====
    @Autowired
    @Qualifier("purchaseServiceImpl")
    private PurchaseService purchaseService;
    
    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    // 구매 등록 View
    @RequestMapping(value = "addPurchase", method = RequestMethod.GET)
    public ModelAndView addPurchase(@RequestParam("prodNo") int prodNo) throws Exception {
        Product product = productService.getProduct(prodNo);

        ModelAndView mav = new ModelAndView();
        mav.setViewName("/purchase/addPurchaseView.jsp");
        mav.addObject("product", product);
        return mav;
    }

    
    // 구매 등록
    @RequestMapping(value = "addPurchase", method = RequestMethod.POST)
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

    // 구매 상세
    @RequestMapping(value = "getPurchase", method = { RequestMethod.GET, RequestMethod.POST })
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

    // 구매 목록(구매자 기준)
    @RequestMapping(value = "getPurchaseList", method = { RequestMethod.GET, RequestMethod.POST })
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
        
        System.out.println("### PurchaseController.getPurchaseList() - search.StartRownNum(" + search.getStartRowNum() + ")");

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
    
    // 상품별 상태코드 변경 - 구매목록
    @RequestMapping(value = "updateTranCode", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView updateTranCode(
            @RequestParam("tranNo") int tranNo,
            @RequestParam("tranStatusCode") String tranStatusCode,
            HttpSession session) throws Exception {

        purchaseService.updateTranCode(tranNo, tranStatusCode);

        ModelAndView mav = new ModelAndView();
        mav.setViewName("redirect:/purchase/getPurchaseList");
        return mav;
    }

    // 상품별 상태코드 변경 - 상품목록
    @RequestMapping(value = "updateTranCodeByProduct", method = { RequestMethod.GET, RequestMethod.POST })
    public ModelAndView updateTranCodeByProduct(
            @RequestParam("prodNo") int prodNo,
            @RequestParam("tranStatusCode") String tranStatusCode,
            HttpSession session) throws Exception {

    	System.out.println("##### [Debug] PurchaseController.updateTranCodeByProduct() - prodNo(" + prodNo + "), tranStatusCode(" + tranStatusCode + ")");
    	
        int rows = purchaseService.updateTranCodeByProduct(prodNo, tranStatusCode);
        System.out.println("### updateTranCodeByProduct rows = " + rows);

        ModelAndView mav = new ModelAndView();
        mav.setViewName("redirect:/product/getProductList");
        return mav;
    }
    
    @PostMapping("cancelPurchase")
    public String cancelPurchase(@RequestParam("tranNo") int tranNo,
                                 RedirectAttributes ra) {
		System.out.println("### PurchaseController.cancelPurchase() - tranNo(" + tranNo + ")");
    	
    	try {
            purchaseService.cancelPurchase(tranNo);
            System.out.println("### PurchaseController.cancelPurchase() - 주문취소");
            ra.addFlashAttribute("message", "주문이 취소되었습니다.");
        } catch (IllegalArgumentException e) {
        	System.out.println("### PurchaseController.cancelPurchase() - 존재하지 않는 주문");
            ra.addFlashAttribute("error", "존재하지 않는 주문입니다.");
        } catch (IllegalStateException e) {
        	System.out.println("### PurchaseController.cancelPurchase() - 상태오류(" + e.getMessage() + ")");
            ra.addFlashAttribute("error", e.getMessage());
        } catch (Exception e) {
        	System.out.println("%%% PurchaseController.cancelPurchase() - 주문 취소 오류(" + e.getMessage() + ")");
            ra.addFlashAttribute("error", "주문 취소 처리 중 오류가 발생했습니다.");
        }

        System.out.println("### PurchaseController.cancelPurchase() - tranNo(" + tranNo + ")");
        
        // 취소 후 목록으로
        return "redirect:/purchase/getPurchaseList";
    }

    // 헬퍼
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
