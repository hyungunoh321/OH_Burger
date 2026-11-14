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
    <a class="btn ghost" href="${ctx}/login">로그인</a>
    <a class="btn primary" href="${ctx}/join">회원가입</a>
  </div>
</div></header>
<main class="container">
