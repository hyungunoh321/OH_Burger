<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- include 한 화면에서도 쓸 수 있게 request 범위에 둔다 --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" scope="request" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>OH Burger<c:if test="${not empty param.title}"> - <c:out value="${param.title}" /></c:if></title>
  <link rel="stylesheet" href="${ctx}/css/style.css">
</head>
<body>
<header class="site-header"><div class="container">
  <a class="logo" href="${ctx}/home">OH <span>Burger</span></a>
  <nav class="nav">
    <a href="${ctx}/home" class="${param.menu eq 'tier' ? 'active' : ''}">티어표</a>
    <a href="${ctx}/burgers" class="${param.menu eq 'burgers' ? 'active' : ''}">버거 도감</a>
    <a href="${ctx}/posts" class="${param.menu eq 'posts' ? 'active' : ''}">게시판</a>
    <a href="${ctx}/roulette" class="${param.menu eq 'roulette' ? 'active' : ''}">룰렛</a>
  </nav>
  <div class="auth">
    <c:choose>
      <c:when test="${not empty sessionScope.loginMember}">
        <span class="who"><c:out value="${sessionScope.loginMember.nickname}" /> 님</span>
        <form method="post" action="${ctx}/logout"><button class="btn ghost" type="submit">로그아웃</button></form>
      </c:when>
      <c:otherwise>
        <%-- 로그인 뒤에 지금 보던 화면으로 돌아오게 주소를 넘긴다 (로그인 · 회원가입 · 오류 화면에서는 넘기지 않음) --%>
        <c:set var="here" value="${requestScope['javax.servlet.forward.servlet_path']}" />
        <c:set var="hereQuery" value="${requestScope['javax.servlet.forward.query_string']}" />
        <c:url var="loginUrl" value="/login">
          <c:if test="${not empty here and here ne '/login' and here ne '/join' and empty requestScope['javax.servlet.error.status_code']}">
            <c:param name="next" value="${here}${empty hereQuery ? '' : '?'}${hereQuery}" />
          </c:if>
        </c:url>
        <a class="btn ghost" href="${loginUrl}">로그인</a>
        <a class="btn primary" href="${ctx}/join">회원가입</a>
      </c:otherwise>
    </c:choose>
  </div>
</div></header>
<main class="container">
