# 模块登记

## 目录
- 前端（ui）
  - Token 存储与登录态

## 索引
- Token Cookie Key（ui/src/utils/storage.ts）
  - 规则：${VITE_TOKEN_KEY || 'token'}_${端口号}
  - 端口号：location.port；为空时 https=443 / http=80
