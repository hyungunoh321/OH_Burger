<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="로그인" />
</jsp:include>

<form class="card pad narrow" method="post" action="${ctx}/login">
  <h1 class="page-title" style="margin-bottom:18px">로그인</h1>

  <c:if test="${joined}"><p class="notice">가입이 완료되었습니다. 로그인해 주세요.</p></c:if>

  <%-- 로그인 뒤에 돌아갈 주소. 서버가 사이트 안의 경로인지 다시 검사한다 --%>
  <c:if test="${not empty next}"><input type="hidden" name="next" value="<c:out value="${next}" />"></c:if>

  <label class="field">
    <span>아이디</span>
    <input class="input" name="loginId" value="<c:out value="${loginId}" />" autocomplete="username" required autofocus>
  </label>
  <label class="field">
    <span>비밀번호</span>
    <input class="input" type="password" name="password" autocomplete="current-password" required>
  </label>

  <c:if test="${not empty error}"><p class="error"><c:out value="${error}" /></p></c:if>

  <button class="btn primary big" type="submit" style="width:100%">로그인</button>
  <p class="hint center" style="margin-bottom:0">아직 회원이 아니신가요? <a href="${ctx}/join" style="color:var(--brand)">회원가입</a></p>
</form>

<jsp:include page="/WEB-INF/views/footer.jsp" />
