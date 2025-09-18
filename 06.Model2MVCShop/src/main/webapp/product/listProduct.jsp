<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="user" value="${sessionScope.user}" />

<html>
<head>
<title>상품 목록조회</title>

<link rel="stylesheet" href="/css/admin.css" type="text/css">

<script type="text/javascript">
function fncGetList(currentPage, orderByPriceAsc){
  var f = document.forms['detailForm'];
  if(!f) return;

  // 페이지 설정
  document.getElementById("currentPage").value = currentPage;

  // 두 번째 인자가 명시적으로 넘어왔을 때만 히든을 업데이트
  if (typeof orderByPriceAsc !== 'undefined' && orderByPriceAsc !== null && orderByPriceAsc !== '') {
    var el = document.getElementById("orderByPriceAsc");
    if (el) {
      el.value = orderByPriceAsc;
    }
  }
  // 제출
  f.submit();
}
</script>

<style>
/* 링크처럼 보이는 버튼 */
.a-like{
  cursor:pointer; text-decoration:underline; color:#0066cc;
  background:none; border:none; padding:0; font:inherit;
}
</style>
</head>

<body bgcolor="#ffffff" text="#000000">

<div style="width:98%; margin-left:10px;">

<!-- =================== 제목 영역 =================== -->
<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37">
      <img src="/images/ct_ttl_img01.gif" width="15" height="37"/>
    </td>
    <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">상품 관리</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37">
      <img src="/images/ct_ttl_img03.gif" width="12" height="37"/>
    </td>
  </tr>
</table>

<!-- =========== 검색/페이징 전용 form (중첩 방지) =========== -->
<form name="detailForm" action="${cPath}/getProductList.do" method="post">
  <input type="hidden" id="currentPage" name="currentPage" value="${empty resultPage.currentPage ? 1 : resultPage.currentPage}"/>
  <input type="hidden" id="orderByPriceAsc" name="orderByPriceAsc" value="${search.orderByPriceAsc}"/>

  <!-- 검색 영역 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="right">
        가격
        <a href="javascript:fncGetList(${empty resultPage.currentPage ? 1 : resultPage.currentPage}, 'DESC');">↑</a>
        <a href="javascript:fncGetList(${empty resultPage.currentPage ? 1 : resultPage.currentPage}, 'ASC');">↓</a>
        &nbsp;
        <select name="searchCondition" class="ct_input_g" style="width:80px">
          <option value="0"  ${ !empty search.searchCondition && search.searchCondition==0 ? "selected" : "" }>상품명</option>
          <option value="1"  ${ !empty search.searchCondition && search.searchCondition==1 ? "selected" : "" }>상품가격</option>
        </select>
        <input type="text" name="searchKeyword" value="${! empty search.searchKeyword ? search.searchKeyword : ""}"
               class="ct_input_g" style="width:200px; height:19px" />
      </td>
      <td align="right" width="70">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <a href="javascript:fncGetList(1);">검색</a>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>
<!-- ===== detailForm 끝 ===== -->

<!-- =================== 리스트 영역 (폼 바깥) =================== -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
  <tr>
    <!-- 열 수 9개 기준으로 colspan=9 -->
    <td colspan="9">
      전체 ${resultPage.totalCount} 건수, 현재 ${resultPage.currentPage} 페이지
    </td>
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
  <tr>
    <td colspan="9" bgcolor="808285" height="1"></td>
  </tr>

  <c:forEach var="product" items="${list}" varStatus="loop">
    <tr class="ct_list_pop">
      <!-- ↓ 내림차순 번호 (큰→작게) -->
      <td align="center">
        ${resultPage.totalCount - ((resultPage.currentPage-1) * resultPage.pageSize) - loop.index}
      </td>
      <td></td>

      <!-- 상품명: 개별 POST 폼 (중첩 아님) -->
      <td align="left">
        <form action="/getProduct.do" method="post" style="display:inline;">
          <input type="hidden" name="prodNo" value="${product.prodNo}" />
          <button type="submit" class="a-like">${product.prodName}</button>
        </form>
      </td>

      <td></td>
      <td align="left">${product.price}</td>
      <td></td>
      <td align="left">${product.manuDate}</td>
      <td></td>

      <!-- 현재상태: 필요 시 '배송하기'도 개별 POST 폼 -->
      <td align="center">
        <c:choose>
          <c:when test="${not empty user and user.role eq 'admin' and product.proTranCode eq '1'}">
            ${product.proTranState}
            <form action="/updateTranCodeByProduct.do" method="post" style="display:inline;">
              <input type="hidden" name="prodNo" value="${product.prodNo}" />
              <input type="hidden" name="tranStatusCode" value="2" />
              <button type="submit" class="a-like">배송하기</button>
            </form>
          </c:when>
          <c:otherwise>
            ${product.proTranState}
          </c:otherwise>
        </c:choose>
      </td>
    </tr>
    <tr>
      <td colspan="9" bgcolor="D6D7D6" height="1"></td>
    </tr>
  </c:forEach>
</table>

<!-- =================== 페이지 네비게이터 =================== -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
  <tr>
    <td align="center">
      <!-- pageNavigator.jsp 내부에서 javascript:fncGetList(n) 호출하도록 구성되어 있으면 OK -->
      <jsp:include page="../common/pageNavigator.jsp"/>
    </td>
  </tr>
</table>

</div>
</body>
</html>
