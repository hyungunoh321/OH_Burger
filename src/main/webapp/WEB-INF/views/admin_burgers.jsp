<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="버거 관리" />
  <jsp:param name="menu" value="admin" />
</jsp:include>

<h1 class="page-title">버거 관리</h1>
<p class="page-desc">관리자 전용 화면입니다. 버거를 등록하고 수정 · 삭제할 수 있습니다.</p>

<form id="filter" class="toolbar" method="get" action="${ctx}/admin/burgers">
  <div class="grow">
    <input class="input" type="search" name="q" value="<c:out value="${q}" />" placeholder="버거 이름 검색" maxlength="60">
  </div>
  <select class="input" name="brand" aria-label="브랜드">
    <option value="">브랜드 전체</option>
    <c:forEach var="br" items="${brands}">
      <option value="${br.id}" ${br.id eq brand ? 'selected' : ''}><c:out value="${br.name}" /></option>
    </c:forEach>
  </select>
  <button class="btn" type="submit">검색</button>
  <a class="btn primary" href="${ctx}/admin/burgers/new">버거 등록</a>
</form>

<p class="hint">총 ${burgers.size()}개</p>
<div class="card">
  <table class="list">
    <thead>
      <tr><th>브랜드</th><th>이름</th><th class="hide-sm">패티</th><th>가격</th><th class="hide-sm">열량</th><th class="hide-sm">추천</th><th>관리</th></tr>
    </thead>
    <tbody>
      <c:forEach var="b" items="${burgers}">
        <tr>
          <td><c:out value="${b.brandName}" /></td>
          <td class="title"><a href="${ctx}/burgers/detail?id=${b.id}"><c:out value="${b.name}" /></a></td>
          <td class="hide-sm">${b.pattyLabel}</td>
          <td>
            <c:choose>
              <c:when test="${empty b.price}"><span class="hint">없음</span></c:when>
              <c:otherwise><fmt:formatNumber value="${b.price}" pattern="#,###" />원</c:otherwise>
            </c:choose>
          </td>
          <td class="hide-sm">
            <c:choose>
              <c:when test="${empty b.caloriesKcal}"><span class="hint">없음</span></c:when>
              <c:otherwise>${b.caloriesKcal}kcal</c:otherwise>
            </c:choose>
          </td>
          <td class="hide-sm">${b.likeCount}</td>
          <td>
            <div class="row">
              <a class="btn small" href="${ctx}/admin/burgers/edit?id=${b.id}">수정</a>
              <%-- 버거 이름은 data 속성으로 넘긴다 (이름에 따옴표가 있어도 스크립트가 깨지지 않게) --%>
              <form class="delete" method="post" action="${ctx}/admin/burgers/delete" style="margin:0"
                    data-name="<c:out value="${b.brandName} ${b.name}" />">
                <input type="hidden" name="id" value="${b.id}">
                <button class="btn small" type="submit">삭제</button>
              </form>
            </div>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty burgers}">
        <tr><td colspan="7" class="hint">조건에 맞는 버거가 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>
</div>

<script>
  // 브랜드를 바꾸면 바로 다시 조회한다
  document.getElementById('filter').addEventListener('change', function (e) {
    if (e.target.name === 'brand') this.submit();
  });
  // 삭제는 되돌릴 수 없으므로 한 번 더 묻는다
  document.addEventListener('submit', function (e) {
    var form = e.target;
    if (form.classList.contains('delete')
        && !confirm(form.dataset.name + ' 을(를) 삭제할까요?\n이 버거의 추천과 게시글 태그도 함께 삭제됩니다.')) {
      e.preventDefault();
    }
  });
</script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
