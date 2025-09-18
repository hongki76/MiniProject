package com.model2.mvc.service.product.test;

import static org.junit.Assert.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.product.ProductService;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration	(locations = {	"classpath:config/context-common.xml",
		"classpath:config/context-aspect.xml",
		"classpath:config/context-mybatis.xml",
		"classpath:config/context-transaction.xml" })

public class ProductServiceTest {

    @Autowired
    @Qualifier("productServiceImpl")
    private ProductService productService;

    // ====== Helpers ======
    private String uniqueName(String prefix) {
        return prefix + "-" + System.currentTimeMillis();
    }

     // getProductList를 이용해 prod_name으로 1건을 찾아 반환
    @SuppressWarnings("unchecked")
    private Product findByName(String name) throws Exception {
        Search search = new Search();
        search.setCurrentPage(1);
        search.setPageSize(10);
        search.setSearchCondition("0"); // 0 : prod_name
        search.setSearchKeyword(name);

        Map<String, Object> map = productService.getProductList(search);
        List<Product> list = (List<Product>) map.get("list");
        if (list == null) return null;

        Optional<Product> opt = list.stream()
                .filter(p -> name.equals(p.getProdName()))
                .findFirst();
        
        return opt.orElse(null);
    }

    private Product newSampleProduct(String name) {
        Product p = new Product();
        p.setProdName(name);
        p.setPrice(12345);
        p.setManuDate("2025-09-12");
        p.setFileName("sample.png");
        p.setProdDetail("JUnit auto-generated");
        return p;
    }

     // 제품 추가 후 이름으로 재조회하여 INSERT 성공 확인
    @Test
    public void testAddProduct() throws Exception {
        String name = uniqueName("ADD");
        Product toAdd = newSampleProduct(name);

        // when
        productService.addProduct(toAdd);

        // then
        Product saved = findByName(name);
        assertNotNull("추가 후 동일 이름의 제품이 조회되어야 함", saved);
        assertEquals(name, saved.getProdName());
        assertEquals(Integer.valueOf(12345), Integer.valueOf(saved.getPrice()));
        assertEquals("2025-09-12", saved.getManuDate());
        assertEquals("sample.png", saved.getFileName());
        assertEquals("JUnit auto-generated", saved.getProdDetail());
        // mapper의 서브쿼리 컬럼(pro_tran_code)도 매핑만 확인 (NULL 또는 값)
        // null이어도 매핑 문제는 아님
    }

     //우선 1건을 추가 → 이름으로 prodNo 확보 → getProduct(prodNo)로 상세 검증
    @Test
    public void testGetProduct() throws Exception {
        String name = uniqueName("GET");
        productService.addProduct(newSampleProduct(name));

        Product saved = findByName(name);
        assertNotNull("사전 준비용 INSERT가 실패함", saved);
        int prodNo = saved.getProdNo();

        Product one = productService.getProduct(prodNo);
        assertNotNull("getProduct는 null이 아니어야 함", one);
        assertEquals(prodNo, one.getProdNo());
        assertEquals(name, one.getProdName());
        assertEquals(Integer.valueOf(12345), Integer.valueOf(one.getPrice()));
        // manufacture_day, image_file, prod_detail, reg_date 매핑 확인
        assertEquals("2025-09-12", one.getManuDate());
        assertEquals("sample.png", one.getFileName());
        assertEquals("JUnit auto-generated", one.getProdDetail());
    }

     // 이름 키워드로 2건 이상 삽입 후 검색조건/키워드/페이징 동작 확인
     // mapper의 where-clause(LOWER LIKE) 및 ROWNUM 페이징을 검증
    @SuppressWarnings("unchecked")
    @Test
    public void testGetProductList() throws Exception {
        String base = uniqueName("LIST");
        // 두 건 삽입
        productService.addProduct(newSampleProduct(base + "-A"));
        productService.addProduct(newSampleProduct(base + "-B"));

        Search search = new Search();
        search.setCurrentPage(1);
        search.setPageSize(5);
        search.setSearchCondition("0");     // prod_name
        search.setSearchKeyword(base);      // 공통 접두사

        Map<String, Object> map = productService.getProductList(search);
        assertNotNull(map);

        List<Product> list = (List<Product>) map.get("list");
        assertNotNull("list가 반환되어야 함", list);
        assertTrue("검색어를 포함한 결과가 최소 2건 이상이어야 함", list.size() >= 2);

        // keyword 포함 여부 확인 (대소문자 무시 LIKE)
        boolean allMatch = list.stream()
                .allMatch(p -> p.getProdName() != null && p.getProdName().toLowerCase().contains(base.toLowerCase()));
        assertTrue("모든 결과의 이름에 키워드가 포함되어야 함", allMatch);

        Object totalObj = map.get("totalCount");
        assertNotNull("totalCount가 반환되어야 함", totalObj);
        int total = (totalObj instanceof Integer) ? (Integer) totalObj
                  : Integer.parseInt(String.valueOf(totalObj));
        assertTrue("totalCount는 list.size() 이상이어야 함", total >= list.size());
    }

     // 1건 삽입 → 이름으로 prodNo 확보 → 일부 필드 변경 → updateProduct → 재조회하여 변경 확인
    @Test
    public void testUpdateProduct() throws Exception {
        String name = uniqueName("UPD");
        productService.addProduct(newSampleProduct(name));

        Product saved = findByName(name);
        assertNotNull("사전 준비용 INSERT가 실패함", saved);

        // 변경
        saved.setProdName(name + "-MOD");
        saved.setPrice(77777);
        saved.setManuDate("2025-09-13");
        saved.setFileName("updated.png");
        saved.setProdDetail("Updated by JUnit");

        // when
        productService.updateProduct(saved);

        // then
        Product updated = productService.getProduct(saved.getProdNo());
        assertNotNull(updated);
        assertEquals(saved.getProdNo(), updated.getProdNo());
        assertEquals(name + "-MOD", updated.getProdName());
        assertEquals(Integer.valueOf(77777), Integer.valueOf(updated.getPrice()));
        assertEquals("2025-09-13", updated.getManuDate());
        assertEquals("updated.png", updated.getFileName());
        assertEquals("Updated by JUnit", updated.getProdDetail());
    }
}
