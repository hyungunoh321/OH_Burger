<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="마이페이지" />
  <jsp:param name="menu" value="mypage" />
</jsp:include>

<h1 class="page-title">마이페이지</h1>
<p class="page-desc"><c:out value="${sessionScope.loginMember.nickname}" /> 님이 쓴 글과 추천한 버거입니다.</p>

<h2 class="section-title">내가 쓴 글 <span class="hint">${posts.size()}개</span></h2>
<div class="card">
  <table class="list">
    <thead>
      <tr><th>분류</th><th>제목</th><th class="hide-sm">작성일</th><th class="hide-sm">조회</th><th>추천</th></tr>
    </thead>
    <tbody>
      <c:forEach var="p" items="${posts}">
        <tr>
          <td><span class="cat">${p.categoryLabel}</span></td>
          <td class="title">
            <a href="${ctx}/posts/detail?id=${p.id}"><c:out value="${p.title}" /></a>
            <c:if test="${p.commentCount > 0}"><span class="cnt">[${p.commentCount}]</span></c:if>
            <c:forEach var="tag" items="${p.tags}"><span class="tag"><c:out value="${tag.name}" /></span> </c:forEach>
          </td>
          <td class="hide-sm">${p.createdDate}</td>
          <td class="hide-sm">${p.viewCount}</td>
          <td>${p.likeCount}</td>
        </tr>
      </c:forEach>
      <c:if test="${empty posts}">
        <tr><td colspan="5" class="hint">아직 쓴 글이 없습니다. <a href="${ctx}/posts/write" style="color:var(--brand)">글쓰기</a></td></tr>
      </c:if>
    </tbody>
  </table>
</div>

<h2 class="section-title">내가 추천한 버거 <span class="hint">${burgers.size()}개</span></h2>
<c:choose>
  <c:when test="${empty burgers}">
    <p class="hint">아직 추천한 버거가 없습니다. <a href="${ctx}/burgers" style="color:var(--brand)">버거 도감 보기</a></p>
  </c:when>
  <c:otherwise>
    <div class="grid">
      <c:forEach var="b" items="${burgers}">
        <a class="card burger-card" href="${ctx}/burgers/detail?id=${b.id}">
          <t:thumb url="${b.imageUrl}" />
          <div>
            <div class="name"><c:out value="${b.name}" /></div>
            <div class="meta"><c:out value="${b.brandName}" /> · ${b.pattyLabel}</div>
            <div class="meta">추천 ${b.likeCount}</div>
          </div>
        </a>
      </c:forEach>
    </div>
  </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/footer.jsp" />
