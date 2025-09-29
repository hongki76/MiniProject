package com.model2.mvc.web.purchase;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;

/**
 * PurchaseRestController
 * 구매 관리를 위한 RESTful API 컨트롤러
 * URL Prefix : /purchase/json/
 */
@RestController
@RequestMapping("/purchase/*")
public class PurchaseRestController {

    // ===== Config (페이징 계산에 사용, 필요 없으면 응답에서 resultPage 제거 가능) =====
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

    public PurchaseRestController() {
        System.out.println("==> PurchaseRestController 실행됨 : " + this.getClass());
    }

    // =========================================================
    // 1) 구매 등록 : JSON
    //    Content-Type: application/json
    //    Body : Purchase (purchaseProd.prodNo 포함 권장)
    // =========================================================
    @PostMapping(value = "json/addPurchase", consumes = MediaType.APPLICATION_JSON_VALUE)
    public boolean addPurchase(@RequestBody Purchase purchase, HttpSession session) throws Exception {
        System.out.println("/purchase/json/addPurchase : POST(JSON) 호출됨");
        // 기본 거래상태(구매완료) 세팅 없으면 기본값 주입
        if (purchase.getTranCode() == null || purchase.getTranCode().trim().isEmpty()) {
            purchase.setTranCode("1");
        }
        // 세션 사용자 주입(구매자)
        User buyer = (User) session.getAttribute("user");
        if (buyer != null) {
            purchase.setBuyer(buyer);
        }
        // (선택) prodNo만 넘어오는 경우 보정
        if (purchase.getPurchaseProd() != null && purchase.getPurchaseProd().getProdNo() > 0) {
            // 필요 시 상품 존재 여부 체크
            Product prod = new Product();
            prod.setProdNo(purchase.getPurchaseProd().getProdNo());
            purchase.setPurchaseProd(prod);
        }

        purchaseService.addPurchase(purchase);
        return true;
    }

    // =========================================================
    // 2) 구매 단건 조회
    // =========================================================
    @GetMapping("json/getPurchase/{tranNo}")
    public Purchase getPurchase(@PathVariable int tranNo, HttpSession session) throws Exception {
        System.out.println("/purchase/json/getPurchase : GET 호출됨, tranNo=" + tranNo);
        return purchaseService.getPurchase(tranNo);
    }

