<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="환경 확인" />
  <jsp:param name="menu" value="tier" />
</jsp:include>

<h1 class="page-title">환경 확인</h1>
<p class="page-desc">서블릿 → DB → JSP 연결이 정상입니다. 등록된 버거는 총 <b>${total}</b>종입니다.</p>

<div class="card">
  <table class="list">
    <thead><tr><th>브랜드</th><th>버거 수</th></tr></thead>
    <tbody>
      <c:forEach var="e" items="${counts}">
        <tr><td class="title"><c:out value="${e.key}" /></td><td>${e.value}</td></tr>
      </c:forEach>
    </tbody>
  </table>
</div>

<jsp:include page="/WEB-INF/views/footer.jsp" />
