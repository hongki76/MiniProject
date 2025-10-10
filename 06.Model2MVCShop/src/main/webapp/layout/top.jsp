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
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 transition-transform duration-200" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
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
            <a href="${cPath}/user/getUser?userId=${sessionScope.user.userId}" class="text-gray-400 hover:text-accent transition-colors" aria-label="My Page">
              <i class="fa-regular fa-user h-5 w-5" aria-hidden="true"></i>
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

      <button id="menu-btn" class="md:hidden p-2 rounded-md hover:bg-gray-700 focus:ring-2 focus:ring-accent" aria-controls="menu-panel" aria-expanded="false">
        <svg class="h-6 w-6 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7"/>
        </svg>
        <span class="sr-only">메뉴 열기</span>
      </button>
    </div>
  </div>

  <div id="menu-panel" class="hidden md:hidden border-t border-gray-700 bg-dark-bg/95 px-4 py-3 space-y-2">
    <a href="${cPath}/product/getProductList" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">PRODUCT</a>

    <c:if test="${not empty sessionScope.user && sessionScope.user.role == 'user'}">
      <div class="border-b border-gray-700 pb-1">
        <button id="orders-toggle" class="flex justify-between items-center w-full px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent" aria-controls="orders-submenu" aria-expanded="false">
          ORDERS
          <i class="fa-solid fa-chevron-down text-xs transition-transform duration-300" id="orders-icon" aria-hidden="true"></i>
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
        <a href="${cPath}/user/getUser?userId=${sessionScope.user.userId}" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">MY PAGE</a>
        <a href="${cPath}/user/logout" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">LOGOUT</a>
      </c:when>
      <c:otherwise>
        <a href="${cPath}/user/login" class="block px-3 py-2 rounded text-gray-300 hover:bg-gray-700 hover:text-accent">LOGIN</a>
      </c:otherwise>
    </c:choose>
  </div>
</header>

<!-- ▼ 공통 네비게이션 스크립트: 모든 페이지에서 동작 -->
<script>
(function () {
  // 안전 가드
  const $ = (sel) => document.querySelector(sel);

  // 1) 모바일 메뉴 토글
  const menuBtn   = $('#menu-btn');
  const menuPanel = $('#menu-panel');
  if (menuBtn && menuPanel) {
    menuBtn.addEventListener('click', () => {
      const willHide = !menuPanel.classList.toggle('hidden'); // toggle 후 hidden 여부
      // aria-expanded 업데이트
      menuBtn.setAttribute('aria-expanded', String(!willHide));
    });
  }

  // 2) 모바일 ORDERS 서브메뉴 토글(로그인 사용자 전용)
  const ordersToggle  = $('#orders-toggle');
  const ordersSubmenu = $('#orders-submenu');
  const ordersIcon    = $('#orders-icon');
  if (ordersToggle && ordersSubmenu) {
    ordersToggle.addEventListener('click', () => {
      const hidden = ordersSubmenu.classList.toggle('hidden');
      ordersToggle.setAttribute('aria-expanded', String(!hidden));
      if (ordersIcon) ordersIcon.classList.toggle('rotate-180', !hidden);
    });
  }

  // 3) 데스크탑 ORDERS 드롭다운(로그인 사용자 전용)
  const wrap    = $('#orders-desktop');
  const trigger = $('#orders-trigger');
  const menu    = $('#orders-menu');
  const arrow   = trigger ? trigger.querySelector('svg') : null;

  if (wrap && trigger && menu) {
    let hideTimer;
    const open = () => {
      clearTimeout(hideTimer);
      menu.classList.remove('invisible','opacity-0','translate-y-1');
      trigger.setAttribute('aria-expanded','true');
      arrow && arrow.classList.add('rotate-180');
    };
    const close = () => {
      menu.classList.add('invisible','opacity-0','translate-y-1');
      trigger.setAttribute('aria-expanded','false');
      arrow && arrow.classList.remove('rotate-180');
    };

    wrap.addEventListener('mouseenter', open);
    wrap.addEventListener('mouseleave', () => { hideTimer = setTimeout(close, 180); });
    menu.addEventListener('mouseenter', () => clearTimeout(hideTimer));
    menu.addEventListener('mouseleave', () => { hideTimer = setTimeout(close, 180); });

    trigger.addEventListener('focus', open);
    trigger.addEventListener('blur',  () => { hideTimer = setTimeout(close, 180); });
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });
  }
})();
</script>
