<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- 버거 티어표(T-01, T-02, HomeServlet)와 사이드 티어표(T-03, SideTierServlet)가 같이 쓴다.
     side 가 true 면 사이드: 종류 칩이 붙고, 상세 화면이 없어 카드를 누를 수 없다.
     tierPath 는 이 화면의 주소(/home 또는 /sides/tier) --%>
<%-- 상단 메뉴에 '버거 티어표'(menu=tier) · '사이드 티어표'(menu=sideTier) 가 따로 있다 --%>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="${side ? '사이드 티어표' : '버거 티어표'}" />
  <jsp:param name="menu" value="${side ? 'sideTier' : 'tier'}" />
</jsp:include>

<h1 class="page-title">${side ? '사이드 티어표' : '버거 티어표'}</h1>
<p class="page-desc">
  <c:choose>
    <c:when test="${side}">국내 프랜차이즈 7곳의 사이드 · 치킨 · 디저트를 기준별로 줄 세웠습니다.</c:when>
    <c:otherwise>국내 프랜차이즈 7곳의 버거를 기준별로 줄 세웠습니다.</c:otherwise>
  </c:choose>
  기준: ${metric.note}
  <c:if test="${side}"> · 종류를 고르면 그 종류 안에서 순위를 다시 매깁니다.</c:if>
</p>

<%-- 탭: 기준만 바꾸고 종류 · 브랜드 · 방향은 유지 --%>
<div class="tabs">
  <c:forEach var="m" items="${metrics}">
    <c:url var="u" value="${tierPath}">
      <c:param name="metric" value="${m.key}" />
      <c:if test="${not empty kind}"><c:param name="kind" value="${kind.key}" /></c:if>
      <c:if test="${not empty brandId}"><c:param name="brand" value="${brandId}" /></c:if>
      <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
    </c:url>
    <a class="tab ${m eq metric ? 'on' : ''}" href="${u}">${m.label}</a>
  </c:forEach>
</div>

<%-- 사이드만: 종류 칩. 순위를 매길 범위를 바꾼다 --%>
<c:if test="${side}">
  <div class="chips kind-chips">
    <c:url var="u" value="${tierPath}">
      <c:param name="metric" value="${metric.key}" />
      <c:if test="${not empty brandId}"><c:param name="brand" value="${brandId}" /></c:if>
      <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
    </c:url>
    <a class="chip ${empty kind ? 'on' : ''}" href="${u}">전체 종류</a>
    <c:forEach var="k" items="${kinds}">
      <c:url var="u" value="${tierPath}">
        <c:param name="metric" value="${metric.key}" />
        <c:param name="kind" value="${k.key}" />
        <c:if test="${not empty brandId}"><c:param name="brand" value="${brandId}" /></c:if>
        <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
      </c:url>
      <a class="chip ${k eq kind ? 'on' : ''}" href="${u}">${k.label}</a>
    </c:forEach>
  </div>
</c:if>

<div class="toolbar">
  <%-- 브랜드 칩: 티어는 그대로 두고 표시만 거른다 --%>
  <div class="chips grow">
    <c:url var="u" value="${tierPath}">
      <c:param name="metric" value="${metric.key}" />
      <c:if test="${not empty kind}"><c:param name="kind" value="${kind.key}" /></c:if>
      <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
    </c:url>
    <a class="chip ${empty brandId ? 'on' : ''}" href="${u}">전체</a>
    <c:forEach var="br" items="${brands}">
      <c:url var="u" value="${tierPath}">
        <c:param name="metric" value="${metric.key}" />
        <c:if test="${not empty kind}"><c:param name="kind" value="${kind.key}" /></c:if>
        <c:param name="brand" value="${br.id}" />
        <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
      </c:url>
      <a class="chip ${br.id eq brandId ? 'on' : ''}" href="${u}"><c:out value="${br.name}" /></a>
    </c:forEach>
  </div>
  <c:url var="u" value="${tierPath}">
    <c:param name="metric" value="${metric.key}" />
    <c:if test="${not empty kind}"><c:param name="kind" value="${kind.key}" /></c:if>
    <c:if test="${not empty brandId}"><c:param name="brand" value="${brandId}" /></c:if>
    <c:if test="${not reversed}"><c:param name="dir" value="rev" /></c:if>
  </c:url>
  <a class="btn" href="${u}">${reversed ? 'D 티어부터 ▲' : 'S 티어부터 ▼'}</a>
</div>

<c:if test="${shown == 0}">
  <p class="hint">
    <c:choose>
      <c:when test="${metric.excludeZero}">아직 인기 점수가 집계된 버거가 없습니다. 버거를 조회하거나 추천하면 점수가 쌓입니다.</c:when>
      <c:otherwise>이 기준의 정보가 공개된 메뉴가 없습니다.</c:otherwise>
    </c:choose>
  </p>
</c:if>

<c:forEach var="row" items="${rows}">
  <div class="tier-row">
    <div class="tier-label tier-${row.key}">${row.key}<small>${row.value.size()}개</small></div>
    <div class="tier-items">
      <c:forEach var="e" items="${row.value}">
        <c:set var="sub"><c:out value="${e.brandName}" /> · <fmt:formatNumber value="${e.value}" maxFractionDigits="1" />${metric.unit}</c:set>
        <c:choose>
          <c:when test="${side}">
            <%-- 사이드 상세 화면이 아직 없어 누를 수 없는 카드 --%>
            <div class="tier-item static">
              <t:thumb url="${e.imageUrl}" />
              <div><div class="name"><c:out value="${e.name}" /></div><div class="sub">${sub}</div></div>
            </div>
          </c:when>
          <c:otherwise>
            <a class="tier-item" href="${ctx}/burgers/detail?id=${e.id}">
              <t:thumb url="${e.imageUrl}" />
              <div><div class="name"><c:out value="${e.name}" /></div><div class="sub">${sub}</div></div>
            </a>
          </c:otherwise>
        </c:choose>
      </c:forEach>
      <c:if test="${empty row.value}"><span class="tier-empty">해당하는 메뉴가 없습니다</span></c:if>
    </div>
  </div>
</c:forEach>

<jsp:include page="/WEB-INF/views/footer.jsp" />
