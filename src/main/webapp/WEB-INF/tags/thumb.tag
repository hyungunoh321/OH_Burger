<%@ tag pageEncoding="UTF-8" body-content="empty" description="버거 사진 자리. 사진 주소가 없거나 불러오지 못하면 CSS 로 그린 버거 표시가 보인다" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ attribute name="url" required="false" description="버거 사진 주소(image_url). 비어 있어도 된다" %>
<%@ attribute name="large" required="false" type="java.lang.Boolean" description="상세 화면용 큰 크기" %>
<%-- 사진은 브랜드 공식 사이트의 주소를 그대로 불러온다. 주소가 바뀌어 깨지면 onerror 가 사진을 떼어 낸다 --%>
<div class="thumb${large ? ' lg' : ''}${empty url ? '' : ' has-img'}" aria-hidden="true"><c:if test="${not empty url}"><img src="<c:out value="${url}" />" alt="" loading="lazy" referrerpolicy="no-referrer" onerror="this.parentNode.classList.remove('has-img'); this.remove();"></c:if></div>
