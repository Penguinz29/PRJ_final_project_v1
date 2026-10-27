# 1. Update style.css
with open('src/main/webapp/static/css/style.css', 'r', encoding='utf-8') as f:
    css = f.read()

old_css = """/* ═══════════════════════════════════════════
   HERO BANNER (Refined Cosmic edtech style)
═══════════════════════════════════════════ */
.hero-banner {
  background: linear-gradient(135deg, #1b0a50 0%, #240f6b 35%, #351382 70%, #461496 100%) !important;
  border-radius: 20px !important;
  padding: 2.1rem 2.3rem !important;
  color: #fff !important;
  margin-bottom: 1.25rem;
  position: relative;
  overflow: hidden;
  box-shadow: 0 10px 30px -5px rgba(24, 9, 74, 0.35) !important;
  min-height: 220px;
  display: flex;
  align-items: center;
}

.hero-banner-content {
  position: relative;
  z-index: 3;
  max-width: 58%;
}"""

new_css = """/* ═══════════════════════════════════════════
   HERO BANNER (Refined Cosmic edtech style)
═══════════════════════════════════════════ */
.hero-banner {
  background: linear-gradient(135deg, #1b0a50 0%, #240f6b 35%, #351382 70%, #461496 100%) !important;
  border-radius: 20px !important;
  padding: 2.1rem 2.3rem !important;
  color: #fff !important;
  margin-bottom: 1.25rem;
  position: relative;
  overflow: hidden;
  box-shadow: 0 10px 30px -5px rgba(24, 9, 74, 0.35) !important;
  min-height: 180px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.hero-banner-content {
  position: relative;
  z-index: 3;
  max-width: 60%;
  display: flex;
  flex-direction: column;
}

.hero-banner p:last-child {
  margin-bottom: 0 !important;
}"""

if old_css in css:
    css = css.replace(old_css, new_css)
else:
    import re
    css = re.sub(
        r'\.hero-banner\s*\{[^}]*display:\s*flex;[^}]*align-items:\s*center;[^}]*\}',
        """.hero-banner {
  background: linear-gradient(135deg, #1b0a50 0%, #240f6b 35%, #351382 70%, #461496 100%) !important;
  border-radius: 20px !important;
  padding: 2.1rem 2.3rem !important;
  color: #fff !important;
  margin-bottom: 1.25rem;
  position: relative;
  overflow: hidden;
  box-shadow: 0 10px 30px -5px rgba(24, 9, 74, 0.35) !important;
  min-height: 180px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}""",
        css
    )

with open('src/main/webapp/static/css/style.css', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(css)

# 2. Update teacher/dashboard.jsp
with open('src/main/webapp/WEB-INF/views/teacher/dashboard.jsp', 'r', encoding='utf-8') as f:
    tj = f.read()

old_teacher_hero = """                                        <%-- ── BLOCK 1: Hero + Stat Cards ── --%>
                                        <div class="hero-banner mb-4">
                                            <div class="hero-label">Bảng điều khiển giảng dạy</div>
                                            <h2>Xin chào,
                                                <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />!
                                            </h2>
                                            <p>Quản lý nội dung, theo dõi học sinh và chấm bài tự luận tại đây.</p>
                                        </div>"""

new_teacher_hero = """                                        <%-- ── BLOCK 1: Hero + Stat Cards ── --%>
                                        <div class="hero-banner mb-4">
                                            <div class="hero-banner-content">
                                                <div class="hero-label">Bảng điều khiển giảng dạy</div>
                                                <h2>Xin chào,
                                                    <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />!
                                                </h2>
                                                <p>Quản lý nội dung, theo dõi học sinh và chấm bài tự luận tại đây.</p>
                                            </div>
                                        </div>"""

if old_teacher_hero in tj:
    tj = tj.replace(old_teacher_hero, new_teacher_hero)
else:
    # in case of spacing difference
    import re
    pattern = r'<div class="hero-banner mb-4">\s*<div class="hero-label">Bảng điều khiển giảng dạy</div>.*?<p>Quản lý nội dung, theo dõi học sinh và chấm bài tự luận tại đây\.</p>\s*</div>'
    replacement = """<div class="hero-banner mb-4">
                                            <div class="hero-banner-content">
                                                <div class="hero-label">Bảng điều khiển giảng dạy</div>
                                                <h2>Xin chào,
                                                    <c:out value="${sessionScope.LOGGED_IN_USER.fullName}" />!
                                                </h2>
                                                <p>Quản lý nội dung, theo dõi học sinh và chấm bài tự luận tại đây.</p>
                                            </div>
                                        </div>"""
    tj = re.sub(pattern, replacement, tj, flags=re.DOTALL)

with open('src/main/webapp/WEB-INF/views/teacher/dashboard.jsp', 'w', encoding='utf-8', newline='\r\n') as f:
    f.write(tj)

print('Updated both style.css and teacher/dashboard.jsp successfully!')
