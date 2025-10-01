/* CommonScript-jq.js (jQuery 버전)
 * - 기존 FormValidation(form) 시그니처 유지
 * - 속성명 호환: required|data-required, filter, maxLength, minLength,
 *               num, fromNum, toNum, format, char, valCheck, fieldTitle
 * - 라디오 그룹, 바이트 길이(한글 2바이트) 등 원 로직 반영
 */

(function (global, $) {
  "use strict";

  // ====== 공용 유틸 ======
  function trimStr(s) {
    if (s == null) return "";
    return $.trim(String(s));
  }

  function byteLength(str) {
    // escape 기반 대신, URI 인코딩 길이를 이용해 2바이트 문자를 2로 가깝게 취급
    // %XX 시퀀스는 바이트 1개로 계산, 일반 ASCII는 1
    var enc = encodeURIComponent(str);
    // enc에서 '%..'은 3문자이므로 실제 바이트로 환산
    var bytes = 0;
    for (var i = 0; i < enc.length; i++) {
      if (enc[i] === "%") {
        bytes++;
        i += 2; // %XX 건너뛰기
      } else {
        bytes++;
      }
    }
    return bytes;
  }

  function isDigitsOnly(s) {
    return /^[0-9]+$/.test(s);
  }

  function numberCheck(val, allowChars) {
    // allowChars 예: ""(숫자만), "-"(부호), ".-"(실수)
    var pattern = "0-9";
    if (allowChars && allowChars.indexOf("-") > -1) pattern += "\\-";
    if (allowChars && allowChars.indexOf(".") > -1) pattern += "\\.";
    var re = new RegExp("^[" + pattern + "]+$");
    return re.test(val);
  }

  function formatMask(value, mask) {
    // mask: '9' 숫자, 's' 비숫자, 그 외는 리터럴로 동일해야 함
    if (!value || !mask || value.length !== mask.length) return false;
    for (var i = 0; i < value.length; i++) {
      var m = mask[i], ch = value[i];
      if (m === "9") {
        if (!/^[0-9]$/.test(ch)) return false;
      } else if (m === "s") {
        if (/^[0-9]$/.test(ch)) return false;
      } else {
        if (ch !== m) return false;
      }
    }
    return true;
  }

  function inRangeNumeric(val, fromNum, toNum) {
    if (val === "" || isNaN(val)) return true;
    var n = Number(val);
    if (fromNum != null && fromNum !== "" && !isNaN(fromNum) && n < Number(fromNum)) return false;
    if (toNum != null && toNum !== "" && !isNaN(toNum) && n > Number(toNum)) return false;
    return true;
  }

  function numLengthCheck(value, intLen, decLen) {
    // "num"이 "정수자리.소수자리" 형태일 때 길이 제한
    if (!value) return true;
    if (!numberCheck(value, ".-")) return false;
    var parts = String(value).split(".");
    var isNeg = parts[0].startsWith("-");
    var intPart = isNeg ? parts[0].slice(1) : parts[0];
    var decPart = parts[1] || "";
    if (intLen != null && String(intPart).length > Number(intLen)) return false;
    if (decLen != null && String(decPart).length > Number(decLen)) return false;
    return true;
  }

  // ====== 개별 규칙 ======
  function validateRequired($field, value, fieldTitle) {
    var hasRequired =
      $field.attr("required") != null ||
      $field.data("required") != null ||
      $field.prop("required") === true;
    if (!hasRequired) return true;
    if ($field.is(":radio")) {
      // 같은 name 라디오 중 하나 이상 체크
      var name = $field.attr("name");
      return $field.closest("form").find("input[type=radio][name='" + name + "']:checked").length > 0
        || (alert(fieldTitle + " is a required field."), false);
    }
    if (value === "") {
      alert(fieldTitle + " is a required field.");
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  function validateFilter($field, value, fieldTitle) {
    var filter = $field.attr("filter");
    if (!filter || value === "") return true;
    // filter에 정규식 리터럴/문자열 모두 올 수 있었던 과거 호환
    var re;
    try {
      // "/.../" 형태면 슬래시 제거
      if (filter.startsWith("/") && filter.endsWith("/")) {
        re = new RegExp(filter.slice(1, -1));
      } else {
        re = new RegExp(filter);
      }
    } catch (e) {
      // 필터 파싱 실패 시 무시
      return true;
    }
    if (re.test(value)) {
      alert("You can't enter characters as below in " + fieldTitle + " field.\n\n" + filter);
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  function validateMaxMinLength($field, value, fieldTitle) {
    var maxL = $field.attr("maxLength");
    var minL = $field.attr("minLength");
    if (value === "") return true;
    var bytes = byteLength(value);
    if (maxL != null && Number(maxL) > 0 && bytes > Number(maxL)) {
      alert(fieldTitle + " has over max length.\n\nMax length of this field is (in case of English) : " + maxL);
      $field.trigger("focus");
      return false;
    }
    if (minL != null && Number(minL) > 0 && bytes < Number(minL)) {
      alert(fieldTitle + " has under min length.\n\nMin length of this field is (in case of English) : " + minL);
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  function validateNum($field, value, fieldTitle) {
    var num = $field.attr("num");
    if (!num || value === "") return true;

    if (num === "" && !numberCheck(value, ".-")) {
      alert("You can enter only real number in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    } else if (num === "i" && !numberCheck(value, "-")) {
      alert("You can enter only integer in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    } else if (num === "n" && !numberCheck(value, "")) {
      alert("You can enter only number in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    } else if (num !== "" && num !== "i" && num !== "n") {
      // "정수.소수" 형식
      if (!numberCheck(value, ".-")) {
        alert("You can enter only real number in " + fieldTitle + " field.");
        $field.trigger("focus");
        return false;
      }
      var split = String(num).split(".");
      if (!numLengthCheck(value, split[0], split[1])) {
        alert(fieldTitle + " field has invalid format.\n\n Max cipers of integer part : " + split[0] + " Down to max cipers decimal places : " + split[1]);
        $field.trigger("focus");
        return false;
      }
    }
    return true;
  }

  function validateRange($field, value, fieldTitle) {
    if (value === "" || !numberCheck(value, ".-")) return true;
    var fromNum = $field.attr("fromNum");
    var toNum = $field.attr("toNum");
    if (fromNum != null && Number(value) < Number(fromNum)) {
      alert("You can enter a number over " + fromNum + " in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    }
    if (toNum != null && Number(value) > Number(toNum)) {
      alert("You can enter a number under " + toNum + " in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  function validateFormat($field, value, fieldTitle) {
    var mask = $field.attr("format");
    if (!mask || value === "") return true;
    if (!formatMask(value, mask)) {
      alert(fieldTitle + " has invalid format.\n\n Format : " + mask);
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  function validateChar($field, value, fieldTitle) {
    var rule = $field.attr("char");
    if (!rule) return true;
    // s: 특수문자 금지, k: 한글 금지, e: 영문 금지, n: 숫자 금지
    if (rule.indexOf("s") >= 0 && /[$@#%\^&*"'\\]/.test(value)) {
      alert("You can't enter special characters in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    }
    if (rule.indexOf("k") >= 0 && /[가-힣]/.test(value)) {
      alert("You can't enter korean language (hangul) in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    }
    if (rule.indexOf("e") >= 0 && /[A-Za-z]/.test(value)) {
      alert("You can't enter english in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    }
    if (rule.indexOf("n") >= 0 && /[0-9]/.test(value)) {
      alert("You can't enter number in " + fieldTitle + " field.");
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  function validateEtc($field, value, fieldTitle) {
    var v = ($field.attr("valCheck") || "").toUpperCase();
    if (!v || value === "") return true;

    function emailOK(s) {
      // 널널한 RFC 호환 패턴
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);
    }
    function urlOK(s) {
      // http/https 스킴 생략 허용
      return /^((https?:\/\/)?([^\s.]+\.)+[^\s]{2,})$/.test(s);
    }
    function phoneOK(s) {
      return /^[0-9]{1,4}-[0-9]{2,4}-[0-9]{3,4}$/.test(s);
    }
    function dateOK(s) {
      // yyyymmdd
      if (!/^\d{8}$/.test(s)) return false;
      var y = +s.slice(0, 4), m = +s.slice(4, 6), d = +s.slice(6, 8);
      var dt = new Date(y, m - 1, d);
      return dt.getFullYear() === y && dt.getMonth() === m - 1 && dt.getDate() === d;
    }
    function juminOK(s) {
      var m = /^(\d{6})-?(\d{7})$/.exec(s);
      if (!m) return false;
      var num = m[1] + m[2];
      var base = "234567892345";
      var sum = 0;
      for (var i = 0; i < 12; i++) {
        sum += (num.charCodeAt(i) - 48) * (base.charCodeAt(i) - 48);
      }
      var mod = sum % 11;
      return ((11 - mod) % 10) === (num.charCodeAt(12) - 48);
    }

    if (v.indexOf("MAIL") > -1 && !emailOK(value)) {
      alert(fieldTitle + " has an invalid email address.\n\n ex) sds@samsung.com");
      $field.trigger("focus");
      return false;
    }
    if (v.indexOf("URL") > -1 && !urlOK(value)) {
      alert(fieldTitle + " has an invalid web address.\n\n ex) www.samsungsds.co.kr");
      $field.trigger("focus");
      return false;
    }
    if (v.indexOf("PHONE") > -1 && !phoneOK(value)) {
      alert(fieldTitle + " has an invalid telephone number. ex) 02-202-0020");
      $field.trigger("focus");
      return false;
    }
    if (v.indexOf("DATE") > -1 && !dateOK(value)) {
      alert(fieldTitle + " has an invalid date.\n\n ex) 20051031");
      $field.trigger("focus");
      return false;
    }
    if (v.indexOf("JUMIN") > -1 && !juminOK(value)) {
      alert(fieldTitle + " has an invalid social security number.");
      $field.trigger("focus");
      return false;
    }
    return true;
  }

  // ====== 메인 함수 ======
  function validateForm($form) {
    // 라디오는 name 단위로 한 번만 검사
    var checkedRadioNames = new Set();

    var $fields = $form.find(":input")
      .not(":hidden, :button, :submit, :reset, [disabled]");

    for (var i = 0; i < $fields.length; i++) {
      var $f = $($fields[i]);
      var type = ($f.attr("type") || "").toLowerCase();

      // 라디오는 같은 name 중 첫 요소만 검사
      if (type === "radio") {
        var nm = $f.attr("name");
        if (!nm || checkedRadioNames.has(nm)) continue;
        checkedRadioNames.add(nm);
      }

      var title = $f.attr("fieldTitle") || $f.attr("title") || $f.attr("name") || "This";
      var val = trimStr(type === "radio" ? "" : $f.val());

      // === 규칙 적용 순서 ===
      if (!validateRequired($f, val, title)) return false;
      if (!validateFilter($f, val, title)) return false;
      if (!validateMaxMinLength($f, val, title)) return false;
      if (!validateNum($f, val, title)) return false;
      if (!validateRange($f, val, title)) return false;
      if (!validateFormat($f, val, title)) return false;
      if (!validateChar($f, val, title)) return false;
      if (!validateEtc($f, val, title)) return false;
    }
    return true;
  }

  // ====== 공개 API (호환 유지) ======
  global.FormValidation = function (form) {
    return validateForm($(form));
  };

  // 옵션: 입력 중 길이 제한 강제 적용 (원본 PortalTextLengthCheck 대체)
  $(document).on("input", "[maxLength]", function () {
    var $f = $(this);
    var maxL = Number($f.attr("maxLength"));
    if (!maxL || maxL <= 0) return;
    var v = String($f.val());
    // 바이트 기준 잘라내기
    var enc = encodeURIComponent(v);
    var bytes = 0, end = 0;
    for (var i = 0; i < enc.length; i++) {
      if (enc[i] === "%") {
        bytes++; i += 2;
      } else {
        bytes++;
      }
      if (bytes > maxL) break;
      end++;
    }
    if (bytes > maxL) {
      // end는 인코딩 기준이므로 실제 문자 길이로 다시 계산
      // 간단하게 뒤에서 한 글자 제거 반복
      while (byteLength(v) > maxL) {
        v = v.slice(0, -1);
      }
      $f.val(v);
      var title = $f.attr("fieldTitle") || $f.attr("title") || "This field";
      alert(title + " has over max length.\n\nMax length of this field is (in case of English) : " + maxL);
    }
  });

})(window, window.jQuery);
