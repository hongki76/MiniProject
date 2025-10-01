<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="curr" value="${resultPage.currentPage}" />
<c:set var="begin" value="${resultPage.beginUnitPage}" />
<c:set var="end" value="${resultPage.endUnitPage}" />
<c:set var="max" value="${resultPage.maxPage}" />
<c:set var="unit" value="${resultPage.pageUnit}" />

<style>
.pg a, .pg span { margin:0 4px; text-decoration:none; }
.pg .now { font-weight:bold; text-decoration:underline; }
.pg .disabled { color:#aaa; pointer-events:none; }
</style>

<div class="pg">
  <!-- 처음 / 이전 -->
  <c:choose>
    <c:when test="${curr > 1}">
      <a href="#" data-page="1">« 처음</a>
      <a href="#" data-page="${curr-1}">‹ 이전</a>
    </c:when>
    <c:otherwise>
      <span class="disabled">« 처음</span>
      <span class="disabled">‹ 이전</span>
    </c:otherwise>
  </c:choose>

  <!-- 번호 -->
  <c:forEach var="p" begin="${begin}" end="${end}">
    <c:choose>
      <c:when test="${p == curr}">
        <span class="now">${p}</span>
      </c:when>
      <c:otherwise>
        <a href="#" data-page="${p}">${p}</a>
      </c:otherwise>
    </c:choose>
  </c:forEach>

  <!-- 다음 / 마지막 -->
  <c:choose>
    <c:when test="${curr < max}">
      <a href="#" data-page="${curr+1}">다음 ›</a>
      <a href="#" data-page="${max}">마지막 »</a>
    </c:when>
    <c:otherwise>
      <span class="disabled">다음 ›</span>
      <span class="disabled">마지막 »</span>
    </c:otherwise>
  </c:choose>
</div>
