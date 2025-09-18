<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <title>상품 구매</title>
  <script type="text/javascript" src="../javascript/calendar.js"></script>
  <script type="text/javascript">
    function fncAddPurchase() { document.addPurchase.submit(); }
  </script>
</head>

<body>

<form name="addPurchase" method="post" action="/addPurchase.do">

  <!-- 히든값 -->
  <input type="hidden" name="prodNo"  value="${product.prodNo}" />

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
      <td class="ct_write01">${product.manuDate}</td>
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
        <!-- 1차: Date/Timestamp이면 바로 포맷 -->
        <c:catch var="fmtErr">
          <fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd HH:mm" />
        </c:catch>

        <!-- 2차: String("yyyy-MM-dd HH:mm:ss.S")이면 파싱 후 포맷 -->
        <c:if test="${not empty fmtErr}">
          <c:catch var="parseErr">
            <fmt:parseDate value="${product.regDate}" var="regDt" pattern="yyyy-MM-dd HH:mm:ss.S" />
            <fmt:formatDate value="${regDt}" pattern="yyyy-MM-dd HH:mm" />
          </c:catch>

          <!-- 3차: 그래도 실패하면 원문 출력 -->
          <c:if test="${not empty parseErr}">
            ${product.regDate}
          </c:if>
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
      	<input type="text" name="receiverName" value="<c:out value='${sessionScope.user.userName}'/>" class="ct_input_g" style="width:100px;">      
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매자연락처</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
      	<input type="text" name="receiverPhone" value="<c:out value='${sessionScope.user.phone}'/>" class="ct_input_g" style="width:100px;">
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
    <tr>
      <td class="ct_write">구매자Email</td>
      <td bgcolor="#D6D6D6"></td>
      <td class="ct_write01">
      	<input type="text" name="receiverEmail" value="<c:out value='${sessionScope.user.email}'/>" class="ct_input_g" style="width:100px;">
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
             onclick="show_calendar('document.addPurchase.dlvyDate', document.addPurchase.dlvyDate.value)" />
      </td>
    </tr>
    <tr><td colspan="3" bgcolor="#D6D6D6" height="1"></td></tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td align="center">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td><img src="/images/ct_btnbg01.gif" width="17" height="23" /></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <a href="javascript:fncAddPurchase();">구매</a>
            </td>
            <td><img src="/images/ct_btnbg03.gif" width="14" height="23" /></td>
            <td width="30"></td>
            <td><img src="/images/ct_btnbg01.gif" width="17" height="23" /></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <a href="javascript:history.go(-1)">취소</a>
            </td>
            <td><img src="/images/ct_btnbg03.gif" width="14" height="23" /></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

</form>

</body>
</html>
