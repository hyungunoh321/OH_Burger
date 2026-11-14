<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 오류 화면. ErrorServlet 이 status, errorTitle, errorMessage 를 넘긴다. 예외 내용은 보여 주지 않는다 --%>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="${errorTitle}" />
</jsp:include>

<div class="error-page">
  <div class="code">${status}</div>
  <h1 class="page-title"><c:out value="${errorTitle}" /></h1>
  <p class="page-desc"><c:out value="${errorMessage}" /></p>
  <div class="row" style="justify-content:center">
    <button class="btn" type="button" onclick="history.back()">이전 화면</button>
    <a class="btn primary" href="${ctx}/home">메인으로</a>
  </div>
</div>

<jsp:include page="/WEB-INF/views/footer.jsp" />
