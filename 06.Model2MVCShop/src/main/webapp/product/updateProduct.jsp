<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="proTranCode" value="${fn:trim(product.proTranCode)}" />
<c:set var="editable" value="${empty proTranCode or proTranCode eq '0'}" />

<html>
<head>
  <title>상품정보수정</title>
  <link rel="stylesheet" href="${cPath}/css/admin.css" type="text/css">
  <style>
    .a-like{ cursor:pointer; text-decoration:underline; color:#06c; background:none; border:none; padding:0; font:inherit; }
    .txt-disabled { color:#999; text-decoration:none; cursor:default; }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">

<form name="detailForm" id="detailForm"
      action="${cPath}/product/updateProduct"
      method="post" enctype="multipart/form-data" style="display:inline;">
  <input type="hidden" name="prodNo" value="${product.prodNo}"/>

  <!-- 상단 타이틀 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="${cPath}/images/ct_ttl_img01.gif" width="15" height="37" alt=""></td>
      <td background="${cPath}/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">상품수정</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="${cPath}/images/ct_ttl_img03.gif" width="12" height="37" alt=""></td>
    </tr>
  </table>

  <!-- 입력 폼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 상품명 -->
    <tr>
      <td width="104" class="ct_write">상품명 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt=""></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodName" id="prodName" class="ct_input_g"
               style="width: 200px; height: 19px" maxlength="50"
               fieldTitle="상품명" required
               value="${product.prodName}">
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 상품상세정보 -->
    <tr>
      <td class="ct_write">상품상세정보 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt=""></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodDetail" id="prodDetail" class="ct_input_g"
               style="width: 300px; height: 19px" maxlength="200"
               fieldTitle="상품상세정보" required
               value="${product.prodDetail}">
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 제조일자 -->
    <tr>
      <td class="ct_write">제조일자 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt=""></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" readonly="readonly" name="manuDate" id="manuDate"
               class="ct_input_g" style="width: 120px; height: 19px"
               maxlength="10" fieldTitle="제조일자" required
               value="${product.manuDate}">
        &nbsp;
        <!-- calendar.js 호출은 JS에서 바인딩: data-target만 지정 -->
        <button type="button" class="a-like open-calendar" data-target="manuDate" aria-label="달력 열기">
          <img src="${cPath}/images/ct_icon_date.gif" width="15" height="15" alt="달력">
        </button>
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 가격 -->
    <tr>
      <td class="ct_write">가격 <img src="${cPath}/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt=""></td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="price" id="price" class="ct_input_g"
               style="width: 120px; height: 19px"
               fieldTitle="가격" required maxLength="10" num="n" fromNum="0"
               value="${product.price}"> 원
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

	<!-- 이미지 -->
	<tr>
	  <td class="ct_write">상품이미지</td>
	  <td bgcolor="D6D6D6" width="1"></td>
	  <td class="ct_write01">
	    <input type="hidden" name="oldFileName" value="${product.fileName}">
	
	    <!-- 미리보기 이미지: id + data-original 부여 -->
	    <img id="previewImg"
	         src="${empty product.fileName ? (cPath += '/images/no-image.png') : ('/upload/' += product.fileName)}"
	         data-original="${empty product.fileName ? (cPath += '/images/no-image.png') : ('/upload/' += product.fileName)}"
	         alt="${product.prodName}"
	         style="max-width:260px; max-height:200px; display:inline-block;" />
	
	    &nbsp;
	
	    <!-- 파일 선택: id + accept -->
	    <input type="file" id="uploadFile" name="uploadFile" 
	           class="ct_input_g" style="width: 300px;" maxlength="100"
	           accept="image/*">

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
                <c:when test="${editable}">
                  <button type="button" id="btnUpdate" class="a-like">수정</button>
                </c:when>
              </c:choose>
            </td>
            <td width="10"></td>
            <td width="17" height="23"><img src="${cPath}/images/ct_btnbg01.gif" width="17" height="23" alt=""></td>
            <td background="${cPath}/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <button type="button" id="btnCancel" class="a-like">취소</button>
            </td>
            <td width="14" height="23"><img src="${cPath}/images/ct_btnbg03.gif" width="14" height="23" alt=""></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</form>

<!-- 스크립트 로드 (하단) -->
<script src="${cPath}/javascript/jquery-3.7.1.min.js"></script>
<script src="${cPath}/javascript/CommonScript-jq.js"></script> <!-- 공통 검증 -->
<script src="${cPath}/javascript/calendar.js"></script>        <!-- 기존 달력 -->
<script src="${cPath}/javascript/product-update.js"></script>  <!-- 신규 전용 스크립트 -->
</body>
</html>
