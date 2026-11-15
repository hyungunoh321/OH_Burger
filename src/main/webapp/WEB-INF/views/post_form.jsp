<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 글쓰기 · 수정 공통 화면. 서블릿이 heading, action, cancelUrl, form 을 넘긴다 --%>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="${heading}" />
  <jsp:param name="menu" value="posts" />
</jsp:include>

<h1 class="page-title"><c:out value="${heading}" /></h1>
<p class="page-desc">버거를 태그하면 해당 버거 상세 화면에도 글이 노출됩니다.</p>

<c:if test="${restored}">
  <p class="notice">로그인이 풀려 다시 로그인했습니다. 쓰던 내용을 되살렸으니 확인하고 등록해 주세요.</p>
</c:if>

<form class="card pad" method="post" action="${ctx}${action}">
  <label class="field">
    <span>분류</span>
    <select class="input" name="category" style="width:auto" required>
      <c:forEach var="cat" items="${categoryLabels}">
        <option value="${cat.key}" ${cat.key eq form.category ? 'selected' : ''}>${cat.value}</option>
      </c:forEach>
    </select>
    <c:if test="${not empty form.errors.category}"><span class="error"><c:out value="${form.errors.category}" /></span></c:if>
  </label>

  <label class="field">
    <span>제목</span>
    <input class="input" name="title" value="<c:out value="${form.title}" />" maxlength="${titleMax}" required
           placeholder="제목을 입력하세요 (${titleMax}자 이내)">
    <c:if test="${not empty form.errors.title}"><span class="error"><c:out value="${form.errors.title}" /></span></c:if>
  </label>

  <div class="field" style="margin-bottom:16px">
    <span style="display:block;font-weight:700;margin-bottom:6px">버거 태그 <span class="hint">(선택, 최대 ${tagMax}개)</span></span>
    <%-- 고른 버거는 칩으로 보여 주고, 칩 안의 숨은 입력(burgerId)이 서버로 간다. 칩을 누르면 뺀다 --%>
    <div class="chips" id="picked" style="margin-bottom:8px">
      <c:forEach var="t" items="${form.tags}">
        <button type="button" class="chip on" title="누르면 태그에서 뺍니다">🍔 <c:out value="${t.label}" /> ✕<input type="hidden" name="burgerId" value="${t.burgerId}"></button>
      </c:forEach>
    </div>
    <input class="input" id="tagq" list="burgerlist" autocomplete="off" placeholder="버거 이름을 검색해 선택하세요">
    <datalist id="burgerlist">
      <c:forEach var="b" items="${allBurgers}">
        <option value="<c:out value="${b.brandName} ${b.name}" />" data-id="${b.id}"></option>
      </c:forEach>
    </datalist>
    <p class="hint" id="tagmsg"></p>
    <c:if test="${not empty form.errors.tags}"><span class="error"><c:out value="${form.errors.tags}" /></span></c:if>
  </div>

  <label class="field">
    <span>내용</span>
    <textarea class="input" name="content" maxlength="${contentMax}" required
              placeholder="내용을 입력하세요 (${contentMax}자 이내)"><c:out value="${form.content}" /></textarea>
    <c:if test="${not empty form.errors.content}"><span class="error"><c:out value="${form.errors.content}" /></span></c:if>
  </label>

  <div class="row end">
    <a class="btn" href="${ctx}${cancelUrl}">취소</a>
    <button class="btn primary" type="submit">등록</button>
  </div>
</form>

<script>
  (function () {
    var MAX = ${tagMax};
    var picked = document.getElementById('picked');
    var input = document.getElementById('tagq');
    var msg = document.getElementById('tagmsg');
    var options = document.getElementById('burgerlist').options;

    function pickedIds() {
      return Array.prototype.map.call(picked.querySelectorAll('input[name=burgerId]'), function (el) { return el.value; });
    }

    // 목록에서 고른 값이 버거 이름과 정확히 같을 때만 태그로 추가한다
    function tryAdd() {
      var option = null;
      for (var i = 0; i < options.length; i++) {
        if (options[i].value === input.value) { option = options[i]; break; }
      }
      if (!option) return;

      msg.textContent = '';
      var id = option.dataset.id;
      if (pickedIds().indexOf(id) >= 0) {
        msg.textContent = '이미 태그한 버거입니다.';
      } else if (pickedIds().length >= MAX) {
        msg.textContent = '버거는 최대 ' + MAX + '개까지 태그할 수 있습니다.';
      } else {
        var chip = document.createElement('button');
        chip.type = 'button';
        chip.className = 'chip on';
        chip.title = '누르면 태그에서 뺍니다';
        chip.textContent = '🍔 ' + option.value + ' ✕'; // textContent 라서 이름에 특수 문자가 있어도 안전하다
        var hidden = document.createElement('input');
        hidden.type = 'hidden';
        hidden.name = 'burgerId';
        hidden.value = id;
        chip.appendChild(hidden);
        picked.appendChild(chip);
      }
      input.value = '';
    }

    // 글자를 치는 도중에는 추가하지 않는다. "리아 불고기"처럼 다른 이름의 앞부분과 같은 이름이
    // 먼저 걸려서 "리아 불고기 더블(빅불)"을 끝까지 칠 수 없게 되기 때문이다.
    // 목록에서 고른 경우(insertReplacementText, 또는 inputType 이 없는 경우)에만 바로 추가한다.
    input.addEventListener('input', function (e) {
      if (e.inputType === undefined || e.inputType === 'insertReplacementText') tryAdd();
    });
    // 직접 다 친 경우에는 칸을 벗어나거나(change) Enter 를 누를 때 추가한다
    input.addEventListener('change', tryAdd);
    // Enter 로 양식이 제출되지 않게 하고 태그 추가만 시도한다
    input.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') { e.preventDefault(); tryAdd(); }
    });

    picked.addEventListener('click', function (e) {
      var chip = e.target.closest('.chip');
      if (chip) { chip.remove(); msg.textContent = ''; }
    });
  })();
</script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
