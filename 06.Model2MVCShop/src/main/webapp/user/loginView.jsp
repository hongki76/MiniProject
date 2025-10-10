<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>로그인 | HK Shop</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <!-- Tailwind (index.jsp와 동일 팔레트) -->
  <script src="https://cdn.tailwindcss.com"></script>
  <script>
    tailwind.config = {
      darkMode: 'class',
      theme: {
        extend: {
          colors: {
            accent:    '#14b8a6',
            'dark-bg': '#1f2937',
            'dark-card':'#374151',
            'dark-text':'#f3f4f6',
          }
        }
      }
    }
  </script>

  <!-- AOS / Icons (선택) -->
  <link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>

  <!-- jQuery (AJAX 로그인) -->
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>

<body class="min-h-screen bg-gradient-to-b from-gray-900 to-dark-bg text-dark-text">
  <%@ include file="/layout/top.jsp" %>

  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <section class="grid lg:grid-cols-2 gap-10 items-center">
      <!-- Left: Intro -->
      <div data-aos="fade-right" class="hidden lg:block">
        <div class="rounded-2xl bg-gradient-to-br from-dark-card to-gray-800 p-10 shadow-2xl shadow-accent/20">
          <p class="text-sm font-semibold text-accent tracking-widest mb-3">WELCOME BACK</p>
          <h1 class="text-4xl font-extrabold text-white leading-tight mb-4">
            다시 만나 반가워요
          </h1>
          <p class="text-gray-300">
            회원 전용 혜택과 주문 내역을 확인하려면 로그인해 주세요.
            아직 회원이 아니라면 간단한 가입으로 다양한 기능을 이용할 수 있어요.
          </p>

          <div class="mt-8 overflow-hidden rounded-xl shadow-2xl group relative">
            <img
              src="https://png.pngtree.com/thumb_back/fh260/background/20220213/pngtree-close-up-of-digital-tablet-with-login-screen-photo-image_29442084.jpg"
              alt="미니멀 제품 콜라주"
              class="w-full h-auto object-cover transform transition duration-700 group-hover:scale-105 group-hover:brightness-110"
            />
            <div class="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition duration-500 flex items-center justify-center">
              <span class="text-white font-bold">Please sign in.</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Login Card -->
      <div data-aos="fade-left" class="w-full">
        <div class="mx-auto max-w-md">
          <div class="rounded-2xl bg-dark-card/80 backdrop-blur border border-gray-700 shadow-2xl">
            <div class="px-8 pt-8 pb-6">
              <h2 class="text-2xl font-bold text-white mb-2">로그인</h2>
              <p class="text-gray-400 text-sm">
                계정이 없으신가요? <a href="${cPath}/user/addUser" class="text-accent hover:underline">회원가입</a>
              </p>
            </div>

            <div class="px-8 pb-8">
              <form id="loginForm" class="space-y-5" onsubmit="return false;">
                <!-- ID -->
                <div>
                  <label for="userId" class="block text-sm mb-1 text-gray-300">아이디</label>
                  <input
                    type="text"
                    id="userId"
                    name="userId"
                    maxlength="50"
                    autocomplete="username"
                    class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                    placeholder="아이디를 입력하세요"
                  />
                </div>

                <!-- Password -->
                <div>
                  <label for="password" class="block text-sm mb-1 text-gray-300">비밀번호</label>
                  <input
                    type="password"
                    id="password"
                    name="password"
                    maxlength="50"
                    autocomplete="current-password"
                    class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                    placeholder="비밀번호를 입력하세요"
                  />
                </div>

                <!-- Actions -->
                <div class="pt-2 flex flex-col gap-3">
                  <button
                    id="loginBtn"
                    class="w-full inline-flex items-center justify-center gap-2 px-4 py-3 rounded-lg bg-accent text-white font-semibold shadow-lg shadow-accent/40 hover:bg-teal-600 transition-all disabled:opacity-60 disabled:cursor-not-allowed"
                  >
                    <i class="fa-solid fa-right-to-bracket"></i>
                    <span>로그인</span>
                  </button>

                  <a
                    id="signupBtn"
                    href="${cPath}/user/addUser"
                    class="w-full inline-flex items-center justify-center gap-2 px-4 py-3 rounded-lg border border-gray-600 text-gray-200 hover:bg-gray-700 transition-all"
                  >
                    <i class="fa-regular fa-user"></i>
                    <span>회원가입</span>
                  </a>
                </div>
              </form>
            </div>

            <div class="px-8 py-4 bg-gray-900/60 border-t border-gray-700 rounded-b-2xl text-xs text-gray-400">
              비밀번호를 잊으셨나요? <span class="text-gray-300">관리자에게 문의하세요.</span>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <%@ include file="/layout/footer.jsp" %>

  <!-- AOS -->
  <script src="https://unpkg.com/aos@2.3.4/dist/aos.js"></script>
  <script>AOS.init({ duration: 800, once: true });</script>

  <!-- 로그인 스크립트 -->
  <script>
    (function () {
      const $loginBtn = $('#loginBtn');
      const $userId   = $('#userId');
      const $pw       = $('#password');

      // 초기 포커스
      $userId.focus();

      // 엔터 제출
      $(document).on('keydown', function (e) {
        if (e.key === 'Enter') doLogin();
      });

      // 버튼 클릭
      $loginBtn.on('click', function () { doLogin(); });

      let submitting = false;
      function setSubmitting(on) {
        submitting = on;
        $loginBtn.prop('disabled', on);
      }

      function doLogin() {
        if (submitting) return;
        const id = $userId.val().trim();
        const pw = $pw.val().trim();

        if (!id) { alert('ID 를 입력하지 않으셨습니다.'); $userId.focus(); return; }
        if (!pw) { alert('패스워드를 입력하지 않으셨습니다.'); $pw.focus(); return; }

        setSubmitting(true);

        $.ajax({
          url: '${cPath}/user/json/login',
          method: 'POST',
          dataType: 'json',
          headers: { 'Accept': 'application/json', 'Content-Type': 'application/json' },
          data: JSON.stringify({ userId: id, password: pw }),
          success: function (json) {
            if (json && json.userId) {
              window.location.replace('${cPath}/index.jsp');
            } else {
              alert('아이디 또는 패스워드를 확인하시고 다시 로그인 해주세요.');
            }
          },
          error: function (xhr) {
            if (xhr.status === 401 || xhr.status === 403) {
              alert('아이디 또는 패스워드가 올바르지 않습니다.');
            } else {
              alert('로그인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
            }
          },
          complete: function () {
            setSubmitting(false);
          }
        });
      }
    })();
  </script>
</body>
</html>
