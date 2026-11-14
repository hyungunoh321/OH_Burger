<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="${post.title}" />
  <jsp:param name="menu" value="posts" />
</jsp:include>

<div class="card pad">
  <span class="cat">${post.categoryLabel}</span>
  <h1 class="page-title" style="margin-top:8px"><c:out value="${post.title}" /></h1>
  <div class="post-meta">
    <span><c:out value="${post.nickname}" /></span>
    <span>${post.createdDateTime}<c:if test="${post.edited}"> (수정됨)</c:if></span>
    <span>조회 ${post.viewCount}</span>
  </div>

  <c:if test="${not empty post.tags}">
    <div class="chips" style="margin-bottom:14px">
      <c:forEach var="t" items="${post.tags}">
        <a class="tag" href="${ctx}/burgers/detail?id=${t.burgerId}">🍔 <c:out value="${t.label}" /></a>
      </c:forEach>
    </div>
  </c:if>

  <%-- 본문은 이스케이프해서 출력하고, 줄바꿈은 CSS(white-space: pre-line)로 살린다 --%>
  <div class="post-body"><c:out value="${post.content}" /></div>

  <div class="center" style="margin:20px 0">
    <%-- 추천 토글(P-05). 자기 글은 추천할 수 없어 버튼을 잠근다 (서버에서도 막는다) --%>
    <button class="btn big ${liked ? 'on' : ''}" id="like" type="button" aria-pressed="${liked}"
            data-url="${ctx}/posts/like" data-id="${post.id}" ${author ? 'disabled' : ''}>👍 추천 <b id="likes">${post.likeCount}</b></button>
    <c:if test="${author}"><p class="hint">자기 글은 추천할 수 없습니다.</p></c:if>
    <c:url var="loginUrl" value="/login"><c:param name="next" value="/posts/detail?id=${post.id}" /></c:url>
    <p class="hint" id="like-login" hidden>추천하려면 로그인이 필요합니다. <a href="${loginUrl}" style="color:var(--brand)">로그인하러 가기</a></p>
    <p class="hint" id="like-own" hidden>자기 글은 추천할 수 없습니다.</p>
    <p class="error" id="like-error" hidden>추천을 처리하지 못했습니다. 잠시 뒤에 다시 시도해 주세요.</p>
  </div>

  <div class="row between">
    <a class="btn" href="${ctx}/posts">목록</a>
    <div class="row">
      <%-- 버튼을 숨기는 것은 편의일 뿐이고, 권한은 수정 · 삭제 서블릿이 다시 검사한다 --%>
      <c:if test="${author}"><a class="btn" href="${ctx}/posts/edit?id=${post.id}">수정</a></c:if>
      <c:if test="${canDelete}">
        <form method="post" action="${ctx}/posts/delete" style="margin:0"
              onsubmit="return confirm('이 글을 삭제할까요? 댓글과 추천도 함께 삭제됩니다.');">
          <input type="hidden" name="id" value="${post.id}">
          <button class="btn" type="submit">삭제</button>
        </form>
      </c:if>
    </div>
  </div>
</div>

<script src="${ctx}/js/like.js"></script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
