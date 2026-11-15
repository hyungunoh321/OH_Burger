<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="버거 티어표" />
  <jsp:param name="menu" value="tier" />
</jsp:include>

<h1 class="page-title">버거 티어표</h1>
<p class="page-desc">국내 프랜차이즈 7곳의 버거를 기준별로 줄 세웠습니다. 기준: ${metric.note}</p>

<%-- 탭: 기준만 바꾸고 브랜드 · 방향은 유지 --%>
<div class="tabs">
  <c:forEach var="m" items="${metrics}">
    <c:url var="u" value="/home">
      <c:param name="metric" value="${m.key}" />
      <c:if test="${not empty brandId}"><c:param name="brand" value="${brandId}" /></c:if>
      <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
    </c:url>
    <a class="tab ${m eq metric ? 'on' : ''}" href="${u}">${m.label}</a>
  </c:forEach>
</div>

<div class="toolbar">
  <%-- 브랜드 칩: 티어는 전체 버거 기준 그대로 두고 표시만 거른다 --%>
  <div class="chips grow">
    <c:url var="u" value="/home">
      <c:param name="metric" value="${metric.key}" />
      <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
    </c:url>
    <a class="chip ${empty brandId ? 'on' : ''}" href="${u}">전체</a>
    <c:forEach var="br" items="${brands}">
      <c:url var="u" value="/home">
        <c:param name="metric" value="${metric.key}" />
        <c:param name="brand" value="${br.id}" />
        <c:if test="${reversed}"><c:param name="dir" value="rev" /></c:if>
      </c:url>
      <a class="chip ${br.id eq brandId ? 'on' : ''}" href="${u}"><c:out value="${br.name}" /></a>
    </c:forEach>
  </div>
  <c:url var="u" value="/home">
    <c:param name="metric" value="${metric.key}" />
    <c:if test="${not empty brandId}"><c:param name="brand" value="${brandId}" /></c:if>
    <c:if test="${not reversed}"><c:param name="dir" value="rev" /></c:if>
  </c:url>
  <a class="btn" href="${u}">${reversed ? 'D 티어부터 ▲' : 'S 티어부터 ▼'}</a>
</div>

<c:if test="${shown == 0}">
  <p class="hint">
    <c:choose>
      <c:when test="${metric.excludeZero}">아직 인기 점수가 집계된 버거가 없습니다. 버거를 조회하거나 추천하면 점수가 쌓입니다.</c:when>
      <c:otherwise>이 기준의 정보가 공개된 버거가 없습니다.</c:otherwise>
    </c:choose>
  </p>
</c:if>

<c:forEach var="row" items="${rows}">
  <div class="tier-row">
    <div class="tier-label tier-${row.key}">${row.key}<small>${row.value.size()}개</small></div>
    <div class="tier-items">
      <c:forEach var="e" items="${row.value}">
        <a class="tier-item" href="${ctx}/burgers/detail?id=${e.burgerId}">
          <div class="thumb" aria-hidden="true"></div>
          <div>
            <div class="name"><c:out value="${e.name}" /></div>
            <div class="sub"><c:out value="${e.brandName}" /> · <fmt:formatNumber value="${e.value}" maxFractionDigits="1" />${metric.unit}</div>
          </div>
        </a>
      </c:forEach>
      <c:if test="${empty row.value}"><span class="tier-empty">해당하는 버거가 없습니다</span></c:if>
    </div>
  </div>
</c:forEach>

<jsp:include page="/WEB-INF/views/footer.jsp" />
