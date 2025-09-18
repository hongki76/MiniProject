<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="proTranCode" value="${fn:trim(product.proTranCode)}" />

<html>
<head>
<title>상품정보수정</title>

<link rel="stylesheet" href="${cPath}/css/admin.css" type="text/css">

<script type="text/javascript" src="${cPath}/javascript/calendar.js"></script>

<script type="text/javascript">
// POST 고정 유효성 검사 + 전송
function fncAddProduct(){
  var f = document.forms['detailForm'];
  if(!f) return;

  var name = f.prodName.value.trim();
  var detail = f.prodDetail.value.trim();
  var manuDate = f.manuDate.value.trim();
  var price = f.price.value.trim();

  if(!name){ alert("상품명은 반드시 입력하여야 합니다."); return; }
  if(!detail){ alert("상품상세정보는 반드시 입력하여야 합니다."); return; }
  if(!manuDate){ alert("제조일자는 반드시 입력하셔야 합니다."); return; }
  if(!price){ alert("가격은 반드시 입력하셔야 합니다."); return; }

  f.action = "${cPath}/updateProduct.do";
  f.method = "post";
  f.submit();
}
</script>
</head>

<form name="detailForm" action="${cPath}/updateProduct.do" method="post" style="display:inline;">
  <input type="hidden" name="prodNo" value="${product.prodNo}"/>

  <!-- 상단 타이틀 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${cPath}/images/ct_ttl_img01.gif" width="15" height="37"/></td>
      <td background="${cPath}/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">상품수정</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="${cPath}/images/ct_ttl_img03.gif" width="12" height="37"/></td>
    </tr>
  </table>

  <!-- 입력 폼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
    <tr>
      <td width="104" class="ct_write">상품명 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodName" class="ct_input_g" style="width: 200px; height: 19px" maxlength="50" value="${product.prodName}">
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">상품상세정보 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodDetail" value="${product.prodDetail}" class="ct_input_g" style="width: 300px; height: 19px" maxlength="200">
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">제조일자 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" readonly="readonly" name="manuDate" value="${product.manuDate}" class="ct_input_g" style="width: 120px; height: 19px" maxlength="10">
        <img src="${cPath}/images/ct_icon_date.gif" width="15" height="15"
             onclick="show_calendar('document.detailForm.manuDate', document.detailForm.manuDate.value)" />
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">가격 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="number" name="price" value="${product.price}" class="ct_input_g" style="width: 120px; height: 19px" min="0" step="1"/> 원
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <tr>
      <td class="ct_write">상품이미지</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="fileName" class="ct_input_g" style="width: 300px; height: 19px" maxlength="100" value="${product.fileName}"/>
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- 하단 버튼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
    <tr>
      <td width="53%"></td>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="50" height="23">
              <c:choose>
                <c:when test="${empty proTranCode or proTranCode eq '0'}">
                  <!-- 구매 가능 상태(=판매중)일 때만 수정 허용 -->
                  <button type="button" class="txt-link" onclick="fncAddProduct()">수정</button>
                </c:when>
                <c:otherwise>
                  <button type="button" class="txt-disabled" disabled="disabled">수정</button>
                </c:otherwise>
              </c:choose>
            </td>
            <td width="10"></td>
            <td width="17" height="23"><img src="${cPath}/images/ct_btnbg01.gif" width="17" height="23"/></td>
            <td background="${cPath}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <a href="javascript:history.go(-1)">취소</a>
            </td>
            <td width="14" height="23"><img src="${cPath}/images/ct_btnbg03.gif" width="14" height="23"/></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>

</body>
</html>
