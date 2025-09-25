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

  <!-- 검색/페이징 전용 form -->
  <form name="detailForm" id="detailForm" action="${cPath}/product/getProductList" method="post">
    <input type="hidden" id="currentPage" name="currentPage"
           value="${empty resultPage.currentPage ? 1 : resultPage.currentPage}"/>
    <input type="hidden" id="orderByPriceAsc" name="orderByPriceAsc" value="${search.orderByPriceAsc}"/>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
      <tr>
        <td align="right">
          가격
          <!-- 정렬: javascript: 제거, 버튼에 data-order만 부여 -->
          <button type="button" class="a-like sort-price" data-order="DESC" aria-label="가격 내림차순">↑</button>
          <button type="button" class="a-like sort-price" data-order="ASC"  aria-label="가격 오름차순">↓</button>
          &nbsp;
          <select name="searchCondition" class="ct_input_g" style="width:80px">
            <option value="0" ${!empty search.searchCondition && search.searchCondition==0 ? "selected" : ""}>상품명</option>
            <option value="1" ${!empty search.searchCondition && search.searchCondition==1 ? "selected" : ""}>상품가격</option>
          </select>
          <input type="text" name="searchKeyword" value="${! empty search.searchKeyword ? search.searchKeyword : ""}"
                 class="ct_input_g" style="width:200px; height:19px" />
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
      <td colspan="9">전체 ${resultPage.totalCount} 건수, 현재 ${resultPage.currentPage} 페이지</td>
    </tr>
    <tr>
      <td class="ct_list_b" width="100">No</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="150">상품명</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="150">가격</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b">등록일</td>
      <td class="ct_line02"></td>
      <td class="ct_list_b" width="120">현재상태</td>
    </tr>
    <tr><td colspan="9" bgcolor="808285" height="1"></td></tr>

    <c:forEach var="product" items="${list}" varStatus="loop">
      <tr class="ct_list_pop">
        <td align="center">
          ${resultPage.totalCount - ((resultPage.currentPage-1) * resultPage.pageSize) - loop.index}
        </td>
        <td></td>

        <td align="left">
          <form action="/product/getProduct" method="post" style="display:inline;">
            <input type="hidden" name="prodNo" value="${product.prodNo}" />
            <button type="submit" class="a-like">${product.prodName}</button>
          </form>
        </td>

        <td></td>
        <td align="left">${product.price}</td>
        <td></td>
        <td align="left">${product.manuDate}</td>
        <td></td>

        <td align="center">
          <c:choose>
            <c:when test="${not empty user and user.role eq 'admin' and product.proTranCode eq '1'}">
              ${product.proTranState}
              <a href="/purchase/updateTranCodeByProduct?prodNo=${product.prodNo}&amp;tranStatusCode=2" class="a-like">배송하기</a>
            </c:when>
            <c:otherwise>
              ${product.proTranState}
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr><td colspan="9" bgcolor="D6D7D6" height="1"></td></tr>
    </c:forEach>
  </table>

  <!-- 페이지 네비게이터 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="center">
        <jsp:include page="../common/pageNavigator.jsp"/>
      </td>
    </tr>
  </table>

</div>

<!-- 스크립트: 하단에 외부 파일로만 로드 -->
<script src="/javascript/jquery-3.7.1.min.js"></script>
<!-- (선택) 공통 검증 사용 시 -->
<script src="/javascript/CommonScript-jq.js"></script>
<script src="/javascript/product-list.js"></script>
</body>
</html>
