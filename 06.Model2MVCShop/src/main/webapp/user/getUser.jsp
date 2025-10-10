<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="cPath" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>회원정보 | HK Shop</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>

  <!-- Tailwind (addUserView.jsp와 동일 팔레트) -->
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
      <!-- Left: Visual / Intro (동일 톤) -->
      <div data-aos="fade-right" class="hidden lg:block">
        <div class="rounded-2xl bg-gradient-to-br from-dark-card to-gray-800 p-10 shadow-2xl shadow-accent/20 sticky top-6">
          <p class="text-sm font-semibold text-accent tracking-widest mb-3">MY ACCOUNT</p>
          <h1 class="text-4xl font-extrabold text-white leading-tight mb-4">
            내 계정 정보를<br/>한눈에 확인하세요
          </h1>
          <p class="text-gray-300">
            가입 정보와 연락처, 이메일, 가입일을 확인하고 필요하면 즉시 수정할 수 있어요.
          </p>

          <div class="mt-8 overflow-hidden rounded-xl shadow-2xl group relative">
            <img
              src="https://images.unsplash.com/photo-1512428559087-560fa5ceab42?q=80&w=1600&auto=format&fit=crop"
              alt="계정 정보 이미지"
              class="w-full h-auto object-cover transform transition duration-700 group-hover:scale-105 group-hover:brightness-110"
            />
            <div class="absolute inset-0 bg-black/30 opacity-0 group-hover:opacity-100 transition duration-500 flex items-center justify-center">
              <span class="text-white font-bold">HK Shop Account</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: User Detail Card -->
      <div data-aos="fade-left" class="w-full">
        <div class="mx-auto max-w-2xl">
          <div class="rounded-2xl bg-dark-card/80 backdrop-blur border border-gray-700 shadow-2xl">
            <!-- Header -->
            <div class="px-8 pt-8 pb-6">
              <h2 class="text-2xl font-bold text-white mb-2">회원정보</h2>
              <p class="text-gray-400 text-sm">
                정보가 바뀌었나요?
                <a href="${cPath}/user/updateUser?userId=${user.userId}" class="text-accent hover:underline">바로 수정</a>
              </p>
            </div>

            <!-- Content -->
            <div class="px-8 pb-8">
              <div class="grid grid-cols-1 gap-5">
                <!-- 아이디 -->
                <div class="flex items-start gap-4">
                  <div class="flex-shrink-0">
                    <i class="fa-solid fa-id-card text-accent"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-400">아이디</p>
                    <p class="text-base font-semibold text-white break-all">${user.userId}</p>
                  </div>
                </div>

                <!-- 이름 -->
                <div class="flex items-start gap-4">
                  <div class="flex-shrink-0">
                    <i class="fa-solid fa-user text-accent"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-400">이름</p>
                    <p class="text-base font-semibold text-white break-all">${user.userName}</p>
                  </div>
                </div>

                <!-- 주소 -->
                <div class="flex items-start gap-4">
                  <div class="flex-shrink-0">
                    <i class="fa-solid fa-location-dot text-accent"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-400">주소</p>
                    <p class="text-base font-semibold text-white break-words whitespace-pre-line">
                      <c:out value="${user.addr}" />
                    </p>
                  </div>
                </div>

                <!-- 휴대전화번호 -->
                <div class="flex items-start gap-4">
                  <div class="flex-shrink-0">
                    <i class="fa-solid fa-phone text-accent"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-400">휴대전화번호</p>
                    <p class="text-base font-semibold text-white break-all">
                      <c:out value="${empty user.phone ? '' : user.phone}" />
                    </p>
                  </div>
                </div>

                <!-- 이메일 -->
                <div class="flex items-start gap-4">
                  <div class="flex-shrink-0">
                    <i class="fa-solid fa-envelope text-accent"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-400">이메일</p>
                    <p class="text-base font-semibold text-white break-all">
                      <c:out value="${user.email}" />
                    </p>
                  </div>
                </div>

                <!-- 가입일자 -->
                <div class="flex items-start gap-4">
                  <div class="flex-shrink-0">
                    <i class="fa-regular fa-calendar-check text-accent"></i>
                  </div>
                  <div class="flex-1">
                    <p class="text-xs text-gray-400">가입일자</p>
                    <p class="text-base font-semibold text-white break-all">
                      <c:out value="${user.regDate}" />
                    </p>
                  </div>
                </div>
              </div>

              <!-- Actions -->
              <div class="pt-8 flex flex-col sm:flex-row gap-3">
                <button type="button" id="editBtn"
                        class="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3 rounded-lg bg-accent text-white font-semibold shadow-lg shadow-accent/40 hover:bg-teal-600 transition-all">
                  <i class="fa-regular fa-pen-to-square"></i>
                  <span>수정</span>
                </button>
              </div>
            </div>

            <!-- Footer -->
            <div class="px-8 py-4 bg-gray-900/60 border-t border-gray-700 rounded-b-2xl text-xs text-gray-400">
              개인 정보는 안전하게 보호됩니다. 변경 사항은 즉시 적용됩니다.
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

  <!-- 버튼 동작 스크립트 (addUserView.jsp 스타일과 동일한 방식) -->
  <script>
    (function(){
      const $back  = $('#backBtn');
      const $edit  = $('#editBtn');
      const userId = '${user.userId}';
      const cPath  = '${cPath}';

      $back.on('click', function(){
        // 기존 페이지에서 하던 "확인" 동작: 뒤로가기
        if (history.length > 1) {
          history.back();
        } else {
          // 히스토리가 없을 때는 마이페이지/메인 등으로 이동(보호)
          location.href = cPath ? (cPath + '/') : '/';
        }
      });

      $edit.on('click', function(){
        // 기존 "수정" 링크와 동일한 이동
        location.href = cPath + '/user/updateUser?userId=' + encodeURIComponent(userId);
      });
    })();
  </script>
</body>
</html>
