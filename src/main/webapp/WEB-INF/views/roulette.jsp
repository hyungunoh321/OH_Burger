<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="버거 룰렛" />
  <jsp:param name="menu" value="roulette" />
</jsp:include>

<h1 class="page-title">버거 룰렛</h1>
<p class="page-desc">뭐 먹을지 고민될 때, 조건을 고르고 돌려 보세요.</p>

<%-- 조건을 바꾸면 js/roulette.js 가 후보를 다시 받아 와 룰렛 판을 그린다. data-ctx 는 요청 주소를 만들 때 쓴다 --%>
<div class="roulette" id="roulette" data-ctx="${ctx}">
  <form class="card pad" id="conditions" onsubmit="return false">
    <div class="field" style="margin-bottom:16px">
      <span style="display:block;font-weight:700;margin-bottom:6px">브랜드 <span class="hint">(선택 안 하면 전체)</span></span>
      <div class="chips">
        <c:forEach var="br" items="${brands}">
          <label class="chip"><input type="checkbox" name="brand" value="${br.id}"><c:out value="${br.name}" /></label>
        </c:forEach>
      </div>
    </div>
    <label class="field">
      <span>패티</span>
      <select class="input" name="patty">
        <option value="">전체</option>
        <c:forEach var="p" items="${pattyLabels}">
          <option value="${p.key}"><c:out value="${p.value}" /></option>
        </c:forEach>
      </select>
    </label>
    <label class="field">
      <span>가격 상한</span>
      <select class="input" name="maxPrice">
        <option value="">제한 없음</option>
        <option value="6000">6,000원 이하</option>
        <option value="8000">8,000원 이하</option>
        <option value="10000">10,000원 이하</option>
      </select>
      <span class="hint">가격 상한을 고르면 가격 정보가 없는 버거는 빠집니다</span>
    </label>
    <label class="field">
      <span>열량 상한</span>
      <select class="input" name="maxKcal">
        <option value="">제한 없음</option>
        <option value="450">450kcal 이하</option>
        <option value="550">550kcal 이하</option>
        <option value="650">650kcal 이하</option>
        <option value="800">800kcal 이하</option>
      </select>
    </label>
    <p class="hint" id="count" aria-live="polite">후보를 불러오는 중입니다…</p>
    <button class="btn primary big" id="spin" type="button" style="width:100%" disabled>룰렛 돌리기</button>
  </form>

  <div>
    <div class="wheel-wrap">
      <canvas id="wheel" width="840" height="840" role="img" aria-label="버거 룰렛 판"></canvas>
      <div class="pointer"></div>
    </div>
    <div id="result" aria-live="polite"></div>
  </div>
</div>

<script src="${ctx}/js/roulette.js"></script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
