<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 버거 등록 · 수정 공통 화면 (B-04). 서블릿이 heading, action, cancelUrl, form, brands, pattyLabels 를 넘긴다 --%>
<jsp:include page="/WEB-INF/views/header.jsp">
  <jsp:param name="title" value="${heading}" />
  <jsp:param name="menu" value="admin" />
</jsp:include>

<h1 class="page-title"><c:out value="${heading}" /></h1>
<p class="page-desc">가격과 영양 정보는 확인한 값만 넣고, 모르는 칸은 비워 둡니다. 비운 칸은 "정보 없음"으로 표시됩니다.</p>

<c:if test="${restored}">
  <p class="notice">로그인이 풀려 다시 로그인했습니다. 입력하던 내용을 되살렸으니 확인하고 저장해 주세요.</p>
</c:if>

<form class="card pad" method="post" action="${ctx}${action}">
  <div class="form-grid">
    <label class="field">
      <span>브랜드</span>
      <select class="input" name="brandId" required>
        <option value="">선택</option>
        <c:forEach var="br" items="${brands}">
          <option value="${br.id}" ${br.id eq form.values.brandId ? 'selected' : ''}><c:out value="${br.name}" /></option>
        </c:forEach>
      </select>
      <c:if test="${not empty form.errors.brandId}"><span class="error"><c:out value="${form.errors.brandId}" /></span></c:if>
    </label>
    <label class="field">
      <span>패티 종류</span>
      <select class="input" name="pattyType" required>
        <c:forEach var="p" items="${pattyLabels}">
          <option value="${p.key}" ${p.key eq form.values.pattyType ? 'selected' : ''}><c:out value="${p.value}" /></option>
        </c:forEach>
      </select>
      <c:if test="${not empty form.errors.pattyType}"><span class="error"><c:out value="${form.errors.pattyType}" /></span></c:if>
    </label>
  </div>

  <label class="field">
    <span>이름</span>
    <input class="input" name="name" value="<c:out value="${form.values.name}" />" maxlength="${nameMax}" required
           placeholder="버거 이름 (${nameMax}자 이내)">
    <c:if test="${not empty form.errors.name}"><span class="error"><c:out value="${form.errors.name}" /></span></c:if>
  </label>

  <label class="field">
    <span>설명 <span class="hint">(선택)</span></span>
    <textarea class="input short" name="description" maxlength="${descriptionMax}"
              placeholder="버거 소개 (${descriptionMax}자 이내)"><c:out value="${form.values.description}" /></textarea>
    <c:if test="${not empty form.errors.description}"><span class="error"><c:out value="${form.errors.description}" /></span></c:if>
  </label>

  <label class="field">
    <span>사진 주소 <span class="hint">(선택)</span></span>
    <input class="input" name="imageUrl" value="<c:out value="${form.values.imageUrl}" />" maxlength="${imageUrlMax}"
           placeholder="https:// 로 시작하는 사진 주소">
    <c:if test="${not empty form.errors.imageUrl}"><span class="error"><c:out value="${form.errors.imageUrl}" /></span></c:if>
  </label>

  <div class="form-grid">
    <label class="field">
      <span>가격 (원)</span>
      <input class="input" name="price" value="<c:out value="${form.values.price}" />" inputmode="numeric" maxlength="12">
      <c:if test="${not empty form.errors.price}"><span class="error"><c:out value="${form.errors.price}" /></span></c:if>
    </label>
    <label class="field">
      <span>중량 (g)</span>
      <input class="input" name="weightG" value="<c:out value="${form.values.weightG}" />" inputmode="numeric" maxlength="12">
      <c:if test="${not empty form.errors.weightG}"><span class="error"><c:out value="${form.errors.weightG}" /></span></c:if>
    </label>
    <label class="field">
      <span>열량 (kcal)</span>
      <input class="input" name="caloriesKcal" value="<c:out value="${form.values.caloriesKcal}" />" inputmode="numeric" maxlength="12">
      <c:if test="${not empty form.errors.caloriesKcal}"><span class="error"><c:out value="${form.errors.caloriesKcal}" /></span></c:if>
    </label>
    <label class="field">
      <span>단백질 (g)</span>
      <input class="input" name="proteinG" value="<c:out value="${form.values.proteinG}" />" inputmode="decimal" maxlength="12">
      <c:if test="${not empty form.errors.proteinG}"><span class="error"><c:out value="${form.errors.proteinG}" /></span></c:if>
    </label>
    <label class="field">
      <span>포화지방 (g)</span>
      <input class="input" name="satFatG" value="<c:out value="${form.values.satFatG}" />" inputmode="decimal" maxlength="12">
      <c:if test="${not empty form.errors.satFatG}"><span class="error"><c:out value="${form.errors.satFatG}" /></span></c:if>
    </label>
    <label class="field">
      <span>당류 (g)</span>
      <input class="input" name="sugarG" value="<c:out value="${form.values.sugarG}" />" inputmode="decimal" maxlength="12">
      <c:if test="${not empty form.errors.sugarG}"><span class="error"><c:out value="${form.errors.sugarG}" /></span></c:if>
    </label>
    <label class="field">
      <span>나트륨 (mg)</span>
      <input class="input" name="sodiumMg" value="<c:out value="${form.values.sodiumMg}" />" inputmode="numeric" maxlength="12">
      <c:if test="${not empty form.errors.sodiumMg}"><span class="error"><c:out value="${form.errors.sodiumMg}" /></span></c:if>
    </label>
  </div>

  <div class="row end">
    <a class="btn" href="${ctx}${cancelUrl}">취소</a>
    <button class="btn primary" type="submit">저장</button>
  </div>
</form>

<jsp:include page="/WEB-INF/views/footer.jsp" />
