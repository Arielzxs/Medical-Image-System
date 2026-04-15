<script setup></script>

<template>
  <div class="footer">
    <div class="left">
      <span class="footer-icon">🏥</span>
      Copyright © 2025-2027 医疗影像管理系统 · All rights reserved.
    </div>
    <div class="right">
      <a target="_blank" href="#" class="footer-link">帮助文档</a>
      <span class="divider">|</span>
      <a target="_blank" href="#" class="footer-link">关于我们</a>
    </div>
  </div>
</template>

<style scoped>
.footer {
  height: 48px;
  border-top: 1px solid #edf0f5;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
  background: #fff;
  flex-shrink: 0;
}

.left {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #9baab8;
}

.footer-icon {
  font-size: 14px;
}

.right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.footer-link {
  font-size: 12px;
  color: #9baab8;
  text-decoration: none;
  transition: color 0.2s;
}

.footer-link:hover {
  color: #1890ff;
}

.divider {
  color: #dce4ee;
  font-size: 12px;
}
</style>
