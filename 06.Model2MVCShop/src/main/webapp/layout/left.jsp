<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="user"  value="${sessionScope.user}" />

<html>
<head>
  <title>Model2 MVC Shop</title>
  <link href="/css/left.css" rel="stylesheet" type="text/css">
  <style>
    .a-like{ cursor:pointer; text-decoration:underline; color:#06c; background:none; border:none; padding:0; font:inherit; }
  </style>
  <script type="text/javascript">
    // 팝업( GET )
    function openHistory(){
      var name = "popWin";
      var feat = "left=300,top=200,width=300,height=200,scrollbars=no,menubar=no,resizable=no";
      window.open("/history.jsp", name, feat);
    }
  </script>
</head>

<body background="/images/left/imgLeftBg.gif" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">

<table width="159" border="0" cellspacing="0" cellpadding="0">

  <!-- menu 01 line -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">

        <!-- 로그인 사용자의 개인정보조회 -->
        <c:if test="${not empty user}">
          <tr>
            <td class="Depth03">
              <a class="a-like" target="rightFrame"
                 href="${cPath}/user/getUser?userId=${fn:escapeXml(user.userId)}">개인정보조회</a>
            </td>
          </tr>
        </c:if>

        <!-- 관리자 전용: 회원정보조회 -->
        <c:if test="${not empty user and user.role eq 'admin'}">
          <tr>
            <td class="Depth03">
              <a class="a-like" target="rightFrame" href="${cPath}/user/listUser">회원정보조회</a>
            </td>
          </tr>
        </c:if>

        <tr><td class="DepthEnd">&nbsp;</td></tr>
      </table>
    </td>
  </tr>

  <!-- menu 02 line : 관리자 전용 상품 관리 -->
  <c:if test="${not empty user and user.role eq 'admin'}">
    <tr>
      <td valign="top">
        <table border="0" cellspacing="0" cellpadding="0" width="159">
          <tr>
            <td class="Depth03">
              <!-- 판매상품등록 (뷰 진입 GET) -->
              <a class="a-like" target="rightFrame" href="${cPath}/product/addProductView">판매상품등록</a>
            </td>
          </tr>
          <tr>
            <td class="Depth03">
              <!-- 판매상품관리 -->
              <a class="a-like" target="rightFrame" href="${cPath}/product/getProductList">판매상품관리</a>
            </td>
          </tr>
          <tr><td class="DepthEnd">&nbsp;</td></tr>
        </table>
      </td>
    </tr>
  </c:if>

  <!-- menu 03 line : 일반 사용자 메뉴 -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">
          
        <!-- 로그인 + 일반 사용자일 때 -->          
        <c:if test="${not empty user and user.role eq 'user'}">
          <tr>
            <td class="Depth03">
              <a class="a-like" target="rightFrame" href="${cPath}/product/getProductList">상 품 검 색</a>
            </td>
          </tr>        
          <tr>
            <td class="Depth03">
              <a class="a-like" target="rightFrame" href="${cPath}/purchase/getPurchaseList">구매이력조회</a>
            </td>
          </tr>
	        <tr>
	          <td class="Depth03">
	            <a class="a-like" href="#" onclick="openHistory(); return false;">최근 본 상품</a>
	          </td>
	        </tr>          
        </c:if>

        <tr><td class="DepthEnd">&nbsp;</td></tr>
      </table>
    </td>
  </tr>
  
  <!-- menu 03 line : 일반 사용자 메뉴 -->
  <tr>
    <td valign="top">
      <table border="0" cellspacing="0" cellpadding="0" width="159">
          
        <!-- 비회원 -->          
        <c:if test="${empty user}">
          <tr>
            <td class="Depth03">
              <a class="a-like" target="rightFrame" href="${cPath}/product/getProductList">상 품 검 색</a>
            </td>
          </tr>
	        <tr>
	          <td class="Depth03">
	            <a class="a-like" href="#" onclick="openHistory(); return false;">최근 본 상품</a>
	          </td>
	        </tr>
        </c:if>

        <tr><td class="DepthEnd">&nbsp;</td></tr>
      </table>
    </td>
  </tr>

</table>
</body>
</html>