    // =========================================================
    // 3) 구매 목록(구매자 기준)
    //    Content-Type: application/json
    //    Body: Search { currentPage, pageSize, ... }
    //    Query: buyerId(optional)  -> 없으면 세션에서 user.userId 사용
    //    반환: { list, totalCount, tranStateMap, resultPage, search }
    // =========================================================
    @PostMapping(value = "json/getPurchaseList", consumes = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> getPurchaseList(
            @RequestBody Search search,
            @RequestParam(value = "buyerId", required = false) String buyerId,
            HttpSession session) throws Exception {

        // 페이징 기본값 보정
        if (search.getCurrentPage() <= 0) search.setCurrentPage(1);
        if (search.getPageSize() <= 0) search.setPageSize(pageSize);

        // 세션에서 buyerId 보완
        if (buyerId == null || buyerId.trim().isEmpty()) {
            User buyer = (User) session.getAttribute("user");
            if (buyer != null) {
                buyerId = buyer.getUserId();
            }
        }

        System.out.println("### PurchaseRestController.getPurchaseList() - search.startRowNum(" + search.getStartRowNum() + ")");
        System.out.println("### PurchaseRestController.getPurchaseList() - search.endRowNum(" + search.getEndRowNum() + ")");
        System.out.println("### PurchaseRestController.getPurchaseList() - buyerId(" + buyerId + ")");

        Map<String, Object> svc = purchaseService.getPurchaseList(search, buyerId);

        @SuppressWarnings("unchecked")
        List<Purchase> list = (List<Purchase>) svc.get("list");
        Integer totalCount = (Integer) svc.get("totalCount");
        if (totalCount == null) {
            Object alt = svc.get("count");
            totalCount = (alt instanceof Integer) ? (Integer) alt : 0;
        }

        // 상태 문자열 맵 생성 (tranNo -> tranState)
        Map<Integer, String> tranStateMap = new HashMap<>();
        if (list != null) {
            for (Purchase p : list) {
                int code = toIntSafe(p != null ? p.getTranCode() : null);
                tranStateMap.put(p.getTranNo(), resolveTranState(code));
            }
        }

        Page resultPage = new Page(search.getCurrentPage(), totalCount, pageUnit, search.getPageSize());
        int baseRowNo = totalCount - ((search.getCurrentPage() - 1) * search.getPageSize());
        resultPage.setBaseRowNo(baseRowNo);

        Map<String, Object> res = new HashMap<>();
        res.put("list", list);
        res.put("totalCount", totalCount);
        res.put("tranStateMap", tranStateMap);
        res.put("resultPage", resultPage);
        res.put("search", search);
        return res;
    }

    // =========================================================
    // 4) 거래상태코드 변경(구매목록에서 사용)
    //    Content-Type: application/json
    //    Body: { "tranNo": 12345, "tranStatusCode": "2" }
    // =========================================================
    @PostMapping(value = "json/updateTranCode", consumes = MediaType.APPLICATION_JSON_VALUE)
    public boolean updateTranCode(@RequestBody UpdateTranCodeReq req) throws Exception {
        System.out.println("### updateTranCode - tranNo=" + req.getTranNo() + ", tranStatusCode=" + req.getTranStatusCode());
        purchaseService.updateTranCode(req.getTranNo(), req.getTranStatusCode());
        return true;
    }

    // =========================================================
    // 5) 거래상태코드 변경(상품목록에서 사용 - prodNo 기준)
    //    Content-Type: application/json
    //    Body: { "prodNo": 10001, "tranStatusCode": "3" }
    //    반환: { updatedRows: n }
    // =========================================================
    @PostMapping(value = "json/updateTranCodeByProduct", consumes = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> updateTranCodeByProduct(@RequestBody UpdateTranCodeByProdReq req) throws Exception {
        System.out.println("##### [Debug] PurchaseRestController.updateTranCodeByProduct() - prodNo(" + req.getProdNo() + "), tranStatusCode(" + req.getTranStatusCode() + ")");
        int rows = purchaseService.updateTranCodeByProduct(req.getProdNo(), req.getTranStatusCode());
        Map<String, Object> res = new HashMap<>();
        res.put("updatedRows", rows);
        return res;
    }
    
    @PostMapping("json/cancelPurchase")
    public Map<String, Object> cancelPurchase(@RequestParam int tranNo) {
        Map<String, Object> res = new HashMap<>();
        try {
        	System.out.println("PurchaseRestController.cancelPurchase() - tranNo(" + ")");
            purchaseService.cancelPurchase(tranNo);
            res.put("success", true);
            res.put("message", "주문이 취소되었습니다.");
        } catch (IllegalStateException | IllegalArgumentException e) {
            res.put("success", false);
            res.put("message", e.getMessage());
        } catch (Exception e) {
            res.put("success", false);
            res.put("message", "오류가 발생했습니다.");
        }
        return res;
    }

    // ===== Helpers =====
    private String resolveTranState(int tranCode) {
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

    // ===== Request DTOs =====
    public static class UpdateTranCodeReq {
        private int tranNo;
        private String tranStatusCode;
        public int getTranNo() { return tranNo; }
        public void setTranNo(int tranNo) { this.tranNo = tranNo; }
        public String getTranStatusCode() { return tranStatusCode; }
        public void setTranStatusCode(String tranStatusCode) { this.tranStatusCode = tranStatusCode; }
    }

    public static class UpdateTranCodeByProdReq {
        private int prodNo;
        private String tranStatusCode;
        public int getProdNo() { return prodNo; }
        public void setProdNo(int prodNo) { this.prodNo = prodNo; }
        public String getTranStatusCode() { return tranStatusCode; }
        public void setTranStatusCode(String tranStatusCode) { this.tranStatusCode = tranStatusCode; }
    }
}
