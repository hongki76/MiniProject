<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="proTranCode" value="${fn:trim(product.proTranCode)}" />
<c:set var="user" value="${sessionScope.user}" />

<html>
<head>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <title>상품상세조회</title>
  <style>
    .txt-link { background:none; border:0; padding:0; color:#06c; text-decoration:underline; cursor:pointer; font:inherit; }
    .txt-disabled { color:#999; text-decoration:none; cursor:default; }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">

<!-- 상단 타이틀 영역 -->
<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37"></td>
    <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">상품상세조회</td>
          <td width="20%" align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37"/></td>
  </tr>
</table>

<!-- 상세 정보 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">
      상품번호 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
    </td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr><td width="105">${product.prodNo}</td></tr>
      </table>
    </td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">
      상품명 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
    </td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.prodName}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">
      상품이미지 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
    </td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">
      <img src="${product.fileName}"/>
    </td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">
      상품상세정보 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
    </td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.prodDetail}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">제조일자</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.manuDate}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">가격</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.price}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">등록일자</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.regDate}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
</table>

<!-- 하단 버튼 영역 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
  <tr>
    <td width="53%"></td>
    <td align="right">
      <table border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="50" height="23">
			<c:choose>
			  <c:when test="${not empty user and user.role eq 'admin'}">
			    <form action="${cPath}/updateProductView.do" method="post" style="display:inline;">
			      <input type="hidden" name="prodNo" value="${product.prodNo}" />
			      <button type="submit" class="a-like">수정</button>
			    </form>
			  </c:when>
			
			  <c:otherwise>
			    <form action="${cPath}/addPurchaseView.do" method="post" style="display:inline;">
			      <input type="hidden" name="prodNo" value="${product.prodNo}" />
			      <button type="submit"
			              class="${proTranCode eq '0' or empty proTranCode ? 'txt-link' : 'txt-disabled'}"
			              ${proTranCode ne '0' and not empty proTranCode ? 'disabled' : ''}>
			        구매
			      </button>
			    </form>
			  </c:otherwise>
			</c:choose>
          </td>
          <td width="30" height="23">
            <a href="javascript:history.go(-1)">이전</a>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

</body>
</html>
