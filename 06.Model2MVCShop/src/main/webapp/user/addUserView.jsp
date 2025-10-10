<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원가입 | HK Shop</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <!-- Tailwind -->
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

  <!-- AOS / Icons -->
  <link href="https://unpkg.com/aos@2.3.4/dist/aos.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"/>

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>

<body class="min-h-screen bg-gradient-to-b from-gray-900 to-dark-bg text-dark-text">
  <%@ include file="/layout/top.jsp" %>

  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
    <section class="grid lg:grid-cols-2 gap-10 items-start">
      <!-- Left: Intro Visual -->
      <div data-aos="fade-right" class="hidden lg:block">
        <div class="rounded-2xl bg-gradient-to-br from-dark-card to-gray-800 p-10 shadow-2xl shadow-accent/20 sticky top-6">
          <p class="text-sm font-semibold text-accent tracking-widest mb-3">JOIN US</p>
          <h1 class="text-4xl font-extrabold text-white leading-tight mb-4">
            몇 가지 정보만 입력하면<br/>바로 시작할 수 있어요
          </h1>
          <p class="text-gray-300">
            계정을 만들고 주문/배송 조회, 관심상품 관리 등 다양한 기능을 이용해 보세요.
          </p>

          <div class="mt-8 overflow-hidden rounded-xl shadow-2xl group relative">
            <img
              src="https://images.unsplash.com/photo-1512428559087-560fa5ceab42?q=80&w=1600&auto=format&fit=crop"
              alt="가입 환영 이미지"
              class="w-full h-auto object-cover transform transition duration-700 group-hover:scale-105 group-hover:brightness-110"
            />
            <div class="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition duration-500 flex items-center justify-center">
              <span class="text-white font-bold">Welcome to HK Shop</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Sign Up Form -->
      <div data-aos="fade-left" class="w-full">
        <div class="mx-auto max-w-2xl">
          <div class="rounded-2xl bg-dark-card/80 backdrop-blur border border-gray-700 shadow-2xl">
            <div class="px-8 pt-8 pb-6">
              <h2 class="text-2xl font-bold text-white mb-2">회원가입</h2>
              <p class="text-gray-400 text-sm">
                이미 계정이 있으신가요?
                <a href="${cPath}/user/login" class="text-accent hover:underline">로그인</a>
              </p>
            </div>

            <div class="px-8 pb-8">
              <!-- 서버가 기대하는 필드명을 유지 -->
              <form id="signupForm" name="detailForm" method="post" action="${cPath}/user/addUser" class="space-y-6">
                <!-- 아이디 (자동 중복확인) -->
                <div>
                  <label for="userId" class="block text-sm mb-1 text-gray-300">
                    아이디<span class="text-red-400">*</span>
                  </label>
                  <div class="relative">
                    <input type="text" id="userId" name="userId" maxlength="20" autocomplete="off"
                           class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                           placeholder="영문/숫자 조합 권장"/>
                    <!-- AJAX 결과 메시지 -->
                    <small id="idHint" class="absolute left-1 top-[100%] mt-1 text-xs"></small>
                  </div>
                </div>

                <!-- 비밀번호 -->
                <div class="grid sm:grid-cols-2 gap-4">
                  <div>
                    <label for="password" class="block text-sm mb-1 text-gray-300">비밀번호<span class="text-red-400">*</span></label>
                    <input type="password" id="password" name="password" maxlength="10" minlength="6" autocomplete="new-password"
                           class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                           placeholder="6~10자"/>
                  </div>
                  <div>
                    <label for="password2" class="block text-sm mb-1 text-gray-300">비밀번호 확인<span class="text-red-400">*</span></label>
                    <input type="password" id="password2" name="password2" maxlength="10" minlength="6" autocomplete="new-password"
                           class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                           placeholder="다시 입력"/>
                  </div>
                </div>

                <!-- 이름 -->
                <div>
                  <label for="userName" class="block text-sm mb-1 text-gray-300">이름<span class="text-red-400">*</span></label>
                  <input type="text" id="userName" name="userName" maxlength="50"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="이름을 입력하세요"/>
                </div>

                <!-- 주민번호 (선택) -->
                <div>
                  <label for="ssn" class="block text-sm mb-1 text-gray-300">주민번호 (선택)</label>
                  <input type="text" id="ssn" name="ssn" maxlength="13"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="- 제외, 13자리 입력"/>
                  <p class="text-xs text-gray-500 mt-1">예: 9001011234567</p>
                </div>

                <!-- 주소 -->
                <div>
                  <label for="addr" class="block text-sm mb-1 text-gray-300">주소</label>
                  <input type="text" id="addr" name="addr" maxlength="100"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="도로명 주소"/>
                </div>

                <!-- 휴대전화 -->
                <div>
                  <label class="block text-sm mb-1 text-gray-300">휴대전화번호</label>
                  <div class="flex items-center gap-3">
                    <select name="phone1" id="phone1"
                            class="rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-3 py-3 text-sm outline-none">
                      <option value="010">010</option>
                      <option value="011">011</option>
                      <option value="016">016</option>
                      <option value="018">018</option>
                      <option value="019">019</option>
                    </select>
                    <input type="text" name="phone2" id="phone2" maxlength="9"
                           class="flex-1 rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm outline-none"
                           placeholder="앞자리"/>
                    <span class="text-gray-500">-</span>
                    <input type="text" name="phone3" id="phone3" maxlength="9"
                           class="flex-1 rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm outline-none"
                           placeholder="뒷자리"/>
                  </div>
                  <input type="hidden" name="phone" id="phone"/>
                </div>

                <!-- 이메일 -->
                <div>
                  <label for="email" class="block text-sm mb-1 text-gray-300">이메일</label>
                  <input type="text" id="email" name="email" maxlength="100"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="you@example.com"/>
                </div>

                <!-- Actions -->
                <div class="pt-2 flex flex-col sm:flex-row gap-3">
                  <button type="button" id="registerBtn"
                          class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-accent text-white font-semibold shadow-lg shadow-accent/40 hover:bg-teal-600 transition-all disabled:opacity-60 disabled:cursor-not-allowed">
                    <i class="fa-solid fa-user-plus"></i>
                    <span>가입</span>
                  </button>
                  <button type="button" id="cancelBtn"
                          class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg border border-gray-600 text-gray-200 hover:bg-gray-700 transition-all">
                    <i class="fa-regular fa-circle-xmark"></i>
                    <span>입력취소</span>
                  </button>
                </div>
              </form>
            </div>

            <div class="px-8 py-4 bg-gray-900/60 border-t border-gray-700 rounded-b-2xl text-xs text-gray-400">
              가입과 동시에 서비스 이용약관 및 개인정보 처리방침에 동의하게 됩니다.
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

  <!-- 가입/자동 중복확인 스크립트 -->
  <script>
    (function () {
      const $form        = $('#signupForm');
      const $userId      = $('#userId');
      const $password    = $('#password');
      const $password2   = $('#password2');
      const $userName    = $('#userName');
      const $email       = $('#email');
      const $phone1      = $('#phone1');
      const $phone2      = $('#phone2');
      const $phone3      = $('#phone3');
      const $phoneHidden = $('#phone');
      const $registerBtn = $('#registerBtn');
      const $cancelBtn   = $('#cancelBtn');

      // ===== 공통 유틸 =====
      function validateEmail() {
        const v = ($email.val() || '').trim();
        if (v && (v.indexOf('@') < 1 || v.indexOf('.') === -1)) {
          alert('이메일 형식이 아닙니다.');
          $email.focus();
          return false;
        }
        return true;
      }

      function buildPhone() {
        const p2 = ($phone2.val() || '').trim();
        const p3 = ($phone3.val() || '').trim();
        if (p2 && p3) {
          $phoneHidden.val($phone1.val() + '-' + p2 + '-' + p3);
        } else {
          $phoneHidden.val('');
        }
      }

      // ===== ID 자동 중복확인 =====
      const $hint = $('#idHint');
      let dupPending = false; // 중복 요청 방지
      let lastChecked = '';   // 마지막으로 확인한 아이디 (불필요한 호출 방지)

      function setHint(msg, type) {
        // type: 'ok' | 'bad' | 'info'
        const ok   = 'text-teal-400';
        const bad  = 'text-red-400';
        const info = 'text-gray-400';
        $hint.removeClass('text-teal-400 text-red-400 text-gray-400')
             .addClass(type === 'ok' ? ok : type === 'bad' ? bad : info)
             .text(msg || '');
      }

      function parseBoolean(resp) {
    	  console.log("=== [DEBUG] parseBoolean called ===");
    	  console.log("typeof resp:", typeof resp, " | value:", resp);

    	  if (typeof resp === 'boolean') {
    	    console.log("→ boolean detected → return", resp);
    	    return resp;
    	  }
    	  if (typeof resp === 'string') {
    	    const normalized = resp.trim().toLowerCase();
    	    const result = normalized === 'true';
    	    console.log("→ string detected:", normalized, "→ return", result);
    	    return result;
    	  }
    	  try {
    	    const parsed = JSON.parse(resp);
    	    const result = !!parsed;
    	    console.log("→ parsed JSON:", parsed, "→ return", result);
    	    return result;
    	  } catch (e) {
    	    console.warn("→ parse error:", e, "→ fallback to false");
    	    return false;
    	  }
    	}

      // 서버: GET /user/json/checkDuplication/{userId} (true=중복, false=사용가능)
      function checkDupAjax(force) {
        const id = ($userId.val() || '').trim();
        if (!id) { setHint('아이디를 입력해 주세요.', 'info'); return Promise.resolve(false); }

        // 같은 값은 중복 체크 스킵(blur/입력 이벤트 최적화)
        if (!force && id === lastChecked) {
          return Promise.resolve($hint.hasClass('text-teal-400')); // 이전 결과 사용: ok면 사용가능
        }

        if (dupPending) return Promise.resolve(null);

        dupPending = true;
        setHint('확인 중...', 'info');

        return $.ajax({
          url: '${cPath}/user/json/checkDuplication/' + encodeURIComponent(id),
          method: 'GET'
        }).then(function(resp) {
          lastChecked = id;
          const isDup = parseBoolean(resp); // true=중복
          if (isDup) {
            setHint('이미 사용 중인 아이디입니다.', 'bad');
          } else {
            setHint('사용 가능한 아이디입니다.', 'ok');
          }
          return !isDup; // 사용 가능 여부
        }).catch(function() {
          setHint('확인 중 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.', 'bad');
          return false;
        }).always(function() {
          dupPending = false;
        });
      }

      // 입력 중엔 힌트 초기화, 멈춤 후(디바운스) 자동 확인
      let debounceTimer = null;
      $userId.on('input', function(){
        setHint('', 'info');
        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(() => { checkDupAjax(false); }, 500);
      });

      // 포커스 아웃 시 강제 확인
      $userId.on('blur', function(){ if ($userId.val().trim()) checkDupAjax(true); });

      // ===== 제출(onSubmit): 유효성 -> 최종 중복검사 -> 제출 =====
      async function onSubmit() {
        if (!$userId.val().trim())    { alert('아이디는 반드시 입력하셔야 합니다.'); $userId.focus(); return; }
        if (!$password.val().trim())  { alert('패스워드는 반드시 입력하셔야 합니다.'); $password.focus(); return; }
        if (!$password2.val().trim()) { alert('패스워드 확인은 반드시 입력하셔야 합니다.'); $password2.focus(); return; }
        if ($password.val() !== $password2.val()) { alert('비밀번호 확인이 일치하지 않습니다.'); $password2.focus(); return; }
        if (!$userName.val().trim())  { alert('이름은 반드시 입력하셔야 합니다.'); $userName.focus(); return; }
        if (!validateEmail())         { return; }

        // 최종 중복확인 (사용 가능해야 진행)
        const usable = await checkDupAjax(true);
        if (usable !== true) { // false 또는 오류(null)
          if (usable === false) {
            alert('이미 사용 중인 아이디입니다. 다른 아이디를 입력해 주세요.');
          }
          $userId.focus();
          return;
        }

        // 전화번호 hidden 구성 후 제출
        buildPhone();
        $form.trigger('submit');
      }

      // 이벤트 바인딩
      $('#registerBtn').on('click', onSubmit);
      $('#cancelBtn').on('click', function(){ $form[0].reset(); setHint('', 'info'); lastChecked=''; });

      // Enter 키: onSubmit (아이디 칸에서도 Enter 시 최종 검사 후 제출)
      $form.on('keydown', function(e){
        if (e.key === 'Enter') {
          e.preventDefault();
          onSubmit();
        }
      });
    })();
  </script>
</body>
</html>
