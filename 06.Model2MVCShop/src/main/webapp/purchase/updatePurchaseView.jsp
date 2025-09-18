<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
  <title>구매정보 수정</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <script type="text/javascript" src="../javascript/calendar.js"></script>
</head>

<body bgcolor="#ffffff" text="#000000">

<form name="updatePurchase" method="post" action="/updatePurchase.do">
  <input type="hidden" name="tranNo"   value="${purchase.tranNo}">
  <input type="hidden" name="buyerId"  value="${purchase.buyer.userId}">

  <!-- Title Bar -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37">
        <img src="/images/ct_ttl_img01.gif" width="15" height="37" />
      </td>
      <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">구매정보수정</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37">
        <img src="/images/ct_ttl_img03.gif" width="12" height="37" />
      </td>
    </tr>
  </table>

  <!-- Form Body -->
  <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">구매자아이디</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <c:out value="${purchase.buyer.userId}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">구매방법</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <select name="paymentOption" class="ct_input_g" style="width: 100px; height: 19px" maxLength="20">
          <option value="1">
            <c:if test="${fn:trim(purchase.paymentOption) eq '1'}">
              <c:out value="selected" />
            </c:if>현금구매
          </option>
          <option value="2">
            <c:if test="${fn:trim(purchase.paymentOption) eq '2'}">
              <c:out value="selected" />
            </c:if>신용구매
          </option>
        </select>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">구매자이름</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="receiverName" class="ct_input_g" style="width: 200px; height: 19px"
               maxLength="20" value="${purchase.receiverName}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">구매자 연락처</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="receiverPhone" class="ct_input_g" style="width: 200px; height: 19px"
               maxLength="20" value="${purchase.receiverPhone}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">구매자Email</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="receiverEmail" class="ct_input_g" style="width: 400px; height: 19px"
               maxLength="200" value="${purchase.receiverEmail}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">구매요청사항</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="dlvyRequest" class="ct_input_g" style="width: 400px; height: 19px"
               maxLength="200" value="${purchase.dlvyRequest}" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td width="104" class="ct_write">배송희망일자</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td width="200" class="ct_write01">
        <c:choose>
          <!-- Date 타입이면 yyyyMMdd 로 포맷 -->
          <c:when test="${purchase.dlvyDate instanceof T(java.util.Date)}">
            <input type="text" readonly="readonly" name="dlvyDate" class="ct_input_g"
                   style="width: 100px; height: 19px" maxLength="20"
                   value="<fmt:formatDate value='${purchase.dlvyDate}' pattern='yyyyMMdd'/>" />
          </c:when>
          <!-- 문자열이면 앞 10자리(yyyy-MM-dd) 잘라서 하이픈 제거 -->
          <c:otherwise>
            <c:set var="dlvyStr10" value="${fn:substring(purchase.dlvyDate,0,10)}" />
            <input type="text" readonly="readonly" name="dlvyDate" class="ct_input_g"
                   style="width: 100px; height: 19px" maxLength="20"
                   value="${fn:replace(dlvyStr10,'-','')}" />
          </c:otherwise>
        </c:choose>
        <img src="../images/ct_icon_date.gif" width="15" height="15"
             onclick="show_calendar('document.updatePurchase.dlvyDate', document.updatePurchase.dlvyDate.value)" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- Buttons -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
    <tr>
      <td width="53%"></td>
      <td align="right">
        <table align="right" style="margin-top:10px;">
          <tr>
            <td class="ct_btn01" style="padding:3px 8px; border:1px solid #ccc; background:#f5f5f5; cursor:pointer;">
              <input type="submit" value="수정" style="border:none; background:none; cursor:pointer;"/>
            </td>
            <td width="10"></td>
            <td class="ct_btn01" style="padding:3px 8px; border:1px solid #ccc; background:#f5f5f5; cursor:pointer;">
              <a href="/getPurchase.do?tranNo=${purchase.tranNo}" style="text-decoration:none; color:inherit;">취소</a>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>

</body>
</html>
