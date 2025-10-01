<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />
<c:set var="proTranCode" value="${fn:trim(product.proTranCode)}" />
<c:set var="user" value="${sessionScope.user}" />
<c:set var="editable" value="${empty proTranCode or proTranCode eq '0'}"/>

<html>
<head>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <title>상품상세조회</title>
  <style>
    .txt-link { background:none; border:0; padding:0; color:#06c; text-decoration:underline; cursor:pointer; font:inherit; }
    .txt-disabled { color:#999; text-decoration:none; cursor:default; }
    .a-like{ cursor:pointer; text-decoration:underline; color:#06c; background:none; border:none; padding:0; font:inherit; }

    /* ===== 첨부 갤러리 ===== */
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
    .file-meta{ font-size:11px; color:#666; }
    .file-actions{ display:flex; gap:8px; align-items:center; }
    .btn-mini{
      font-size:12px; padding:2px 6px; border:1px solid #ddd; border-radius:6px; background:#fff; cursor:pointer;
    }
    .muted{ color:#888; font-size:12px; }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">

<!-- 상단 타이틀 영역 -->
<table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37" alt=""></td>
    <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="93%" class="ct_ttl01">상품상세조회</td>
          <td width="20%" align="right">&nbsp;</td>
        </tr>
      </table>
    </td>
    <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37" alt=""/></td>
  </tr>
</table>

<!-- 상세 정보 -->
<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">상품번호 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt="필수"/></td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td width="105">${product.prodNo}</td></tr></table></td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  <tr>
    <td width="104" class="ct_write">상품명 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt="필수"/></td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.prodName}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <!-- ===== 멀티 첨부 갤러리/목록 ===== -->
  <tr>
    <td width="104" class="ct_write">첨부파일</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">

      <c:choose>
        <c:when test="${not empty fileList}">
          <div class="muted">총 ${fn:length(fileList)}개</div>

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
                  <a class="btn-mini" href="${cPath}/upload/${name}" target="_blank">열기</a>
                  <a class="btn-mini" href="${cPath}/upload/${name}" download>다운로드</a>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:when>
        <c:otherwise>
          <span class="muted">첨부된 파일이 없습니다.</span>
        </c:otherwise>
      </c:choose>

    </td>
  </tr>

  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">상품상세정보 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle" alt="필수"/></td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">${product.prodDetail}</td>
  </tr>
  <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

  <tr>
    <td width="104" class="ct_write">제조일자</td>
    <td bgcolor="D6D6D6" width="1"></td>
    <td class="ct_write01">
		<c:if test="${not empty product.manuDate}">
		  <c:set var="md" value="${product.manuDate}" />
		  <c:set var="digits" value="${fn:replace(fn:replace(fn:replace(fn:replace(md,'-',''),'/',''),'.',''),' ','')}" />
		  <c:choose>
		    <c:when test="${fn:length(digits) == 8}">
		      ${fn:substring(digits,0,4)}-${fn:substring(digits,4,6)}-${fn:substring(digits,6,8)}
		    </c:when>
		    <c:when test="${fn:length(digits) == 6}">
		      <c:set var="yy" value="${fn:substring(digits,0,2)}" />
		      <fmt:parseNumber var="yyNum" value="${yy}" integerOnly="true" />
		      <c:choose>
		        <c:when test="${yyNum le 69}"><c:set var="year4" value="${'20'}${yy}" /></c:when>
		        <c:otherwise><c:set var="year4" value="${'19'}${yy}" /></c:otherwise>
		      </c:choose>
		      <c:set var="mm" value="${fn:substring(digits,2,4)}" />
		      <c:set var="dd" value="${fn:substring(digits,4,6)}" />
		      ${year4}-${mm}-${dd}
		    </c:when>
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
    <td class="ct_write01">
        <c:if test="${not empty product.regDate}">
          <fmt:formatDate value="${product.regDate}" pattern="yyyy-MM-dd" />
        </c:if>
    </td>
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
              <c:when test="${not empty user and user.role eq 'admin' and editable}">
                <form action="${cPath}/product/updateProductView" method="post" style="display:inline;">
                  <input type="hidden" name="prodNo" value="${product.prodNo}" />
                  <button type="submit" class="a-like">수정</button>
                </form>
              </c:when>
            </c:choose>

            <c:choose>
              <c:when test="${not empty user and user.role eq 'user' and editable}">
                <a href="${cPath}/purchase/addPurchase?prodNo=${product.prodNo}" class="txt-link" id="btnBuy"
                   data-cpath="${cPath}" data-prodno="${product.prodNo}">구매</a>
              </c:when>
            </c:choose>
          </td>
          <td width="30" height="23">
            <button type="button" class="a-like" id="btnBack">이전</button>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<!-- 스크립트 로드 -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="/javascript/product-get.js"></script>
</body>
</html>
