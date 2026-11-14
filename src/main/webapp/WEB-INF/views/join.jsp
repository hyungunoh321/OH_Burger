<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="회원가입" />
</jsp:include>

<form class="card pad narrow" method="post" action="${ctx}/join">
  <h1 class="page-title" style="margin-bottom:18px">회원가입</h1>

  <label class="field">
    <span>아이디</span>
    <input class="input" name="loginId" value="<c:out value="${loginId}" />" autocomplete="username"
           required minlength="4" maxlength="20" pattern="[A-Za-z0-9]{4,20}">
    <span class="hint">영문 · 숫자 4~20자</span>
    <c:if test="${not empty errors.loginId}"><span class="error"><c:out value="${errors.loginId}" /></span></c:if>
  </label>

  <label class="field">
    <span>비밀번호</span>
    <input class="input" type="password" name="password" autocomplete="new-password" required minlength="8">
    <span class="hint">8자 이상</span>
    <c:if test="${not empty errors.password}"><span class="error"><c:out value="${errors.password}" /></span></c:if>
  </label>

  <label class="field">
    <span>비밀번호 확인</span>
    <input class="input" type="password" name="passwordConfirm" autocomplete="new-password" required>
    <c:if test="${not empty errors.passwordConfirm}"><span class="error"><c:out value="${errors.passwordConfirm}" /></span></c:if>
  </label>

  <label class="field">
    <span>닉네임</span>
    <input class="input" name="nickname" value="<c:out value="${nickname}" />" autocomplete="nickname"
           required minlength="2" maxlength="10">
    <span class="hint">2~10자, 게시글과 댓글에 표시됩니다</span>
    <c:if test="${not empty errors.nickname}"><span class="error"><c:out value="${errors.nickname}" /></span></c:if>
  </label>

  <button class="btn primary big" type="submit" style="width:100%">가입하기</button>
  <p class="hint center" style="margin-bottom:0">이미 회원이신가요? <a href="${ctx}/login" style="color:var(--brand)">로그인</a></p>
</form>

<jsp:include page="/WEB-INF/views/footer.jsp" />
