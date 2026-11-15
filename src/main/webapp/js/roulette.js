// 조건부 랜덤 버거 룰렛 (R-01)
// 회전 · 당첨 로직은 프로토타입(docs/wireframe/roulette.html)의 것이고, 후보 목록만 서버에서 받는다.
(function () {
  var MAX = 12; // 룰렛에 올리는 최대 후보 수
  // 버거 재료 색: 토마토, 번, 치즈, 상추, 패티, 구운 번
  var COLORS = ['#d43a2f', '#e0842a', '#d9a400', '#5f9a2f', '#7a5a44', '#a9621a'];
  var DURATION = 4000; // 회전 시간(ms)

  var root = document.getElementById('roulette');
  var base = root.dataset.ctx;
  var form = document.getElementById('conditions');
  var canvas = document.getElementById('wheel');
  var g = canvas.getContext('2d');
  var countEl = document.getElementById('count');
  var spinBtn = document.getElementById('spin');
  var resultEl = document.getElementById('result');

  var candidates = []; // 룰렛에 올린 후보 (최대 MAX 개)
  var rot = 0;         // 판의 현재 각도(라디안)
  var spinning = false;
  var requestNo = 0;   // 늦게 도착한 예전 응답을 버리기 위한 번호
  var emptyText = '후보를 불러오는 중입니다…';

  // 후보가 많으면 무작위로 MAX 개만 고른다 (피셔-예이츠 섞기)
  function pick(list) {
    var copy = list.slice();
    for (var i = copy.length - 1; i > 0; i--) {
      var j = Math.floor(Math.random() * (i + 1));
      var tmp = copy[i]; copy[i] = copy[j]; copy[j] = tmp;
    }
    return copy.slice(0, MAX);
  }

  function draw() {
    var R = canvas.width / 2;
    g.clearRect(0, 0, canvas.width, canvas.height);
    g.save();
    g.translate(R, R);
    if (candidates.length === 0) {
      g.fillStyle = '#f8eedc';
      g.beginPath(); g.arc(0, 0, R - 10, 0, Math.PI * 2); g.fill();
      g.fillStyle = '#8a7867'; g.font = '600 34px Pretendard, sans-serif'; g.textAlign = 'center';
      g.fillText(emptyText, 0, 12);
      g.restore();
      return;
    }
    g.rotate(rot);
    var seg = (Math.PI * 2) / candidates.length;
    candidates.forEach(function (b, i) {
      g.beginPath();
      g.moveTo(0, 0);
      g.arc(0, 0, R - 10, i * seg, (i + 1) * seg);
      g.closePath();
      // 조각 수가 색 수의 배수 + 1 이면 처음과 끝 색이 같아지므로 마지막 조각만 다른 색을 쓴다
      var last = i === candidates.length - 1 && i % COLORS.length === 0 && i > 0;
      g.fillStyle = COLORS[last ? 3 : i % COLORS.length];
      g.fill();
      g.strokeStyle = '#fff'; g.lineWidth = 4; g.stroke();
      g.save();
      g.rotate(i * seg + seg / 2);
      g.fillStyle = '#fff'; g.font = '700 28px Pretendard, sans-serif'; g.textAlign = 'right'; g.textBaseline = 'middle';
      var name = b.name.length > 9 ? b.name.slice(0, 8) + '…' : b.name;
      g.fillText(name, R - 34, 0);
      g.restore();
    });
    g.restore();
    g.beginPath(); g.arc(R, R, 44, 0, Math.PI * 2);
    g.fillStyle = '#fffbf4'; g.fill();
    g.beginPath(); g.arc(R, R, 26, 0, Math.PI * 2);
    g.fillStyle = '#5a3520'; g.fill();
  }

  // 값이 없는(null) 항목은 "정보 없음"으로 보여 준다
  function describe(b) {
    return [
      b.price == null ? '가격 정보 없음' : b.price.toLocaleString('ko-KR') + '원',
      b.kcal == null ? '열량 정보 없음' : b.kcal + 'kcal',
      b.protein == null ? '단백질 정보 없음' : '단백질 ' + b.protein + 'g'
    ].join(' · ');
  }

  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (text != null) node.textContent = text; // textContent 라서 이름에 특수 문자가 있어도 안전하다
    return node;
  }

  // 당첨 카드: 버거 정보 + "상세 보기", "다시 돌리기"
  function show(b) {
    var card = el('div', 'card result');
    var thumb = el('div', 'thumb');
    thumb.setAttribute('aria-hidden', 'true');
    if (b.image) {
      // 사진이 안 뜨면 thumb.tag 와 같이 CSS 버거 표시로 돌아간다
      var img = el('img');
      img.alt = '';
      img.referrerPolicy = 'no-referrer';
      img.onerror = function () { thumb.classList.remove('has-img'); thumb.removeChild(img); };
      img.src = b.image;
      thumb.classList.add('has-img');
      thumb.appendChild(img);
    }
    var info = el('div');
    info.style.flex = '1';
    info.appendChild(el('div', 'hint', '오늘의 버거는'));
    info.appendChild(el('div', 'name', b.brand + ' ' + b.name));
    info.appendChild(el('div', 'hint', describe(b)));
    var detail = el('a', 'btn primary', '상세 보기');
    detail.href = base + '/burgers/detail?id=' + encodeURIComponent(b.id);
    card.appendChild(thumb);
    card.appendChild(info);
    card.appendChild(detail);
    // 후보가 하나뿐이면 다시 돌려도 같은 결과라 버튼을 두지 않는다
    if (candidates.length > 1) {
      var again = el('button', 'btn', '다시 돌리기');
      again.type = 'button';
      again.addEventListener('click', spin);
      card.appendChild(again);
    }
    resultEl.textContent = '';
    resultEl.appendChild(card);
  }

  function setBusy(busy) {
    spinning = busy;
    spinBtn.disabled = busy || candidates.length === 0;
    // 도는 동안에는 조건을 바꾸지 못하게 한다
    Array.prototype.forEach.call(form.elements, function (field) {
      if (field !== spinBtn) field.disabled = busy;
    });
  }

  function spin() {
    if (spinning || candidates.length === 0) return;
    if (candidates.length === 1) { show(candidates[0]); return; } // 후보가 하나면 바로 결과
    setBusy(true);
    resultEl.textContent = '';
    var seg = (Math.PI * 2) / candidates.length;
    var winner = Math.floor(Math.random() * candidates.length);
    // 당첨 조각의 가운데가 위쪽 화살표(-90도)에 오도록 최종 각도를 정하고 5바퀴 이상 돌린다
    var start = rot;
    var target = -Math.PI / 2 - (winner + 0.5) * seg;
    while (target < start + Math.PI * 10) target += Math.PI * 2;
    var t0 = performance.now();
    (function frame(now) {
      var t = Math.min((now - t0) / DURATION, 1);
      rot = start + (target - start) * (1 - Math.pow(1 - t, 3)); // 점점 느려지는 회전
      draw();
      if (t < 1) {
        requestAnimationFrame(frame);
      } else {
        setBusy(false);
        spinBtn.textContent = '다시 돌리기';
        show(candidates[winner]);
      }
    })(t0);
  }

  // 조건으로 서버에 후보를 물어보고 룰렛 판을 다시 만든다
  function refresh() {
    var no = ++requestNo;
    var params = new URLSearchParams();
    Array.prototype.forEach.call(form.querySelectorAll('input[name=brand]:checked'), function (box) {
      params.append('brand', box.value);
    });
    ['patty', 'maxPrice', 'maxKcal'].forEach(function (name) {
      if (form.elements[name].value) params.append(name, form.elements[name].value);
    });

    fetch(base + '/roulette/candidates?' + params.toString())
      .then(function (res) {
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
      })
      .then(function (data) {
        if (no !== requestNo) return; // 그사이 조건이 또 바뀌었으면 버린다
        var all = data.burgers;
        candidates = pick(all);
        emptyText = '조건에 맞는 버거가 없습니다';
        countEl.textContent = all.length === 0
          ? '조건에 맞는 버거가 없습니다. 조건을 바꿔 보세요.'
          : '조건에 맞는 버거 ' + all.length + '개' + (all.length > MAX ? ' (그중 ' + MAX + '개를 무작위로 올림)' : '');
        finish();
      })
      .catch(function () {
        if (no !== requestNo) return;
        candidates = [];
        emptyText = '후보를 불러오지 못했습니다';
        countEl.textContent = '후보를 불러오지 못했습니다. 잠시 뒤에 다시 시도해 주세요.';
        finish();
      });

    function finish() {
      spinBtn.disabled = candidates.length === 0;
      spinBtn.textContent = '룰렛 돌리기';
      resultEl.textContent = '';
      rot = 0;
      draw();
    }
  }

  form.addEventListener('change', function () { if (!spinning) refresh(); });
  spinBtn.addEventListener('click', spin);
  draw();
  refresh();
})();
