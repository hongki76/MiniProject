<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head><title>구매 완료</title></head>
<body>

<h2>다음과 같이 구매가 완료되었습니다.</h2>

<c:choose>
  <c:when test="${empty purchase}">
    <p>구매 정보를 찾을 수 없습니다.</p>
  </c:when>
  <c:otherwise>
    <table border="1" cellpadding="6">
      <tr>
        <td>물품번호</td>
        <td>${purchase.purchaseProd.prodNo}</td>
      </tr>
      <tr>
        <td>구매자아이디</td>
        <td>${purchase.buyer.userId}</td>
      </tr>
      <tr>
        <td>구매방법</td>
        <td>
          <c:choose>
            <c:when test="${purchase.paymentOption eq '001'}">신용구매</c:when>
            <c:otherwise>현금구매</c:otherwise>
          </c:choose>
        </td>
      </tr>
      <tr>
        <td>구매자이름</td>
        <td>${purchase.receiverName}</td>
      </tr>
      <tr>
        <td>구매자연락처</td>
        <td>${purchase.receiverPhone}</td>
      </tr>
      <tr>
        <td>구매자주소</td>
        <td>${purchase.receiverEmail}</td>
      </tr>
      <tr>
        <td>구매요청사항</td>
        <td>${purchase.dlvyRequest}</td>
      </tr>
      <tr>
        <td>배송희망일자</td>
        <td>${purchase.dlvyDate}</td>
      </tr>
    </table>
  </c:otherwise>
</c:choose>

</body>
</html>
