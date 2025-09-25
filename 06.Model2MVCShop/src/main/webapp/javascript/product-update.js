// /javascript/product-update.js
// - updateProduct.jsp 전용: 수정/취소/달력 오픈, 검증, 이미지 미리보기

(function (global, $) {
  "use strict";

  function doSubmit() {
    var $form = $("#detailForm");
    if ($form.length === 0) return;

    // 공통 검증 (있을 때만)
    if (global.FormValidation && !global.FormValidation($form.get(0))) {
      return;
    }

    // 가격 숫자만
    var price = $.trim($("#price").val() || "");
    if (!/^[0-9]+$/.test(price)) {
      alert("가격은 숫자만 입력하세요.");
      $("#price").focus();
      return;
    }

    $form.trigger("submit");
  }

  function goBack() {
    if (global.history && typeof global.history.back === "function") {
      global.history.back();
    } else {
      global.location.href = (global.CONTEXT_PATH || "") + "/product/getProductList";
    }
  }

  $(function () {
    // ===== 수정 / 취소 =====
    $(document).on("click", "#btnUpdate", function (e) {
      e.preventDefault();
      doSubmit();
    });

    $(document).on("click", "#btnCancel", function (e) {
      e.preventDefault();
      goBack();
    });

    // ===== 달력 오픈 (calendar.js 그대로 사용) =====
    $(document).on("click", ".open-calendar", function (e) {
      e.preventDefault();

      var targetKey = $(this).data("target"); // 예: manuDate
      if (!targetKey) return;

      // input 찾기 (id 우선, 없으면 name)
      var $input = $("#" + targetKey);
      if ($input.length === 0) $input = $("[name='" + targetKey + "']");
      if ($input.length === 0) return;

      // form name: data-form > input.closest(form).name > #detailForm.name > 기본
      var $btn = $(this);
      var formName =
        $btn.data("form") ||
        ($input.closest("form").attr("name")) ||
        ($("#detailForm").attr("name")) ||
        "detailForm";

      // calendar.js 기대 형식: "document.form.field"
      var fieldToken = $input.attr("name") || targetKey;
      var ref = "document." + formName + "." + fieldToken;

      // 현재 값 → 숫자만 추출 → YYYYMMDD, 아니면 빈 문자열(오늘 기준)
      var raw  = ($input.val() || "").toString().trim();
      var norm = raw.replace(/\D/g, "");
      if (norm.length !== 8) norm = "";

      if (typeof global.show_calendar === "function") {
        global.show_calendar(ref, norm);
      }
    });

    // ===== 이미지 미리보기 =====
    var $file = $("#uploadFile");
    var $img  = $("#previewImg");

    if ($file.length && $img.length) {
      var originalSrc = $img.attr("data-original") || $img.attr("src");

      $file.on("change", function () {
        var file = this.files && this.files[0];

        if (!file) {
          // 선택 취소 → 원본 복원
          $img.attr("src", originalSrc);
          return;
        }

        // 이미지 타입만 허용
        if (!/^image\//i.test(file.type)) {
          alert("이미지 파일만 선택할 수 있습니다.");
          this.value = "";
          $img.attr("src", originalSrc);
          return;
        }

        // 용량 제한(옵션): 10MB
        var maxBytes = 10 * 1024 * 1024;
        if (file.size > maxBytes) {
          alert("이미지 용량은 10MB 이하여야 합니다.");
          this.value = "";
          $img.attr("src", originalSrc);
          return;
        }

        // 미리보기
        var url = URL.createObjectURL(file);
        $img.attr("src", url).one("load.previewOnce", function () {
          try { URL.revokeObjectURL(url); } catch (e) {}
          $img.off("load.previewOnce");
        });
      });

      // (선택) 원본으로 복원 버튼이 있을 경우
      $(document).on("click", "#btnResetPreview", function (e) {
        e.preventDefault();
        $img.attr("src", originalSrc);
        $file.val("");
      });
    }
	
  }); 
})(window, window.jQuery);
