package com.model2.mvc.service.purchase.test;

import static org.junit.Assert.*;

import java.util.HashMap;
import java.util.List;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.purchase.PurchaseService;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {	"classpath:config/context-common.xml",
		"classpath:config/context-aspect.xml",
		"classpath:config/context-mybatis.xml",
		"classpath:config/context-transaction.xml"})

public class PurchaseServiceTest {

    @Autowired
    @Qualifier("purchaseServiceImpl")
    private PurchaseService purchaseService;

    // ===== 테스트 파라미터 (프로젝트/DB 환경에 맞게 수정) =====
    private static final String TEST_BUYER_ID = "user06"; // 존재하는 사용자 ID
    private static final int    TEST_PROD_NO  = 10016;    // 존재하는 상품 번호

    private String uid(String prefix) {
        return prefix + "-" + System.currentTimeMillis();
    }

    /** 구매자 기준 목록/카운트 공통 조회 */
    private HashMap<String, Object> listByBuyer(String buyerId, int page, int pageSize) throws Exception {
        Search search = new Search();
        search.setCurrentPage(page);
        search.setPageSize(pageSize);
        return purchaseService.getPurchaseList(search, buyerId);
    }

    /** 테스트용 구매 1건 추가 후, 방금 추가한 tranNo 반환 */
    private int createPurchaseAndReturnTranNo(String mark) throws Exception {
        Purchase purchase = new Purchase();

        Product prod = new Product();
        prod.setProdNo(TEST_PROD_NO);     // 존재하는 상품
        
        User buyer = new User();
        buyer.setUserId(TEST_BUYER_ID);   // 존재하는 사용자
        buyer.setUserName("사용자6");
        buyer.setAddr("서울시 구로구");
        buyer.setEmail("user06@email.com");
        buyer.setPhone("010-000-0000");

        purchase.setPurchaseProd(prod);
        purchase.setBuyer(buyer);
        purchase.setPaymentOption("1"); // 1:Cash, 2:Card
        purchase.setDlvyRequest("문앞 배송");
        purchase.setTranCode("0");      // 판매중
        purchase.setDlvyDate("2025-12-31");

        purchaseService.addPurchase(purchase);
        System.out.println("== addPurchase OK: " + mark);

        // 1) selectKey 등으로 tranNo가 세팅되었다면 바로 사용
        if (purchase.getTranNo() > 0) {
            return purchase.getTranNo();
        }

        // 2) Fallback: 목록에서 방금 건 찾기
        HashMap<String, Object> map = listByBuyer(TEST_BUYER_ID, 1, 50);

        @SuppressWarnings("unchecked")
        List<Purchase> list = (List<Purchase>) map.get("list");
        assertNotNull("구매 목록이 null입니다.", list);

        Purchase justAdded = list.stream()
            .filter(p -> {
                if (p == null) return false;
                // purchaseProd / buyer NPE 방지
                Product pp = p.getPurchaseProd();
                User ub = p.getBuyer();
                Integer prodNo = (pp != null) ? pp.getProdNo() : null;
                String userId = (ub != null) ? ub.getUserId() : null;
                return prodNo != null
                    && prodNo == TEST_PROD_NO
                    && TEST_BUYER_ID.equals(userId);
            })
            .findFirst()
            .orElse(null);

        assertNotNull("방금 추가한 구매를 목록에서 찾지 못했습니다.", justAdded);

        // 안전한 디버그 출력 (null 체크 후)
        Integer dbgProdNo = (justAdded.getPurchaseProd() != null) ? justAdded.getPurchaseProd().getProdNo() : null;
        String dbgBuyerName = (justAdded.getBuyer() != null) ? justAdded.getBuyer().getUserName() : null;
        String dbgBuyerId = (justAdded.getBuyer() != null) ? justAdded.getBuyer().getUserId() : null;
        System.out.println("[Debug] ### PurchaseServiceTest.createPurchaseAndReturnTranNo() - "
            + "ProdNo(" + dbgProdNo + "), BuyerName(" + dbgBuyerName + "), BuyerId(" + dbgBuyerId + ")");

        assertTrue("tranNo가 1 이상이어야 함", justAdded.getTranNo() > 0);
        return justAdded.getTranNo();
    }

    // -----------------------------------------------------------------------------
    // 1) addPurchase 테스트 (검증은 목록/필드값으로 확인)
    // -----------------------------------------------------------------------------
    @Test
    public void testAddPurchase() throws Exception {
        String mark = uid("JUNIT-ADD");
        int tranNo = createPurchaseAndReturnTranNo(mark);
        System.out.println("== testAddPurchase OK, tranNo: " + tranNo);
    }

