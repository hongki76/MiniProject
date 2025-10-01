<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="user"  value="${sessionScope.user}" />

<html>
<head>
  <title>상품 목록조회</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <style>
    .a-like{
      cursor:pointer; text-decoration:underline; color:#0066cc;
      background:none; border:none; padding:0; font:inherit;
    }

    /* 무한스크롤 가독성 */
    .ct_list_pop td { padding: 50px 2px; }
    .ct_list_b { height: 28px; }

    /* 현재상태 배지 */
    .badge{ display:inline-block; min-width:64px; padding:2px 8px; border-radius:10px; font-size:12px; line-height:18px; }
    .badge.on{  color:#0a7; background:#eafff5; border:1px solid #b9f0dc; }   /* 판매중 */
    .badge.off{ color:#a33; background:#fff1f1; border:1px solid #f3c9c9; }   /* 재고없음 */

    /* 상품 hover 레이어 */
    .prod-hover-layer{
      position: absolute;
      z-index: 3000;
      min-width: 280px;
      max-width: 420px;
      background: #fff;
      border: 1px solid #d9d9d9;
      box-shadow: 0 8px 24px rgba(0,0,0,.12);
      border-radius: 8px;
      padding: 12px 14px;
      display: none;
      pointer-events: auto;
    }
    .prod-hover-layer .ttl{ font-weight: 600; margin-bottom: 6px; }
    .prod-hover-layer .row{ font-size: 13px; line-height: 1.4; margin: 2px 0; }
    .prod-hover-layer .price{ font-weight: 600; }
    .prod-hover-layer .act{ margin-top: 8px; text-align: right; }
    .prod-hover-layer .btn-like{
      cursor:pointer; text-decoration:underline; color:#0066cc;
      background:none; border:none; padding:0; font:inherit;
    }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">
<div style="width:98%; margin-left:10px;">

  <!-- 제목 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37"/></td>
      <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr><td width="93%" class="ct_ttl01">상품 관리</td></tr>
        </table>
      </td>
      <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37"/></td>
    </tr>
  </table>

  <!-- 검색/페이징 전용 form (제출은 JS가 막고 AJAX로 처리) -->
  <form name="detailForm" id="detailForm" action="${cPath}/product/getProductList" method="post">
    <input type="hidden" id="currentPage" name="currentPage"
           value="${empty resultPage.currentPage ? 1 : resultPage.currentPage}"/>
    <input type="hidden" id="orderByPriceAsc" name="orderByPriceAsc" value="${search.orderByPriceAsc}"/>
    <input type="hidden" name="regDateKeyword" id="regDateKeyword" value="${search.regDateKeyword}"/>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
      <tr>
        <td align="right">
          가격
          <button type="button" class="a-like sort-price" data-order="DESC" aria-label="가격 내림차순">↑</button>
          <button type="button" class="a-like sort-price" data-order="ASC"  aria-label="가격 오름차순">↓</button>
          &nbsp;
          <select name="searchCondition" class="ct_input_g" style="width:100px" id="searchCondition">
            <option value="0" ${!empty search.searchCondition && search.searchCondition==0 ? "selected" : ""}>상품명</option>
            <option value="1" ${!empty search.searchCondition && search.searchCondition==1 ? "selected" : ""}>상품설명</option>
            <option value="2" ${!empty search.searchCondition && search.searchCondition==2 ? "selected" : ""}>등록일</option>
          </select>

          <div class="ac-wrap" style="display:inline-block;">
            <input type="text" name="searchKeyword" id="searchKeyword"
                   value="${! empty search.searchKeyword ? search.searchKeyword : ""}"
                   class="ct_input_g" style="width:200px; height:19px" />
          </div>

          <input type="text" name="minPrice" value="${search.minPrice}" class="ct_input_g"
                 style="width:100px; height:19px; text-align:right;" placeholder="최소금액" num="n" />
          ~
          <input type="text" name="maxPrice" value="${search.maxPrice}" class="ct_input_g"
                 style="width:100px; height:19px; text-align:right;" placeholder="최대금액" num="n" />
        </td>
        <td align="right" width="70">
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"></td>
              <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                <button type="button" id="btnSearch" class="a-like">검색</button>
              </td>
              <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"></td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </form>

  <!-- 리스트 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td colspan="11">
        전체 <span id="totalCountSpan">${resultPage.totalCount}</span> 건수,
        현재 <span id="currentPageSpan">${resultPage.currentPage}</span> 페이지
      </td>
    </tr>
    <tr>
      <td class="ct_list_b" width="100">No</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="250">상품명</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="150">가격</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="120">등록일</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="150">현재상태</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="120">작업</td>
    </tr>
    <tr><td colspan="11" bgcolor="808285" height="1"></td></tr>

    <!-- 무한스크롤: 여기에 계속 append -->
    <tbody id="productTbody">
      <c:forEach var="product" items="${list}" varStatus="loop">
        <tr class="ct_list_pop">
          <td align="center">
            ${resultPage.totalCount - ((resultPage.currentPage-1) * resultPage.pageSize) - loop.index}
          </td>
          <td></td>

          <td align="left">
            <form action="${cPath}/product/getProduct" method="post" style="display:inline;">
              <input type="hidden" name="prodNo" value="${product.prodNo}" />
              <button type="submit" class="a-like prod-link" data-prodno="${product.prodNo}">
                ${product.prodName}
              </button>
            </form>
          </td>

          <td></td>
          <td align="right">${product.price}</td>
          <td></td>
          <td align="center">${product.regDate}</td>
          <td></td>

          <!-- 현재상태 -->
          <td align="center">
            <c:choose>
              <c:when test="${product.proTranCode eq '0' || product.proTranCode == 0}">
                <span class="badge on">판매중</span>
              </c:when>
              <c:otherwise>
                <span class="badge off">재고없음</span>
              </c:otherwise>
            </c:choose>
          </td>

          <td></td>

          <!-- ✅ 작업(배송하기) -->
          <td align="center">
            <c:if test="${not empty user and user.role eq 'admin' and (product.proTranCode eq '1' or product.proTranCode == 1)}">
              <a href="${cPath}/purchase/updateTranCodeByProduct?prodNo=${product.prodNo}&amp;tranStatusCode=2" class="a-like">배송하기</a>
            </c:if>
          </td>
        </tr>
        <tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>
      </c:forEach>
    </tbody>
  </table>

</div>

<!-- 전역 설정: 무한스크롤 스크립트에서 활용 -->
<script>
  window.__PRODUCT_LIST_CONFIG__ = {
    cPath: '${cPath}',
    isLogin: ${not empty user ? 'true' : 'false'},
    role: '${empty user ? "" : user.role}',
    pageSizeSSR: ${empty resultPage.pageSize ? 'null' : resultPage.pageSize},
    totalCountSSR: ${empty resultPage.totalCount ? 0 : resultPage.totalCount},
    currentPageSSR: ${empty resultPage.currentPage ? 1 : resultPage.currentPage}
  };
</script>

<!-- 스크립트 -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="/javascript/CommonScript-jq.js"></script>
<script src="/javascript/product-list.js"></script>
</body>
</html>
