// 추천 버튼 공통 스크립트 (버거 상세 B-03, 게시글 상세 P-05)
//
// 화면에 필요한 것
//   <button id="like" data-url="추천 주소" data-id="번호"> ... <b id="likes">추천 수</b></button>
//   <p id="like-login" hidden>  비회원 안내 (401)
//   <p id="like-own" hidden>    자기 글 안내 (403, 게시글에만 있음)
//   <p id="like-error" hidden>  그 밖의 실패
(function () {
  var btn = document.getElementById('like');
  if (!btn) return;

  var messages = ['like-login', 'like-own', 'like-error'];

  function show(id) {
    var el = document.getElementById(id);
    if (el) el.hidden = false;
  }

  btn.addEventListener('click', function () {
    btn.disabled = true; // 응답이 오기 전에 또 누르지 못하게
    messages.forEach(function (id) {
      var el = document.getElementById(id);
      if (el) el.hidden = true;
    });

    fetch(btn.dataset.url, {
      method: 'POST',
      // 서버는 이 헤더가 있는 요청만 받는다 (다른 사이트의 양식으로는 붙일 수 없음)
      headers: { 'X-Requested-With': 'fetch', 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'id=' + encodeURIComponent(btn.dataset.id)
    }).then(function (res) {
      if (res.status === 401) { show('like-login'); return null; }
      if (res.status === 403) {
        return res.json().then(function (data) {
          if (data.error === 'own') { show('like-own'); return null; }
          throw new Error('forbidden');
        });
      }
      if (!res.ok) throw new Error('HTTP ' + res.status);
      return res.json();
    }).then(function (data) {
      if (!data) return;
      btn.classList.toggle('on', data.liked);
      btn.setAttribute('aria-pressed', data.liked);
      document.getElementById('likes').textContent = data.likeCount;
    }).catch(function () {
      show('like-error');
    }).then(function () {
      btn.disabled = false;
    });
  });
})();
