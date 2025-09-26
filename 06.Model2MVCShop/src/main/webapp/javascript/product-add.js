// /javascript/product-add.js  (기존 기능 + 미리보기/삭제 취합)
(function (global, $) {
  "use strict";

  // ===== 유틸 =====
  function fmtBytes(n) {
    if (n === undefined || n === null) return "";
    var u = ["B", "KB", "MB", "GB"], i = 0, v = n;
    while (v >= 1024 && i < u.length - 1) { v /= 1024; i++; }
    return (Math.round(v * 10) / 10) + " " + u[i];
  }
  function isImage(f) { return /^image\//i.test(f.type); }

  // DataTransfer 지원 여부
  function dtSupported() {
    try { return typeof DataTransfer !== "undefined" && new DataTransfer(); }
    catch (e) { return false; }
  }
  // FileList 재구성 (keepIndexes만 남김)
  function rebuildFileList($input, keepIndexes) {
    var input = $input.get(0);
    var supported = dtSupported();
    if (!supported) {
      // 지원 안 하면 전체 비우기만 가능
      input.value = "";
      return;
    }
    var dt = new DataTransfer();
    var fs = input.files;
    keepIndexes.forEach(function (i) { if (fs[i]) dt.items.add(fs[i]); });
    input.files = dt.files;
  }

  // ===== 제출/리셋 =====
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
    renderList(); // 미리보기 초기화
  }

  // ===== 달력 버튼 =====
  function bindCalendarOpen() {
    $(document).on("click", ".open-calendar", function (e) {
      e.preventDefault();

      var targetKey = $(this).data("target"); // ex) manuDate
      if (!targetKey) return;

      var $input = $("#" + targetKey);
      if ($input.length === 0) $input = $("[name='" + targetKey + "']");
      if ($input.length === 0) {
        console.warn("[calendar] target input not found:", targetKey);
        return;
      }

      var $btn = $(this);
      var formName =
        $btn.data("form") ||
        ($input.closest("form").attr("name")) ||
        ($("#detailForm").attr("name")) ||
        "detailForm";

      var fieldToken = $input.attr("name") || targetKey;
      var ref = "document." + formName + "." + fieldToken;

      var raw = ($input.val() || "").toString().trim();
      var norm = raw.replace(/\D/g, "");
      if (norm.length !== 8) norm = "";

      if (typeof global.show_calendar === "function") {
        global.show_calendar(ref, norm);
      } else {
        console.warn("[calendar] show_calendar is not loaded yet.");
      }
    });
  }

  // ===== 파일 미리보기/삭제 =====
  var $fileInput, $previewGrid, $fileSummary, $btnClear;

  function renderList() {
    if (!$fileInput || $fileInput.length === 0) return;
    var files = $fileInput.get(0).files;

    // 요약
    if (!files || files.length === 0) {
      if ($fileSummary) $fileSummary.hide().empty();
      if ($previewGrid) $previewGrid.empty();
      return;
    }

    var total = 0, nonImage = false;
    $.each(files, function (_, f) {
      total += f.size;
      if (!isImage(f)) nonImage = true;
    });

    if ($fileSummary) {
      $fileSummary
        .show()
        .html(
          "선택 " + files.length + "개 · 총 " + fmtBytes(total) +
          (nonImage ? ' <span class="badge warn" style="margin-left:6px;">일부는 이미지가 아님(미리보기 없음)</span>' : "")
        );
    }

    // 카드 렌더
    if ($previewGrid) $previewGrid.empty();
    $.each(files, function (idx, file) {
      var $card = $('<div class="file-card"></div>');

      if (isImage(file)) {
        var url = URL.createObjectURL(file);
        var $img = $('<img class="file-thumb" alt="">').attr("alt", file.name).attr("src", url);
        $img.on("load", function () { URL.revokeObjectURL(url); });
        $card.append($img);
      } else {
        var $ph = $('<div class="file-thumb" style="display:grid;place-items:center;font-size:12px;color:#999;">미리보기 없음</div>');
        $card.append($ph);
      }

      var $meta = $('<div class="file-meta"></div>')
        .append('<div title="'+file.name+'">'+file.name+'</div>')
        .append('<div>'+fmtBytes(file.size)+' · '+(file.type || "unknown")+'</div>');
      $card.append($meta);

      var $actions = $('<div class="file-actions"></div>');
      var $badge = $('<span class="badge"></span>').text("#" + (idx + 1));
      var $remove = $('<button type="button" class="btn-mini">제거</button>');
      $remove.on("click", function () {
        var keep = [];
        var len = $fileInput.get(0).files.length;
        for (var i = 0; i < len; i++) if (i !== idx) keep.push(i);
        rebuildFileList($fileInput, keep);
        renderList();
      });
      $actions.append($badge, $remove);
      $card.append($actions);

      if ($previewGrid) $previewGrid.append($card);
    });
  }

  function bindFiles() {
    $fileInput   = $("#productFile");
    $previewGrid = $("#filePreview");
    $fileSummary = $("#fileSummary");
    $btnClear    = $("#btnClearFiles");

    if ($fileInput.length) {
      $fileInput.on("change", renderList);
    }
    if ($btnClear.length) {
      $btnClear.on("click", function () {
        // 전체 지우기
        var input = $fileInput.get(0);
        if (dtSupported()) {
          var dt = new DataTransfer();
          input.files = dt.files;
        } else {
          input.value = "";
        }
        renderList();
      });
    }
  }

  // ===== 초기 바인딩 =====
  $(function () {
    $("#btnSubmit").on("click", submitForm);
    $("#btnReset").on("click", resetForm);

    bindCalendarOpen();
    bindFiles();
  });

})(window, window.jQuery);
