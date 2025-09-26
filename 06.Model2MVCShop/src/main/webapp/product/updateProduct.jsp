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

    /* 첨부 갤러리 & 미리보기 공통 스타일 */
    .muted{ color:#888; font-size:12px; }
    .file-grid{
      margin-top:8px;
      display:grid;
      grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
      gap:10px;
    }
    .file-card{
      border:1px solid #ddd; border-radius:8px; padding:8px; background:#fafafa;
      display:flex; flex-direction:column; gap:6px;
    }
    .thumb{
      width:100%; aspect-ratio: 4/3; object-fit:cover; border:1px solid #eee; border-radius:6px; background:#fff;
      display:block;
    }
    .thumb-placeholder{
      width:100%; aspect-ratio:4/3; border:1px dashed #ccc; border-radius:6px;
      display:grid; place-items:center; color:#777; font-size:12px; background:#fff;
    }
    .file-name{ font-size:12px; line-height:1.4; word-break:break-all; color:#333; }
    .file-actions{ display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
    .btn-mini{ font-size:12px; padding:2px 6px; border:1px solid #ddd; border-radius:6px; background:#fff; cursor:pointer; }
    .file-summary{ margin-top:6px; font-size:12px; color:#333; }
    .badge{ display:inline-block; padding:2px 6px; border-radius:999px; border:1px solid #ddd; font-size:11px; color:#555; background:#fff; }
    .badge.warn{ border-color:#e0b800; color:#8a6d00; background:#fff8dd; }
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

    <!-- ===== 기존 첨부파일(삭제 선택 가능) ===== -->
    <tr>
      <td class="ct_write">기존 첨부</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <c:choose>
          <c:when test="${not empty fileList}">
            <div class="muted">총 ${fn:length(fileList)}개 — 삭제할 파일을 체크하세요.</div>
            <div class="file-grid">
              <c:forEach var="f" items="${fileList}">
                <c:set var="name" value="${f.fileName}" />
                <c:set var="lower" value="${fn:toLowerCase(name)}" />
                <c:set var="isImg"
                       value="${fn:endsWith(lower,'.png')
                             or fn:endsWith(lower,'.jpg')
                             or fn:endsWith(lower,'.jpeg')
                             or fn:endsWith(lower,'.gif')
                             or fn:endsWith(lower,'.webp')
                             or fn:endsWith(lower,'.bmp')}" />
                <div class="file-card">
                  <c:choose>
                    <c:when test="${isImg}">
                      <img class="thumb" src="${cPath}/upload/${name}" alt="${name}" />
                    </c:when>
                    <c:otherwise>
                      <div class="thumb-placeholder">미리보기 없음</div>
                    </c:otherwise>
                  </c:choose>

                  <div class="file-name" title="${name}">${name}</div>
                  <div class="file-actions">
                    <label class="muted">
                      <input type="checkbox" name="deleteFileNo" value="${f.fileNo}"> 삭제
                    </label>
                    <a class="btn-mini" href="${cPath}/upload/${name}" target="_blank">열기</a>
                    <a class="btn-mini" href="${cPath}/upload/${name}" download>다운로드</a>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:when>
          <c:otherwise>
            <span class="muted">등록된 첨부가 없습니다.</span>
          </c:otherwise>
        </c:choose>
      </td>
    </tr>
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

	<!-- ===== 새 첨부 추가(멀티 업로드) ===== -->
	<tr>
	  <td class="ct_write">새 첨부 추가</td>
	  <td bgcolor="D6D6D6" width="1"></td>
	  <td class="ct_write01">
	    <input
	      type="file"
	      name="productFile"
	      id="productFile"
	      class="ct_input_g"
	      style="width:300px;"
	      multiple="multiple"
	      accept="image/*"
	      aria-label="새 첨부 파일 선택(여러 개 선택 가능)" />
	
	    <div class="muted" id="fileHelp" style="margin-top:4px;">
	      여러 이미지를 한 번에 선택하려면 Ctrl/Shift 키를 사용하세요.
	    </div>
	
	    <!-- 선택 요약 & 미리보기 -->
	    <div class="file-summary" id="fileSummary" style="display:none;" aria-live="polite" aria-describedby="fileHelp"></div>
	    <div class="file-grid" id="filePreview" aria-live="polite"></div>
	
	    <div style="margin-top:6px;">
	      <button type="button" class="btn-mini" id="btnClearFiles">선택 파일 모두 지우기</button>
	    </div>
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
                <c:otherwise>
                  <span class="txt-disabled">수정불가</span>
                </c:otherwise>
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
<script src="${cPath}/javascript/CommonScript-jq.js"></script>
<script src="${cPath}/javascript/calendar.js"></script>
<script src="${cPath}/javascript/product-update.js"></script>
</body>
</html>
