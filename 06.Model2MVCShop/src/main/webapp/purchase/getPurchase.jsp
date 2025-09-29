<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
  <title>구매상세조회</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <style>
    .a-like { cursor:pointer; text-decoration:underline; color:#06c; background:none; border:0; padding:0; font:inherit; }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">

<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37">
      <img src="/images/ct_ttl_img01.gif" width="15" height="37"/>
    </td>
    <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">구매상세조회</td>
          <td width="20%" align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37">
      <img src="/images/ct_ttl_img03.gif" width="12" height="37"/>
    </td>
  </tr>
</table>

<c:choose>
  <c:when test="${empty purchase}">
    <p style="margin:16px;">구매 정보를 찾을 수 없습니다.</p>
  </c:when>
  <c:otherwise>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">물품번호 <img src="/images/ct_icon_red.gif" /></td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01">
          <c:out value="${purchase.purchaseProd.prodNo}" default=""/>
        </td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">구매자아이디 <img src="/images/ct_icon_red.gif" /></td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01">
          <c:out value="${purchase.buyer.userId}" default=""/>
        </td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">구매방법</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01">
          <c:out value="${purchase.paymentOptionName}" default=""/>
        </td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">구매자이름</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01"><c:out value="${purchase.receiverName}" default=""/></td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">구매자연락처</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01"><c:out value="${purchase.receiverPhone}" default=""/></td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">구매자주소</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01"><c:out value="${purchase.receiverEmail}" default=""/></td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">구매요청사항</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01"><c:out value="${purchase.dlvyRequest}" default=""/></td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">배송희망일</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01">
          <c:choose>
            <c:when test="${not empty purchase.dlvyDate}">
              <fmt:parseDate value="${purchase.dlvyDate}" pattern="yyyy-MM-dd HH:mm:ss" var="__d" />
              <fmt:formatDate value="${__d}" pattern="yyyy-MM-dd" />
            </c:when>
          </c:choose>
        </td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

      <tr>
        <td width="104" class="ct_write">주문일</td>
        <td bgcolor="D6D6D6" width="1"></td>
        <td class="ct_write01">
          <c:choose>
            <c:when test="${not empty purchase.orderDate}">
              <fmt:formatDate value="${purchase.orderDate}" pattern="yyyy-MM-dd" />
            </c:when>
            <c:otherwise><c:out value="${purchase.orderDate}" default=""/></c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    </table>

    <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
      <tr>
        <td width="53%"></td>
        <td align="right">
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
            
              <td width="80">
				<c:if test="${fn:trim(purchase.tranCode) == '0' or fn:trim(purchase.tranCode) == '1'}">
				  <form method="post" action="${cPath}/purchase/cancelPurchase" style="display:inline;"
				        onsubmit="return confirm('이 주문을 취소하시겠습니까?');">
				    <input type="hidden" name="tranNo" value="${purchase.tranNo}" />
				    <button type="submit" class="btn btn-danger">주문 취소</button>
				  </form>
				</c:if>
              </td>
              
              <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"/></td>
              <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
                <!-- 인라인 JS 제거 → 버튼 + jQuery -->
                <button type="button" id="btnOk" class="a-like">확인</button>
              </td>
              <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"/></td>
            </tr>
          </table>
        </td>
      </tr>
    </table>

  </c:otherwise>
</c:choose>

<!-- 외부 스크립트 -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="/javascript/purchase-get.js"></script>
</body>
</html>
