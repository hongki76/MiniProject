<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>HK Shop | Dark Mode</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <!-- Tailwind (개발용 CDN: 운영은 빌드된 CSS 권장) -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      darkMode: 'class',
      theme: {
        extend: {
          colors: {
            accent:    '#14b8a6', // Teal 500
            'dark-bg': '#1f2937', // Gray 800
            'dark-card':'#374151', // Gray 700
            'dark-text':'#f3f4f6', // Gray 100
          }
        }
      }
    }
  </script>

  <!-- AOS -->
  <link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
  <!-- Font Awesome (아이콘) -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>
</head>

<body class="min-h-screen text-dark-text bg-dark-bg transition-colors duration-500">

  <!-- Header -->
  <header class="w-full border-b border-gray-700 bg-dark-bg/80 backdrop-blur-md sticky top-0 z-50" data-aos="fade-down">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="flex h-16 items-center justify-between">
        <a href="${cPath}/index.jsp" class="text-2xl font-extrabold tracking-tight text-white">
          HK <span class="text-accent">Shop</span>
        </a>

        <!-- Desktop nav -->
        <nav class="hidden md:flex items-center gap-2 text-sm font-medium">
          <a href="${cPath}/product/getProductList" class="px-4 py-2 hover:text-accent transition-colors">PRODUCT</a>

          <!-- DESKTOP: Orders dropdown (stable) -->
          <c:if test="${not empty sessionScope.user && sessionScope.user.role == 'user'}">
            <div id="orders-desktop" class="relative">
              <!-- trigger -->
              <a href="${cPath}/purchase/getPurchaseList"
                 id="orders-trigger"
                 class="inline-flex items-center gap-2 px-4 py-2 hover:text-accent transition-colors"
                 aria-haspopup="true" aria-expanded="false">
                ORDERS
                <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 transition-transform duration-200" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 10.94l3.71-3.71a.75.75 0 0 1 1.06 1.06l-4.24 4.24a.75.75 0 0 1-1.06 0L5.21 8.29a.75.75 0 0 1 .02-1.08z" clip-rule="evenodd"/>
                </svg>
              </a>
              <!-- menu -->
              <div id="orders-menu"
                   class="absolute left-1/2 -translate-x-1/2 top-full mt-1 w-48 rounded-md shadow-lg bg-dark-card ring-1 ring-black/50
                          invisible opacity-0 translate-y-1 transition-all duration-150 z-50
                          before:content-[''] before:absolute before:-top-2 before:left-0 before:right-0 before:h-3">
                <!-- ↑ before 엘리먼트 = 호버 브릿지 -->
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

        <!-- Mobile hamburger -->
        <button id="menu-btn" class="md:hidden p-2 rounded-md hover:bg-gray-700 focus:ring-2 focus:ring-accent">
          <svg class="h-6 w-6 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16m-7 6h7"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- Mobile menu -->
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

  <!-- Main -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16">
    <!-- Hero -->
    <section class="rounded-xl overflow-hidden bg-gradient-to-r from-gray-900 to-dark-card shadow-2xl shadow-accent/20 mt-8" data-aos="zoom-in">
      <div class="px-8 py-16 md:px-16 flex flex-col md:flex-row items-center gap-10">
        <div class="md:w-1/2">
          <p class="text-sm font-semibold text-accent mb-2 tracking-widest">WELCOME TO HK SHOP</p>
          <h1 class="text-5xl font-extrabold mb-4 leading-tight text-white">
            미니멀리즘이 <span class="text-accent">경험</span>을 완성합니다
          </h1>
          <p class="text-lg mb-8 text-gray-300">
            세련된 디자인과 최고의 퀄리티. 당신의 일상을 업그레이드할 제품들을 만나보세요.
          </p>
          <div class="flex flex-col sm:flex-row gap-4">
            <a href="${cPath}/product/getProductList"
               class="px-8 py-3 bg-accent text-white font-semibold rounded-full shadow-lg shadow-accent/40 hover:bg-teal-600 transition-all">
              모든 상품 탐색
            </a>
            <c:if test="${not empty sessionScope.user && sessionScope.user.role == 'user'}">
              <a href="${cPath}/purchase/getPurchaseList"
                 class="px-8 py-3 border border-gray-500 text-gray-300 font-semibold rounded-full hover:bg-gray-700 transition-colors">
                주문 확인
              </a>
            </c:if>
          </div>
        </div>
        <div class="md:w-1/2 mt-8 md:mt-0">
          <img src="https://ix-marketing.imgix.net/autotagging.png?auto=format,compress&w=1446"
               alt="미니멀 제품 콜라주"
               class="w-full h-auto rounded-xl object-cover shadow-2xl"/>
        </div>
      </div>
    </section>

    <!-- Picks -->
    <section class="mt-20" data-aos="fade-up">
      <h2 class="text-3xl font-bold mb-8 flex items-center gap-3 text-white">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-8 w-8 text-accent" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-4 0a2 2 0 002-2h-4a2 2 0 002 2z"/>
        </svg>
        오늘의 <span class="text-accent">PICK</span>
      </h2>

      <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <!-- 노트북 -->
        <a href="${cPath}/product/getProduct?prodNo=1" class="group block rounded-xl overflow-hidden bg-dark-card shadow-lg hover:-translate-y-2 hover:scale-[1.03] hover:shadow-accent/50 transition duration-300">
          <img src="https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=800&q=80"
               alt="노트북" class="h-48 w-full object-cover group-hover:scale-110 transition-transform duration-500"/>
          <div class="p-4 border-t border-gray-600">
            <div class="font-semibold text-white">울트라북 M1</div>
            <div class="text-sm text-gray-400">최소한의 디자인, 최고의 성능</div>
          </div>
        </a>

        <!-- 패션 (교체 이미지) -->
        <a href="${cPath}/product/getProduct?prodNo=2" class="group block rounded-xl overflow-hidden bg-dark-card shadow-lg hover:-translate-y-2 hover:scale-[1.03] hover:shadow-accent/50 transition duration-300">
          <img src="https://images.unsplash.com/photo-1521334884684-d80222895322?auto=format&fit=crop&w=800&q=80"
               alt="패션" class="h-48 w-full object-cover group-hover:scale-110 transition-transform duration-500"/>
          <div class="p-4 border-t border-gray-600">
            <div class="font-semibold text-white">시그니처 코튼 티셔츠</div>
            <div class="text-sm text-gray-400">정제된 일상의 시작</div>
          </div>
        </a>

        <!-- 백팩 -->
        <a href="${cPath}/product/getProduct?prodNo=3" class="group block rounded-xl overflow-hidden bg-dark-card shadow-lg hover:-translate-y-2 hover:scale-[1.03] hover:shadow-accent/50 transition duration-300">
          <img src="https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80"
               alt="백팩" class="h-48 w-full object-cover group-hover:scale-110 transition-transform duration-500"/>
          <div class="p-4 border-t border-gray-600">
            <div class="font-semibold text-white">트래블 백팩 Pro</div>
            <div class="text-sm text-gray-400">모든 것을 담는 미니멀 수납</div>
          </div>
        </a>

        <!-- 의자 -->
        <a href="${cPath}/product/getProduct?prodNo=4" class="group block rounded-xl overflow-hidden bg-dark-card shadow-lg hover:-translate-y-2 hover:scale-[1.03] hover:shadow-accent/50 transition duration-300">
          <img src="https://images.unsplash.com/photo-1493666438817-866a91353ca9?auto=format&fit=crop&w=800&q=80"
               alt="의자" class="h-48 w-full object-cover group-hover:scale-110 transition-transform duration-500"/>
          <div class="p-4 border-t border-gray-600">
            <div class="font-semibold text-white">덴마크 디자인 체어</div>
            <div class="text-sm text-gray-400">공간의 중심이 되는 라인</div>
          </div>
        </a>
      </div>
    </section>
  </main>

  <!-- Footer -->
  <footer class="mt-20 border-t border-gray-700 py-10 text-sm text-gray-400 bg-gray-900">
    <div class="max-w-7xl mx-auto px-4 flex flex-col md:flex-row justify-between items-center gap-6">
      <div class="flex gap-8">
        <a href="#" class="hover:text-accent transition-colors">About Us</a>
        <a href="#" class="hover:text-accent transition-colors">Support</a>
        <a href="#" class="hover:text-accent transition-colors">Privacy</a>
      </div>
      <div class="flex gap-4 text-gray-500">
        <a href="#" class="hover:text-accent transition-colors" aria-label="Twitter">
          <i class="fa-brands fa-x-twitter text-lg"></i>
        </a>
        <a href="#" class="hover:text-accent transition-colors" aria-label="Instagram">
          <i class="fa-brands fa-instagram text-lg"></i>
        </a>
        <a href="#" class="hover:text-accent transition-colors" aria-label="Facebook">
          <i class="fa-brands fa-facebook-f text-lg"></i>
        </a>
      </div>
    </div>
    <div class="text-center mt-6 text-gray-500">
      © <span id="y"></span> HK Shop. All rights reserved.
    </div>
  </footer>

  <!-- Scripts -->
  <script>
    document.getElementById('y').textContent = new Date().getFullYear();

    // Mobile menu toggle
    document.getElementById('menu-btn').addEventListener('click', () => {
      document.getElementById('menu-panel').classList.toggle('hidden');
    });

    // Mobile ORDERS submenu toggle
    (function(){
      const t = document.getElementById('orders-toggle');
      const m = document.getElementById('orders-submenu');
      const i = document.getElementById('orders-icon');
      if (!t) return;
      t.addEventListener('click', () => {
        const hidden = m.classList.toggle('hidden');
        i.classList.toggle('rotate-180', !hidden);
      });
    })();

    // Desktop ORDERS dropdown (stable)
    (function(){
      const wrap   = document.getElementById('orders-desktop');
      if (!wrap) return;
      const trigger = document.getElementById('orders-trigger');
      const menu    = document.getElementById('orders-menu');
      const arrow   = trigger.querySelector('svg');
      let hideTimer;

      const open = () => {
        clearTimeout(hideTimer);
        menu.classList.remove('invisible','opacity-0','translate-y-1');
        trigger.setAttribute('aria-expanded','true');
        arrow.classList.add('rotate-180');
      };
      const close = () => {
        menu.classList.add('invisible','opacity-0','translate-y-1');
        trigger.setAttribute('aria-expanded','false');
        arrow.classList.remove('rotate-180');
      };

      wrap.addEventListener('mouseenter', open);
      wrap.addEventListener('mouseleave', () => { hideTimer = setTimeout(close, 180); });
      menu.addEventListener('mouseenter', () => clearTimeout(hideTimer));
      menu.addEventListener('mouseleave', () => { hideTimer = setTimeout(close, 180); });
      trigger.addEventListener('focus', open);
      trigger.addEventListener('blur',  () => { hideTimer = setTimeout(close, 180); });
      document.addEventListener('keydown', (e) => { if (e.key === 'Escape') close(); });
    })();
  </script>

  <script src="https://unpkg.com/aos@2.3.4/dist/aos.js"></script>
  <script>AOS.init({ duration: 800, once: true });</script>
</body>
</html>
