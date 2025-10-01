<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- cPath는 index.jsp에서 설정되므로 여기서 다시 설정하지 않습니다. --%>

<header class="w-full border-b border-gray-700 bg-dark-bg/80 backdrop-blur-md sticky top-0 z-50" data-aos="fade-down">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="flex h-16 items-center justify-between">
      <a href="${cPath}/index.jsp" class="text-2xl font-extrabold tracking-tight text-white">
        HK <span class="text-accent">Shop</span>
      </a>

      <nav class="hidden md:flex items-center gap-2 text-sm font-medium">
        <a href="${cPath}/product/getProductList" class="px-4 py-2 hover:text-accent transition-colors">PRODUCT</a>

        <c:if test="${not empty sessionScope.user && sessionScope.user.role == 'user'}">
          <div id="orders-desktop" class="relative">
            <a href="${cPath}/purchase/getPurchaseList"
               id="orders-trigger"
               class="inline-flex items-center gap-2 px-4 py-2 hover:text-accent transition-colors"
               aria-haspopup="true" aria-expanded="false">
              ORDERS
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 transition-transform duration-200" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 10.94l3.71-3.71a.75.75 0 0 1 1.06 1.06l-4.24 4.24a.75.75 0 0 1-1.06 0L5.21 8.29a.75.75 0 0 1 .02-1.08z" clip-rule="evenodd"/>
              </svg>
            </a>
            <div id="orders-menu"
                 class="absolute left-1/2 -translate-x-1/2 top-full mt-1 w-48 rounded-md shadow-lg bg-dark-card ring-1 ring-black/50
                        invisible opacity-0 translate-y-1 transition-all duration-150 z-50
                        before:content-[''] before:absolute before:-top-2 before:left-0 before:right-0 before:h-3">
              <div class="py-1" role="menu" aria-orientation="vertical">
                <a href="${cPath}/purchase/getPurchaseList"
                   class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-accent" role="menuitem">HISTORY</a>
                <a href="${cPath}/purchase/getPurchaseList?type=cancel"
                   class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-accent" role="menuitem">CANCELLATIONS</a>
                <a href="${cPath}/purchase/getPurchaseList?type=return"
                   class="block px-4 py-2 text-sm text-gray-300 hover:bg-gray-700 hover:text-accent" role="menuitem">RETURNS</a>
              </div>
            </div>
          </div>
        </c:if>

        <div class="flex items-center gap-4 pl-2">
          <c:if test="${not empty sessionScope.user}">
            <a href="${cPath}/user/myPage" class="text-gray-400 hover:text-accent transition-colors" aria-label="My Page">
              <i class="fa-regular fa-user h-5 w-5"></i>
            </a>
          </c:if>

          <c:choose>
            <c:when test="${not empty sessionScope.user}">
              <a href="${cPath}/user/logout" class="px-4 py-2 bg-accent text-white font-semibold rounded-lg hover:bg-teal-600 transition-colors">LOGOUT</a>
            </c:when>
            <c:otherwise>
              <a href="${cPath}/user/login" class="px-4 py-2 hover:text-accent transition-colors">LOGIN</a>
            </c:otherwise>
          </c:choose>
        </div>
      </nav>

      <button id="menu-btn" class="md:hidden p-2 rounded-md hover:bg-gray-700 focus:ring-2 focus:ring-accent">
        <svg class="h-6 w-6 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7"/>
        </svg>
      </button>
    </div>
  </div>

  <div id="menu-panel" class="hidden md:hidden border-t border-gray-700 bg-dark-bg/95 px-4 py-3 space-y-2">
    <a href="${cPath}/product/getProductList" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">PRODUCT</a>

    <c:if test="${not empty sessionScope.user && sessionScope.user.role == 'user'}">
      <div class="border-b border-gray-700 pb-1">
        <button id="orders-toggle" class="flex justify-between items-center w-full px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">
          ORDERS
          <i class="fa-solid fa-chevron-down text-xs transition-transform duration-300" id="orders-icon"></i>
        </button>
        <div id="orders-submenu" class="pl-6 pt-1 hidden space-y-1">
          <a href="${cPath}/purchase/getPurchaseList" class="block px-3 py-1 text-sm text-gray-400 hover:bg-gray-700 hover:text-accent rounded">HISTORY</a>
          <a href="${cPath}/purchase/getPurchaseList?type=cancel" class="block px-3 py-1 text-sm text-gray-400 hover:bg-gray-700 hover:text-accent rounded">CANCELLATIONS</a>
          <a href="${cPath}/purchase/getPurchaseList?type=return" class="block px-3 py-1 text-sm text-gray-400 hover:bg-gray-700 hover:text-accent rounded">RETURNS</a>
        </div>
      </div>
    </c:if>

    <c:choose>
      <c:when test="${not empty sessionScope.user}">
        <a href="${cPath}/user/myPage" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">MY PAGE</a>
        <a href="${cPath}/user/logout" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">LOGOUT</a>
      </c:when>
      <c:otherwise>
        <a href="${cPath}/user/login" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">LOGIN</a>
      </c:otherwise>
    </c:choose>
  </div>
</header>