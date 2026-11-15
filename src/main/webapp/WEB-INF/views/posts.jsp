<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="게시판" />
  <jsp:param name="menu" value="posts" />
</jsp:include>

<h1 class="page-title">게시판</h1>
<p class="page-desc">꿀조합과 꿀팁을 공유해 보세요.</p>

<%-- 분류 탭: 검색어 · 정렬 · 버거 조건은 유지하고 쪽 번호는 처음으로. 주소는 서블릿이 만들어 준다 --%>
<div class="tabs">
  <a class="tab ${empty category ? 'on' : ''}" href="${ctx}<c:out value="${tabHrefs['']}" />">전체</a>
  <c:forEach var="cat" items="${categoryLabels}">
    <a class="tab ${cat.key eq category ? 'on' : ''}" href="${ctx}<c:out value="${tabHrefs[cat.key]}" />">${cat.value}</a>
  </c:forEach>
</div>

<form id="filter" class="toolbar" method="get" action="${ctx}/posts">
  <c:if test="${not empty category}"><input type="hidden" name="category" value="${category}"></c:if>
  <c:if test="${not empty burger}"><input type="hidden" name="burger" value="${burger.id}"></c:if>
  <div class="grow">
    <input class="input" type="search" name="q" value="<c:out value="${q}" />" placeholder="제목 + 내용 검색" maxlength="100">
  </div>
  <select class="input" name="sort" aria-label="정렬">
    <option value="latest" ${sort eq 'latest' ? 'selected' : ''}>최신순</option>
    <option value="likes" ${sort eq 'likes' ? 'selected' : ''}>추천순</option>
  </select>
  <button class="btn" type="submit">검색</button>
  <c:url var="writeUrl" value="/posts/write">
    <c:if test="${not empty burger}"><c:param name="burger" value="${burger.id}" /></c:if>
  </c:url>
  <a class="btn primary" href="${writeUrl}">글쓰기</a>
</form>

<%-- 버거 상세의 "전체 보기"로 들어온 경우: 어떤 버거로 거르는 중인지 보여 주고 풀 수 있게 한다 --%>
<c:if test="${not empty burger}">
  <p class="hint">
    <a class="tag" href="${ctx}/burgers/detail?id=${burger.id}"><c:out value="${burger.brandName}" /> <c:out value="${burger.name}" /></a>
    버거가 태그된 글만 보는 중입니다. <a href="${ctx}<c:out value="${clearBurgerHref}" />" style="color:var(--brand)">조건 풀기</a>
  </p>
</c:if>

<div class="card">
  <table class="list">
    <thead>
      <tr><th>분류</th><th>제목</th><th class="hide-sm">작성자</th><th class="hide-sm">작성일</th><th class="hide-sm">조회</th><th>추천</th></tr>
    </thead>
    <tbody>
      <c:forEach var="p" items="${posts}">
        <tr>
          <td><span class="cat">${p.categoryLabel}</span></td>
          <td class="title">
            <a href="${ctx}/posts/detail?id=${p.id}"><c:out value="${p.title}" /></a>
            <c:if test="${p.commentCount > 0}"><span class="cnt">[${p.commentCount}]</span></c:if>
            <c:forEach var="t" items="${p.tags}"><span class="tag"><c:out value="${t.name}" /></span> </c:forEach>
          </td>
          <td class="hide-sm"><c:out value="${p.nickname}" /></td>
          <td class="hide-sm">${p.createdDate}</td>
          <td class="hide-sm">${p.viewCount}</td>
          <td>${p.likeCount}</td>
        </tr>
      </c:forEach>
      <c:if test="${empty posts}">
        <tr><td colspan="6" class="hint">게시글이 없습니다.</td></tr>
      </c:if>
    </tbody>
  </table>
</div>

<%-- 쪽 번호: 모든 조건을 유지한다 --%>
<c:if test="${totalPages > 1}">
  <div class="pager">
    <c:if test="${page > 1}">
      <a href="${ctx}<c:out value="${prevHref}" />" aria-label="이전 쪽">‹</a>
    </c:if>
    <c:forEach var="n" begin="${startPage}" end="${endPage}">
      <a class="${n == page ? 'on' : ''}" href="${ctx}<c:out value="${pageHrefs[n]}" />">${n}</a>
    </c:forEach>
    <c:if test="${page < totalPages}">
      <a href="${ctx}<c:out value="${nextHref}" />" aria-label="다음 쪽">›</a>
    </c:if>
  </div>
</c:if>

<script>
  // 정렬을 바꾸면 바로 다시 조회한다
  document.getElementById('filter').addEventListener('change', function (e) {
    if (e.target.name === 'sort') this.submit();
  });
</script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
