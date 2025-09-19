<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
<title>구매 목록조회</title>
<link rel="stylesheet" href="/css/admin.css" type="text/css">
<script type="text/javascript">
  <!--
  	function fncMove(page) { 
	  location.href = "/purchase/getPurchaseList?page="+page; 
	}  
  
	// 검색 / page 두가지 경우 모두 Form 전송을 위해 JavaScrpt 이용  
	function fncGetList(currentPage) {
		document.getElementById("currentPage").value = currentPage;
	   	document.detailForm.submit();		
	}
-->  
</script>
</head>

<body bgcolor="#ffffff" text="#000000">
<div style="width: 98%; margin-left: 10px;">

<form name="detailForm" action="/purchase/getPurchaseList" method="post">

<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37" /></td>
    <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">구매 목록조회</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37" /></td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
  <tr>
    <td colspan="11">전체 ${resultPage.totalCount} 건수, 현재 ${resultPage.currentPage} 페이지</td>
  </tr>
  <tr>
    <td class="ct_list_b" width="100">No</td>
    <td class="ct_line02"></td>
    <td class="ct_list_b" width="150">상품명</td>
    <td class="ct_line02"></td>
    <td class="ct_list_b" width="150">상세정보</td>
    <td class="ct_line02"></td>
    <td class="ct_list_b">가격</td>
    <td class="ct_line02"></td>
    <td class="ct_list_b">배송현황</td>
    <td class="ct_line02"></td>
    <td class="ct_list_b">정보수정</td>
  </tr>
  <tr><td colspan="11" bgcolor="808285" height="1"></td></tr>

  <c:choose>
    <c:when test="${not empty list}">
      <c:forEach var="purchase" items="${list}" varStatus="st">

        <tr class="ct_list_pop">
          <td align="center">
            <!-- 행 번호: baseRowNo - index -->
        	<c:set var="rowNo" value="${resultPage.baseRowNo - st.index}" />
            ${rowNo}
          </td>
          <td></td>
          <td align="left">
              <a href="/purchase/getPurchase?tranNo=${purchase.tranNo}">${purchase.purchaseProd.prodName}</a>
          </td>
          <td></td>
          <td align="left"><c:out value="${purchase.purchaseProd.prodDetail}" default=""/>${purchase.purchaseProd.prodDetail}</td>
          <td></td>
          <td align="left"><c:out value="${purchase.purchaseProd.price}" default=""/></td>
          <td></td>
          <td align="left">현재 ${tranStateMap[purchase.tranNo]} 상태입니다.</td>
          <td></td>
          <td align="left">
            <c:if test="${tranStateMap[purchase.tranNo] eq '배송중'}">
              <a href="/purchase/updateTranCode?tranNo=${purchase.tranNo}&amp;tranStatusCode=3">물건도착</a>
            </c:if>
          </td>
        </tr>
        <tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>
      </c:forEach>
    </c:when>
    <c:otherwise>
      <tr>
        <td colspan="11" align="center" class="ct_list_pop" style="padding:16px;">
          표시할 구매내역이 없습니다.
        </td>
      </tr>
      <tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>
    </c:otherwise>
  </c:choose>
</table>

<!-- 페이지 네비게이션 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
  <tr>
    <td align="center">
	    <jsp:include page="../common/pageNavigator.jsp"/>	
    </td>
  </tr>
</table>

</form>
</div>

</body>
</html>
