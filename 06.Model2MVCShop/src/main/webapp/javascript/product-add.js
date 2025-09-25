// /javascript/product-add.js (핵심 부분만 교체)
(function (global, $) {
  "use strict";

  function submitForm() {
    var $form = $("#detailForm");
    if ($form.length === 0) return;

    if (global.FormValidation && !global.FormValidation($form.get(0))) {
      return;
    }

    var price = $.trim($form.find("[name='price']").val() || "");
    if (!/^[0-9]+$/.test(price)) {
      alert("가격은 숫자만 입력하세요.");
      $form.find("[name='price']").focus();
      return;
    }
    $form.trigger("submit");
  }

  function resetForm() {
    var $form = $("#detailForm");
    if ($form.length) $form.get(0).reset();
  }

  $(function () {
    $("#btnSubmit").on("click", submitForm);
    $("#btnReset").on("click", resetForm);

    // 달력 열기: 값은 YYYYMMDD로 정규화해 calendar.js에 전달
    $(document).on("click", ".open-calendar", function (e) {
      e.preventDefault(); // 혹시 모를 submit/네비게이션 방지

      // 1) target 식별
      var targetKey = $(this).data("target"); // 보통 "manuDate"
      if (!targetKey) return;

      // 2) 입력 요소 찾기: id 우선, 없으면 name으로
      var $input = $("#" + targetKey);
      if ($input.length === 0) {
        $input = $("[name='" + targetKey + "']");
      }
      if ($input.length === 0) {
        console.warn("[calendar] target input not found:", targetKey);
        return;
      }

      // 3) form 이름 결정: data-form > 가장 가까운 form > #detailForm > 기본값
      var $btn = $(this);
      var formName =
        $btn.data("form") ||
        ($input.closest("form").attr("name")) ||
        ($("#detailForm").attr("name")) ||
        "detailForm";

      // 4) calendar.js가 기대하는 참조 문자열 구성 (문자 그대로)
      //    ex) "document.detailForm.manuDate"
      var fieldToken = $input.attr("name") || targetKey; // name 우선
      var ref = "document." + formName + "." + fieldToken;

      // 5) 값 정규화: YYYY-MM-DD / YYYY/MM/DD / 기타 → 숫자만 남겨 YYYYMMDD
      var raw = ($input.val() || "").toString().trim();
      var norm = raw.replace(/\D/g, "");
      if (norm.length !== 8) norm = ""; // 비정상/빈값이면 오늘 기준으로 열기

      // 6) calendar.js 호출
      if (typeof global.show_calendar === "function") {
        global.show_calendar(ref, norm);
      } else {
        console.warn("[calendar] show_calendar is not loaded yet.");
      }
    });
  });
})(window, window.jQuery);
