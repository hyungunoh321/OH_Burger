<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="t" tagdir="/WEB-INF/tags" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="${burger.name}" />
  <jsp:param name="menu" value="burgers" />
</jsp:include>

<p class="hint"><a href="${ctx}/burgers">버거 도감</a> › <a href="${ctx}/burgers?brand=${burger.brandId}"><c:out value="${burger.brandName}" /></a></p>

<div class="detail">
  <div><t:thumb url="${burger.imageUrl}" large="true" /></div>
  <div>
    <span class="tag"><c:out value="${burger.brandName}" /></span>
    <h1><c:out value="${burger.name}" /></h1>
    <p class="page-desc">
      ${burger.pattyLabel} 패티 · 단품
      <c:choose>
        <c:when test="${empty burger.price}">가격 정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.price}" pattern="#,###" />원</c:otherwise>
      </c:choose>
    </p>
    <c:if test="${not empty burger.description}">
      <p><c:out value="${burger.description}" /></p>
    </c:if>

    <div class="tier-badges">
      <c:forEach var="m" items="${metrics}">
        <c:set var="t" value="${tiers[m.key]}" />
        <div>
          ${m.label}
          <c:choose>
            <c:when test="${not empty t}"><span class="badge tier-${t}">${t}</span></c:when>
            <c:otherwise><span class="badge none">${m.excludeZero ? '집계 중' : '정보 없음'}</span></c:otherwise>
          </c:choose>
        </div>
      </c:forEach>
    </div>

    <table class="nutri">
      <tr><th>중량</th><td>
        <c:choose><c:when test="${empty burger.weightG}">정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.weightG}" pattern="#,###" /> g</c:otherwise></c:choose>
      </td></tr>
      <tr><th>열량</th><td>
        <c:choose><c:when test="${empty burger.caloriesKcal}">정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.caloriesKcal}" pattern="#,###" /> kcal</c:otherwise></c:choose>
      </td></tr>
      <tr><th>단백질</th><td>
        <c:choose><c:when test="${empty burger.proteinG}">정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.proteinG}" maxFractionDigits="1" /> g</c:otherwise></c:choose>
      </td></tr>
      <tr><th>포화지방</th><td>
        <c:choose><c:when test="${empty burger.satFatG}">정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.satFatG}" maxFractionDigits="1" /> g</c:otherwise></c:choose>
      </td></tr>
      <tr><th>당류</th><td>
        <c:choose><c:when test="${empty burger.sugarG}">정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.sugarG}" maxFractionDigits="1" /> g</c:otherwise></c:choose>
      </td></tr>
      <tr><th>나트륨</th><td>
        <c:choose><c:when test="${empty burger.sodiumMg}">정보 없음</c:when>
        <c:otherwise><fmt:formatNumber value="${burger.sodiumMg}" pattern="#,###" /> mg</c:otherwise></c:choose>
      </td></tr>
    </table>

    <div class="row">
      <%-- 추천 토글(B-03): 누르면 새로고침 없이 서버에 요청하고 최신 추천 수로 바꾼다 --%>
      <button class="btn big ${liked ? 'on' : ''}" id="like" type="button" aria-pressed="${liked}"
              data-url="${ctx}/burgers/like" data-id="${burger.id}">추천 <b id="likes">${burger.likeCount}</b></button>
      <span class="hint">조회 <fmt:formatNumber value="${burger.viewCount}" pattern="#,###" /></span>
      <%-- 관리자에게만 보이는 수정 버튼 (B-04). 실제 권한 검사는 AdminFilter 가 한다 --%>
      <c:if test="${sessionScope.loginMember.admin}">
        <a class="btn" href="${ctx}/admin/burgers/edit?id=${burger.id}">수정</a>
      </c:if>
    </div>
    <c:url var="loginUrl" value="/login"><c:param name="next" value="/burgers/detail?id=${burger.id}" /></c:url>
    <p class="hint" id="like-login" hidden>추천하려면 로그인이 필요합니다. <a href="${loginUrl}" style="color:var(--brand)">로그인하러 가기</a></p>
    <p class="error" id="like-error" hidden>추천을 처리하지 못했습니다. 잠시 뒤에 다시 시도해 주세요.</p>
  </div>
</div>

<div class="row between">
  <h2 class="section-title">이 버거의 꿀조합 · 꿀팁</h2>
  <div class="row">
    <c:if test="${not empty posts}"><a class="btn" href="${ctx}/posts?burger=${burger.id}">전체 보기</a></c:if>
    <a class="btn" href="${ctx}/posts/write?burger=${burger.id}">이 버거로 글쓰기</a>
  </div>
</div>
<div class="card">
  <table class="list">
    <c:forEach var="p" items="${posts}">
      <tr>
        <td><span class="cat">${p.categoryLabel}</span></td>
        <td class="title">
          <a href="${ctx}/posts/detail?id=${p.id}"><c:out value="${p.title}" /></a>
          <c:if test="${p.commentCount > 0}"><span class="cnt">[${p.commentCount}]</span></c:if>
        </td>
        <td class="hide-sm"><c:out value="${p.nickname}" /></td>
        <td>추천 ${p.likeCount}</td>
      </tr>
    </c:forEach>
    <c:if test="${empty posts}">
      <tr><td class="title hint">아직 등록된 글이 없습니다. 첫 꿀팁을 남겨 보세요.</td></tr>
    </c:if>
  </table>
</div>

<script src="${ctx}/js/like.js"></script>

<jsp:include page="/WEB-INF/views/footer.jsp" />