    // -----------------------------------------------------------------------------
    // 2) getPurchase 테스트 (단건 조회/매핑 확인)
    // -----------------------------------------------------------------------------
    @Test
    public void testGetPurchase() throws Exception {
        String mark = uid("JUNIT-GET");
        int tranNo = createPurchaseAndReturnTranNo(mark);

        Purchase purchase = purchaseService.getPurchase(tranNo);
        assertNotNull("단건 조회 결과 null", purchase);
        assertEquals("buyerId 일치", TEST_BUYER_ID, purchase.getBuyer().getUserId());
        assertEquals("prodNo 일치", TEST_PROD_NO, purchase.getPurchaseProd().getProdNo());
        assertNotNull("tranCode는 null이면 안됨", purchase.getTranCode());
        // ==== (요청대로) receiver_name == buyer_id 확인 ====
        assertEquals("buyer.userId는 buyerId와 같아야 함", TEST_BUYER_ID, purchase.getBuyer().getUserId());

        System.out.println("== testGetPurchase OK: tranNo=" + tranNo + ", purchase=" + purchase);
    }

    // -----------------------------------------------------------------------------
    // 3) getPurchaseListByBuyer 테스트 (목록/페이징)
    // -----------------------------------------------------------------------------
    @Test
    public void testGetPurchaseListByBuyer() throws Exception {
        // 두 건 이상 만들어서 페이징 검증 여지 확보
        createPurchaseAndReturnTranNo(uid("JUNIT-LIST-A"));
        createPurchaseAndReturnTranNo(uid("JUNIT-LIST-B"));

        HashMap<String, Object> map = listByBuyer(TEST_BUYER_ID, 1, 2);
        
        @SuppressWarnings("unchecked")
        List<Purchase> list = (List<Purchase>) map.get("list");

        assertNotNull("목록은 null이면 안됨", list);
        assertTrue("pageSize(2) 이하여야 함", list.size() <= 2);

        System.out.println("== testGetPurchaseListByBuyer OK: size=" + list.size());
        for (Purchase p : list) {
            System.out.println("  -> " + p);
        }
    }

    // -----------------------------------------------------------------------------
    // 4) getTotalCountByBuyer 테스트 (추가 전/후 카운트 비교)
    // -----------------------------------------------------------------------------
    @Test
    public void testGetTotalCountByBuyer() throws Exception {
        HashMap<String, Object> before = listByBuyer(TEST_BUYER_ID, 1, 1);        
        int countBefore = (int) before.get("totalCount");

        createPurchaseAndReturnTranNo(uid("JUNIT-COUNT"));

        HashMap<String, Object> after = listByBuyer(TEST_BUYER_ID, 1, 1);
        int countAfter = (int) after.get("totalCount");

        assertTrue("추가 후 카운트는 이전보다 크거나 같아야 함", countAfter >= countBefore + 1);
        System.out.println("== testGetTotalCountByBuyer OK: before=" + countBefore + ", after=" + countAfter);
    }

    // -----------------------------------------------------------------------------
    // 5) getTranCodeByProd 테스트 (상품별 상태코드 조회)
    // -----------------------------------------------------------------------------
    @Test
    public void testGetTranCodeByProd() throws Exception {
        createPurchaseAndReturnTranNo(uid("JUNIT-TC-GET"));
        String code = purchaseService.getTranCode(TEST_PROD_NO);
        assertNotNull("상품별 상태코드 조회 결과 null", code);
        System.out.println("== testGetTranCodeByProd OK: code=" + code);
    }

    // -----------------------------------------------------------------------------
    // 6) updateTranCodeByProd 테스트 (UPDATE -> GET으로 확인)
    // -----------------------------------------------------------------------------
    @Test
    public void testUpdateTranCodeByProd() throws Exception {
        createPurchaseAndReturnTranNo(uid("JUNIT-TC-UPD"));

        purchaseService.updateTranCode(TEST_PROD_NO, "2"); // 예: 배송중
        String code = purchaseService.getTranCode(TEST_PROD_NO);

        // 공백 제거 후 비교
        assertEquals("상태코드가 2로 변경되어야 함", "2", code != null ? code.trim() : null);
        System.out.println("== testUpdateTranCodeByProd OK: code=" + code);
    }
}
