#!/usr/bin/env python3
"""Generate ZYmusic technical roadmap as a high-quality image."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Arc
import numpy as np

# Use Chinese font
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei', 'SimHei']
plt.rcParams['axes.unicode_minus'] = False

fig, ax = plt.subplots(1, 1, figsize=(28, 16))
ax.set_xlim(0, 28)
ax.set_ylim(0, 16)
ax.axis('off')
ax.set_facecolor('#F7F8FC')
fig.patch.set_facecolor('#F7F8FC')

# ============ Color palette (matching reference image) ============
C_TITLE_BG = '#1A3C6E'      # 深蓝 - 标题背景
C_SECTION_BG = '#2B579A'     # 中蓝 - 区块标题
C_BLUE_L = '#5B9BD5'         # 浅蓝
C_BLUE_LL = '#BDD7EE'        # 很浅蓝
C_GREEN_D = '#1E6B4A'        # 深绿
C_GREEN = '#2D8C5E'          # 中绿
C_GREEN_L = '#4CAF50'        # 浅绿
C_ORANGE = '#E67E22'         # 橙色
C_ORANGE_L = '#F5CBA7'       # 浅橙
C_PURPLE = '#7B3FA0'         # 紫色
C_PURPLE_L = '#D2B4DE'       # 浅紫
C_RED = '#C0392B'            # 红色
C_TEAL = '#008080'           # 青色
C_WHITE = '#FFFFFF'
C_BLACK = '#2C3E50'
C_GRAY = '#7F8C8D'
C_LGRAY = '#ECF0F1'
C_BORDER = '#BDC3C7'

def add_box(ax, x, y, w, h, color, text='', fontsize=10, text_color='white', bold=True, edge_color=None, linewidth=1.5):
    """Add a rounded box with text."""
    box = FancyBboxPatch((x, y), w, h,
                         boxstyle="round,pad=0.15",
                         facecolor=color,
                         edgecolor=edge_color if edge_color else color,
                         linewidth=linewidth,
                         zorder=2)
    ax.add_patch(box)
    if text:
        ax.text(x + w/2, y + h/2, text, ha='center', va='center',
                fontsize=fontsize, color=text_color, fontweight='bold' if bold else 'normal',
                zorder=3)
    return box

def add_rect(ax, x, y, w, h, color, text='', fontsize=9, text_color='white', bold=False):
    """Add a rectangle with text."""
    rect = plt.Rectangle((x, y), w, h, facecolor=color, edgecolor=color, linewidth=1, zorder=2)
    ax.add_patch(rect)
    if text:
        ax.text(x + w/2, y + h/2, text, ha='center', va='center',
                fontsize=fontsize, color=text_color, fontweight='bold' if bold else 'normal', zorder=3)
    return rect

def add_arrow(ax, x1, y1, x2, y2, color=C_GRAY, lw=2):
    """Add a line/arrow."""
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=lw, connectionstyle='arc3,rad=0'))
    # For straight lines with arrow heads
    ax.plot([x1, x2], [y1, y2], color=color, linewidth=lw, zorder=1)

def add_section_label(ax, x, y, w, h, color, text):
    """Add a section header bar."""
    rect = plt.Rectangle((x, y), w, h, facecolor=color, edgecolor=color, linewidth=0, zorder=2)
    ax.add_patch(rect)
    ax.text(x + w/2, y + h/2, text, ha='center', va='center',
            fontsize=12, color='white', fontweight='bold', zorder=3)

# ============ MAIN TITLE ============
add_box(ax, 0.5, 15.0, 27, 0.7, C_TITLE_BG,
        'ZY音乐系统技术路线图', fontsize=18, text_color='white', bold=True, linewidth=0)

# ============ THREE COLUMNS LAYOUT ============
# Column 1: 设计思路 (Design Ideas)  -  x: 0.5-8.5
# Column 2: 设计内容 (Design Content) - x: 9.0-19.0
# Column 3: 设计方法 (Design Methods) - x: 19.5-27.5

col_w = 8.0
col_gap = 0.5
c1_x = 0.5
c2_x = 9.0
c3_x = 19.5

# Column headers
header_h = 0.55
header_y = 14.2
add_section_label(ax, c1_x, header_y, col_w, header_h, C_BLUE_L, '设计思路')
add_section_label(ax, c2_x, header_y, 10, header_h, C_GREEN, '设计内容')
add_section_label(ax, c3_x, header_y, 8, header_h, C_ORANGE, '设计方法')

# ============ COLUMN 1: 设计思路 ============
ideas = [
    ('需求驱动', '#2B579A', '以用户自主管理音乐资源\n和社交互动为核心需求\n构建全平台音乐社交系统'),
    ('分层解耦', '#3D7EC5', '采用五层分层架构\n(表现-控制-逻辑-数据-存储)\n实现模块松耦合与职责分离'),
    ('算法选型', '#1E6B4A', '基于场景特征权衡选择\n邻接表模型、有限状态机\nRange分段传输等成熟方案'),
    ('三端统一', '#7B3FA0', '同一套核心代码\n浏览器+桌面(JavaFX)\n+移动端(PWA)统一交付'),
    ('数据安全', '#C0392B', '幂等迁移保障数据完整性\nWAL日志模式支持并发\n相对路径提升可移植性'),
]

idea_y_start = 13.2
idea_h = 2.0
idea_gap = 0.3
for i, (title, color, desc) in enumerate(ideas):
    y = idea_y_start - i * (idea_h + idea_gap)
    # Title bar
    add_rect(ax, c1_x, y + idea_h - 0.45, col_w, 0.45, color, title, fontsize=10, bold=True)
    # Description
    ax.text(c1_x + col_w/2, y + idea_h/2 - 0.25, desc, ha='center', va='center',
            fontsize=8.5, color=C_BLACK, linespacing=1.5)

# ============ COLUMN 2: 设计内容 ============
# Sub-layers within design content
content_items = [
    # (y, height, section_title, section_color, items: [(text, color)])
    (13.2, 1.6, '用户终端层', '#1A3C6E', [
        ('浏览器端\n(Chrome/Edge/Firefox)', '#2B579A'),
        ('桌面客户端\n(JavaFX WebView)', '#1E6B4A'),
        ('移动端PWA\n(Service Worker)', '#7B3FA0'),
    ]),
    (11.2, 1.6, '表现层 & 控制层', '#2B579A', [
        ('JSP动态模板\n页面渲染', '#3D7EC5'),
        ('CSS3动画样式\n响应式布局', '#5B9BD5'),
        ('JavaScript交互\n播放/裁剪/异步', '#008080'),
        ('Servlet分发\n路由/鉴权/转发', '#2B579A'),
    ]),
    (9.2, 1.6, '业务逻辑层 (Service)', '#2D8C5E', [
        ('UserService\n用户认证', '#1A3C6E'),
        ('MusicService\n音乐管理', '#2B579A'),
        ('PlaylistService\n歌单组织', '#1E6B4A'),
        ('CommentService\n评论交互', '#2D8C5E'),
        ('PostService\n社区内容', '#E67E22'),
        ('SearchService\n综合检索', '#7B3FA0'),
    ]),
    (7.2, 1.6, '数据访问层 & 存储层', '#E67E22', [
        ('JDBC访问\n参数化查询', '#2B579A'),
        ('SQLite数据库\nWAL/幂等迁移', '#1E6B4A'),
        ('文件系统\n分类存储', '#E67E22'),
        ('Jetty服务器\n嵌入式部署', '#7B3FA0'),
    ]),
]

for (cy, ch, section_title, section_color, items) in content_items:
    # Section header
    add_rect(ax, c2_x, cy + ch - 0.4, 10, 0.4, section_color, section_title, fontsize=9, bold=True)
    # Items within section
    n_items = len(items)
    item_w = (10 - 0.1 * (n_items + 1)) / n_items
    for j, (item_text, item_color) in enumerate(items):
        ix = c2_x + 0.1 + j * (item_w + 0.1)
        add_box(ax, ix, cy + 0.05, item_w, ch - 0.55, item_color, item_text,
                fontsize=7.5, text_color='white', bold=False, linewidth=0.5)
    # Down arrow between sections
    if cy > 7.5:
        ax.annotate('', xy=(c2_x + 5, cy - 0.05), xytext=(c2_x + 5, cy + 0.3),
                    arrowprops=dict(arrowstyle='->', color=C_GRAY, lw=2.5))

# ============ COLUMN 3: 设计方法 ============
methods = [
    ('后端核心算法', '#C0392B', [
        ('邻接表模型', '评论嵌套树存储与\n单表自引用查询'),
        ('LIKE模式匹配', '四维度通配符\n模糊音乐检索'),
        ('Toggle原子操作', '检查-切换-计数\n三步骤状态翻转'),
        ('HTTP Range传输', 'Range解析/边界校验\n随机访问/分段缓冲'),
        ('元数据列检测', '幂等建表+增量列补充\n零数据损失版本演进'),
    ]),
    ('前端核心算法', '#1E6B4A', [
        ('IIFE单例模式', '闭包封装+标志位守卫\n全局唯一Audio实例'),
        ('有限状态机', '三模式环形转换\n拒绝采样随机播放'),
        ('Canvas仿射变换', 'baseScale/zoomScale\n拖拽裁剪/Base64导出'),
        ('Cache-First策略', 'SW缓存优先+网络回退\n版本化缓存清理'),
        ('递归树遍历', '标识符映射+子节点表\nO(n)深度优先递归渲染'),
    ]),
]

method_y = 13.2
for (section_title, section_color, items) in methods:
    method_y -= 0.15
    # Section header
    add_rect(ax, c3_x, method_y, 8, 0.4, section_color, section_title, fontsize=9, bold=True)
    method_y -= 0.05
    for (algo_name, algo_desc) in items:
        method_y -= 0.52
        # Algorithm name box (colored)
        add_box(ax, c3_x, method_y, 3.2, 0.47, '#3498DB' if section_title.startswith('后端') else '#2D8C5E',
                algo_name, fontsize=8, text_color='white', bold=True, linewidth=0.5)
        # Algorithm description text
        ax.text(c3_x + 3.35, method_y + 0.23, algo_desc, ha='left', va='center',
                fontsize=7.2, color=C_BLACK, linespacing=1.3)
    method_y -= 0.25

# ============ BOTTOM: 关键技术栈 ============
tech_y = 5.8
add_rect(ax, 0.5, tech_y + 0.2, 27, 0.35, C_TITLE_BG, '', fontsize=9, bold=False)
ax.text(14, tech_y + 0.37, '关键技术栈', ha='center', va='center', fontsize=10, color='white', fontweight='bold')

techs = [
    ('Java 17', '#1A3C6E'), ('Servlet 4.0', '#2B579A'), ('JSP 2.3', '#3D7EC5'),
    ('Jetty 9.4', '#5B9BD5'), ('JDBC', '#1E6B4A'), ('SQLite 3', '#2D8C5E'),
    ('HTML5', '#4CAF50'), ('CSS3', '#E67E22'), ('JavaScript ES6', '#F0A050'),
    ('Canvas API', '#7B3FA0'), ('Fetch API', '#9B6BC0'), ('Service Worker', '#008080'),
    ('JavaFX', '#2B579A'), ('Maven 3', '#1E6B4A'), ('Gson', '#3D7EC5'),
    ('FFmpeg', '#E67E22'), ('UUID', '#7B3FA0'),
]
tech_w = 1.5; tech_h = 0.35; tech_gap = 0.08
items_per_row = 8
for i, (name, color) in enumerate(techs):
    row = i // items_per_row
    col = i % items_per_row
    tx = 0.5 + col * (tech_w + tech_gap)
    ty = tech_y - 0.35 - row * (tech_h + 0.06)
    add_rect(ax, tx, ty, tech_w, tech_h, color, name, fontsize=8, bold=False)

# ============ Connecting elements between columns ============
# Add subtle connecting indicators
for i in range(5):
    y = 13.0 - i * 2.2
    ax.plot([c1_x + col_w, c2_x], [y, y], color='#BDC3C7', linewidth=1, linestyle=':', zorder=0)

# ============ BOTTOM: Architecture flow summary ============
flow_y = 4.6
flow_colors = ['#1A3C6E', '#2B579A', '#2D8C5E', '#E67E22']
flow_labels = ['浏览器 / 桌面 / PWA', 'JSP + Servlet + Service', 'JDBC + DAO', 'SQLite + FileSystem']
flow_arrows = ['→', '→', '→']
flow_x_start = 5.5
flow_box_w = 4.0; flow_box_h = 0.45; flow_gap = 0.8
for i, (label, color) in enumerate(zip(flow_labels, flow_colors)):
    fx = flow_x_start + i * (flow_box_w + flow_gap)
    add_box(ax, fx, flow_y, flow_box_w, flow_box_h, color, label, fontsize=9, bold=False, linewidth=0.5)
    if i < 3:
        ax.text(fx + flow_box_w + 0.05, flow_y + flow_box_h/2, '→', ha='center', va='center',
                fontsize=18, color=C_GRAY, fontweight='bold')

ax.text(14, flow_y + 0.65, '数据流向：用户请求 → 控制层分发 → 业务处理 → 数据持久化 → 响应返回',
        ha='center', va='center', fontsize=9, color=C_GRAY, style='italic')

# ============ FOOTER ============
ax.text(14, 0.3, 'ZY音乐系统  |  Java Web全栈架构  |  嵌入式部署 + 三端统一访问',
        ha='center', va='center', fontsize=8, color=C_GRAY)

# ============ SAVE ============
output = 'F:/ZYmusic(2)/ZY音乐技术路线图.png'
plt.tight_layout(pad=0.5)
plt.savefig(output, dpi=180, bbox_inches='tight', facecolor='#F7F8FC', edgecolor='none')
plt.close()
print(f'Saved: {output}')
