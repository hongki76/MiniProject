<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원 정보 수정 | HK Shop</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <!-- Tailwind (getUser.jsp와 동일 팔레트) -->
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
      <!-- Left Visual -->
      <div data-aos="fade-right" class="hidden lg:block">
        <div class="rounded-2xl bg-gradient-to-br from-dark-card to-gray-800 p-10 shadow-2xl shadow-accent/20 sticky top-6">
          <p class="text-sm font-semibold text-accent tracking-widest mb-3">EDIT PROFILE</p>
          <h1 class="text-4xl font-extrabold text-white leading-tight mb-4">
            정보를 최신으로 유지하세요
          </h1>
          <p class="text-gray-300">
            이름, 연락처, 이메일, 주소를 수정하고 저장할 수 있습니다.
          </p>

          <div class="mt-8 overflow-hidden rounded-xl shadow-2xl group relative">
            <img
              src="https://images.unsplash.com/photo-1512428559087-560fa5ceab42?q=80&w=1600&auto=format&fit=crop"
              alt="프로필 수정 이미지"
              class="w-full h-auto object-cover transform transition duration-700 group-hover:scale-105 group-hover:brightness-110"
            />
            <div class="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition duration-500 flex items-center justify-center">
              <span class="text-white font-bold">Update Your Info</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Update Form -->
      <div data-aos="fade-left" class="w-full">
        <div class="mx-auto max-w-2xl">
          <div class="rounded-2xl bg-dark-card/80 backdrop-blur border border-gray-700 shadow-2xl">
            <!-- Header -->
            <div class="px-8 pt-8 pb-6">
              <h2 class="text-2xl font-bold text-white mb-2">회원정보수정</h2>
              <p class="text-gray-400 text-sm">
                변경 후 <span class="text-accent font-semibold">저장</span>을 눌러 주세요.
              </p>
            </div>

            <!-- Form -->
            <div class="px-8 pb-8">
              <form id="updateForm" name="detailForm" method="post" action="${cPath}/user/updateUser" class="space-y-6">
                <input type="hidden" name="userId" value="${user.userId}" />
                <input type="hidden" name="phone" id="phone" />

                <!-- 아이디 (읽기전용) -->
                <div>
                  <label class="block text-sm mb-1 text-gray-300">아이디</label>
                  <div class="w-full rounded-lg bg-gray-800/70 border border-gray-600 px-4 py-3 text-sm text-gray-400">
                    <c:out value="${user.userId}" />
                  </div>
                </div>

                <!-- 이름 -->
                <div>
                  <label for="userName" class="block text-sm mb-1 text-gray-300">이름<span class="text-red-400">*</span></label>
                  <input type="text" id="userName" name="userName" maxlength="50"
                         value="${user.userName}"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="이름을 입력하세요"/>
                </div>

                <!-- 주소 -->
                <div>
                  <label for="addr" class="block text-sm mb-1 text-gray-300">주소</label>
                  <input type="text" id="addr" name="addr" maxlength="100"
                         value="${user.addr}"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="도로명 주소"/>
                </div>

                <!-- 휴대전화 -->
                <div>
                  <label class="block text-sm mb-1 text-gray-300">휴대전화번호</label>
                  <div class="flex items-center gap-3">
                    <select name="phone1" id="phone1"
                            class="rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-3 py-3 text-sm outline-none">
                      <option value="010" ${ ! empty user.phone1 && user.phone1 == "010" ? "selected" : "" }>010</option>
                      <option value="011" ${ ! empty user.phone1 && user.phone1 == "011" ? "selected" : "" }>011</option>
                      <option value="016" ${ ! empty user.phone1 && user.phone1 == "016" ? "selected" : "" }>016</option>
                      <option value="018" ${ ! empty user.phone1 && user.phone1 == "018" ? "selected" : "" }>018</option>
                      <option value="019" ${ ! empty user.phone1 && user.phone1 == "019" ? "selected" : "" }>019</option>
                    </select>
                    <input type="text" name="phone2" id="phone2" maxlength="9"
                           value="${ ! empty user.phone2 ? user.phone2 : ''}"
                           class="flex-1 rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm outline-none"
                           placeholder="앞자리"/>
                    <span class="text-gray-500">-</span>
                    <input type="text" name="phone3" id="phone3" maxlength="9"
                           value="${ ! empty user.phone3 ? user.phone3 : ''}"
                           class="flex-1 rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm outline-none"
                           placeholder="뒷자리"/>
                  </div>
                </div>

                <!-- 이메일 -->
                <div>
                  <label for="email" class="block text-sm mb-1 text-gray-300">이메일</label>
                  <input type="text" id="email" name="email" maxlength="100"
                         value="${user.email}"
                         class="w-full rounded-lg bg-gray-800/70 border border-gray-600 focus:border-accent focus:ring-2 focus:ring-accent/40 px-4 py-3 text-sm placeholder-gray-500 outline-none"
                         placeholder="you@example.com"/>
                </div>

                <!-- Actions (취소 버튼 제거) -->
                <div class="pt-2">
                  <button type="button" id="updateBtn"
                          class="inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-accent text-white font-semibold shadow-lg shadow-accent/40 hover:bg-teal-600 transition-all">
                    <i class="fa-regular fa-floppy-disk"></i>
                    <span>저장</span>
                  </button>
                </div>
              </form>
            </div>

            <!-- Footer -->
            <div class="px-8 py-4 bg-gray-900/60 border-t border-gray-700 rounded-b-2xl text-xs text-gray-400">
              수정 사항은 저장 후 즉시 반영됩니다.
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

  <!-- 업데이트 스크립트 -->
  <script>
    (function () {
      const $form     = $('#updateForm');
      const $userName = $('#userName');
      const $email    = $('#email');
      const $phone1   = $('#phone1');
      const $phone2   = $('#phone2');
      const $phone3   = $('#phone3');
      const $phoneH   = $('#phone');
      const $btn      = $('#updateBtn');

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
          $phoneH.val($phone1.val() + '-' + p2 + '-' + p3);
        } else {
          $phoneH.val('');
        }
      }

      function onSubmit() {
        if (!($userName.val() || '').trim()) { alert('이름은 반드시 입력하셔야 합니다.'); $userName.focus(); return; }
        if (!validateEmail()) return;
        buildPhone();
        $form.attr('method','POST').attr('action','${cPath}/user/updateUser').trigger('submit');
      }

      // 저장 버튼
      $btn.on('click', onSubmit);

      // Enter로도 저장
      $form.on('keydown', function(e){
        if (e.key === 'Enter') {
          e.preventDefault();
          onSubmit();
        }
      });

      // 이메일 즉시 검증(선택)
      $email.on('change', validateEmail);
    })();
  </script>
</body>
</html>
