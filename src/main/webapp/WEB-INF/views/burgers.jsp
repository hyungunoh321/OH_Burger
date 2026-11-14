<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="버거 도감" />
  <jsp:param name="menu" value="burgers" />
</jsp:include>

<h1 class="page-title">버거 도감</h1>
<p class="page-desc">브랜드별 버거 메뉴를 검색하고 비교해 보세요.</p>

<form id="filter" method="get" action="${ctx}/burgers">
  <div class="toolbar">
    <div class="grow">
      <input class="input" type="search" name="q" value="<c:out value="${q}" />" placeholder="버거 이름 검색" maxlength="60">
    </div>
    <select class="input" name="patty" aria-label="패티 종류">
      <option value="">패티 전체</option>
      <c:forEach var="p" items="${pattyLabels}">
        <option value="${p.key}" ${p.key eq patty ? 'selected' : ''}><c:out value="${p.value}" /></option>
      </c:forEach>
    </select>
    <select class="input" name="sort" aria-label="정렬">
      <c:forEach var="s" items="${sortLabels}">
        <option value="${s.key}" ${s.key eq sort ? 'selected' : ''}><c:out value="${s.value}" /></option>
      </c:forEach>
    </select>
    <button class="btn primary" type="submit">검색</button>
  </div>
  <div class="chips" style="margin-bottom:16px">
    <c:forEach var="br" items="${brands}">
      <c:set var="on" value="${selectedBrands.contains(br.id)}" />
      <label class="chip ${on ? 'on' : ''}">
        <input type="checkbox" name="brand" value="${br.id}" ${on ? 'checked' : ''}>
        <c:out value="${br.name}" />
      </label>
    </c:forEach>
  </div>
</form>

<p class="hint">총 ${burgers.size()}개</p>
<c:choose>
  <c:when test="${empty burgers}">
    <p class="hint">조건에 맞는 버거가 없습니다.</p>
  </c:when>
  <c:otherwise>
    <div class="grid">
      <c:forEach var="b" items="${burgers}">
        <a class="card burger-card" href="${ctx}/burgers/detail?id=${b.id}">
          <div class="thumb" aria-hidden="true">🍔</div>
          <div>
            <div class="name"><c:out value="${b.name}" /></div>
            <div class="meta"><c:out value="${b.brandName}" /> · ${b.pattyLabel}</div>
            <div class="meta">
              <c:choose>
                <c:when test="${empty b.price}">가격 정보 없음</c:when>
                <c:otherwise><fmt:formatNumber value="${b.price}" pattern="#,###" />원</c:otherwise>
              </c:choose>
            </div>
            <div class="meta">
              <c:choose>
                <c:when test="${empty b.caloriesKcal}">열량 정보 없음</c:when>
                <c:otherwise>${b.caloriesKcal}kcal</c:otherwise>
              </c:choose>
              ·
              <c:choose>
                <c:when test="${empty b.proteinG}">단백질 정보 없음</c:when>
                <c:otherwise>단백질 <fmt:formatNumber value="${b.proteinG}" maxFractionDigits="1" />g</c:otherwise>
              </c:choose>
            </div>
            <div class="meta">👍 ${b.likeCount}</div>
          </div>
        </a>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<script>
  // 필터를 바꾸면 바로 다시 조회한다 (스크립트가 꺼져 있어도 검색 버튼으로 동작)
  document.getElementById('filter').addEventListener('change', function (e) {
    if (e.target.name !== 'q') this.submit();
  });
</script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
