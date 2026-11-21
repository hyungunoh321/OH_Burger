<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
</main>
<footer class="site-footer"><div class="container">OH Burger</div></footer>
<script>
  // 좁은 화면에서는 상단 메뉴가 옆으로 밀리므로, 지금 화면의 메뉴가 보이게 미리 밀어 둔다
  (function () {
    var nav = document.querySelector('.nav');
    var on = nav && nav.querySelector('a.active');
    if (on && nav.scrollWidth > nav.clientWidth) {
      nav.scrollLeft = on.offsetLeft - nav.offsetLeft - (nav.clientWidth - on.offsetWidth) / 2;
    }
  })();
</script>
</body>
</html>
