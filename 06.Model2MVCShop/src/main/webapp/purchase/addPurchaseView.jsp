<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <title>상품 구매</title>
  <style>
    .a-like{ cursor:pointer; text-decoration:underline; color:#06c; background:none; border:0; padding:0; font:inherit; }
    .icon-btn{ background:none; border:0; padding:0; margin:0; cursor:pointer; }
  </style>
</head>

<body>

<form name="addPurchase" id="addPurchase" method="post" action="/purchase/addPurchase">

  <!-- 히든값 -->
  <input type="hidden" name="prodNo"  value="${product.prodNo}" />

  <!-- 상단 타이틀 바 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15"><img src="/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="/images/ct_ttl_img02.gif" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="ct_ttl01">상품상세조회</td>
            <td align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12"><img src="/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>

  <!-- 본문 -->
  <table width="600" border="0" cellspacing="0" cellpadding="0" align="center" style="margin-top:13px;">
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">상품번호</td>
      <td bgcolor="#D6D6D6" width="1"></td>
      <td class="ct_write01">${product.prodNo}</td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">상품명</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">${product.prodName}</td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">상품상세정보</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">${product.prodDetail}</td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>

    <tr>
      <td class="ct_write">제조일자</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <c:if test="${not empty product.manuDate}">
          <c:set var="md" value="${product.manuDate}" />
          <%-- 구분자 제거( -, /, ., 공백 ) → 숫자만 남김 --%>
          <c:set var="digits" value="${fn:replace(md,'-','')}" />
          <c:set var="digits" value="${fn:replace(digits,'/','')}" />
          <c:set var="digits" value="${fn:replace(digits,'.','')}" />
          <c:set var="digits" value="${fn:replace(digits,' ','')}" />

          <c:choose>
            <%-- 8자리: YYYYMMDD (예: 2025/09/01, 2025-09-01, 20250901) --%>
            <c:when test="${fn:length(digits) == 8}">
              ${fn:substring(digits,0,4)}-${fn:substring(digits,4,6)}-${fn:substring(digits,6,8)}
            </c:when>

            <%-- 6자리: YYMMDD (예: 25/09/01, 250901) → 세기 보정 --%>
            <c:when test="${fn:length(digits) == 6}">
              <c:set var="yy" value="${fn:substring(digits,0,2)}" />
              <fmt:parseNumber var="yyNum" value="${yy}" integerOnly="true" />
              <c:choose>
                <c:when test="${yyNum le 69}">
                  <c:set var="year4" value="${'20'}${yy}" />
                </c:when>
                <c:otherwise>
                  <c:set var="year4" value="${'19'}${yy}" />
                </c:otherwise>
              </c:choose>
              <c:set var="mm" value="${fn:substring(digits,2,4)}" />
              <c:set var="dd" value="${fn:substring(digits,4,6)}" />
              ${year4}-${mm}-${dd}
            </c:when>

            <%-- 그 외: 'YYYY-MM-DD ...'이면 앞 10자만 출력 --%>
            <c:otherwise>
              <c:choose>
                <c:when test="${fn:length(md) >= 10 && fn:substring(md,4,5) == '-'}">
                  ${fn:substring(md,0,10)}
                </c:when>
                <c:otherwise>
                  ${md}
                </c:otherwise>
              </c:choose>
            </c:otherwise>
          </c:choose>
        </c:if>
      </td>
    </tr>

    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">가격</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <fmt:formatNumber value="${product.price}" pattern="#,##0" />
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">등록일자</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <c:if test="${not empty product.regDate}">
          <fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" />
        </c:if>
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매자아이디</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01"><c:out value="${sessionScope.user.userId}" /></td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매방법</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <select name="paymentOption" class="ct_input_g" style="width:100px;">
          <option value="1">현금구매</option>
          <option value="2">카드구매</option>
        </select>
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매자이름</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <input type="text" name="receiverName"
               value="<c:out value='${sessionScope.user.userName}'/>"
               class="ct_input_g" style="width:100px;">
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매자연락처</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <input type="text" name="receiverPhone"
               value="<c:out value='${sessionScope.user.phone}'/>"
               class="ct_input_g" style="width:100px;">
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매자Email</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <input type="text" name="receiverEmail"
               value="<c:out value='${sessionScope.user.email}'/>"
               class="ct_input_g" style="width:100px;">
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매요청사항</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <input type="text" name="dlvyRequest" class="ct_input_g" style="width:300px;">
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">배송희망일자</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
        <input type="text" name="dlvyDate" class="ct_input_g" style="width:100px;">
        <img src="../images/ct_icon_date.gif" width="15" height="15"
             onclick="show_calendar('document.addPurchase.dlvyDate', document.addPurchase.dlvyDate.value.replace(/-/g,''))" />
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
  </table>

  <!-- 하단 버튼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="center">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td><img src="/images/ct_btnbg01.gif" width="17" height="23" /></td>
			<td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
			  <button type="button" id="btnSubmit" class="a-like">구매</button>
			</td>
            <td><img src="/images/ct_btnbg03.gif" width="14" height="23" /></td>
            <td width="30"></td>
            <td><img src="/images/ct_btnbg01.gif" width="17" height="23" /></td>
			<td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
			  <button type="button" id="btnCancel" class="a-like">취소</button>
			</td>
            <td><img src="/images/ct_btnbg03.gif" width="14" height="23" /></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

</form>

<!-- 스크립트 -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="/javascript/CommonScript-jq.js"></script>
<script src="/javascript/calendar.js"></script>
<script src="/javascript/purchase-add.js"></script>

</body>
</html>
