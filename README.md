# 医疗影像管理系统

> TianJin 中软实训项目 — Medical Image Management System

一个基于 **Node.js + Vue 3** 的医疗影像管理系统，支持患者管理、检查记录管理、医疗影像上传与查看等功能。

---

## 🚀 技术栈

| 层次 | 技术 |
|------|------|
| 前端 | Vue 3 + Element Plus + Pinia + Vue Router |
| 后端 | Node.js + Express.js |
| 数据库 | SQLite (node:sqlite 内置模块) |
| 认证 | JWT (JSON Web Token) |
| 文件上传 | Multer |

---

## ✨ 功能特性

- 🔐 **用户认证** — 登录/登出，JWT Token 鉴权，角色权限控制（管理员/医生）
- 👥 **患者管理** — 患者档案的增删改查，支持关键词搜索
- 📋 **检查管理** — 检查记录创建、编辑、状态跟踪（待处理/已完成）
- 🖼️ **影像管理** — 支持多文件上传（JPG/PNG/BMP/DICOM等），影像预览，影像列表管理
- 📊 **工作台仪表板** — 统计概览，最近检查记录，检查类型分布，完成率图表
- 🏥 **用户管理** — 管理员可创建/删除系统用户（医生账号）

---

## 📦 快速开始

### 环境要求

- Node.js >= 22.5（使用内置 `node:sqlite` 模块）

### 安装依赖

```bash
# 安装后端依赖
cd backend
npm install

# 安装前端依赖
cd ../frontend
npm install
```

### 启动开发环境

**方式一：分别启动前后端（推荐开发）**

```bash
# 终端1：启动后端
cd backend
node src/app.js
# 后端运行在 http://localhost:3000

# 终端2：启动前端开发服务器
cd frontend
npm run dev
# 前端运行在 http://localhost:5173（通过代理访问后端）
```

**方式二：生产模式（后端同时提供前端静态文件）**

```bash
# 先构建前端
cd frontend
npm run build

# 启动后端（自动提供前端页面）
cd ../backend
node src/app.js
# 访问 http://localhost:3000
```

---

## 🔑 默认账号

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | admin123 | 管理员 |
| doctor1 | doctor123 | 医生 |

---

## 📁 项目结构

```
Medical-Image-System/
├── backend/                 # 后端服务
│   ├── src/
│   │   ├── app.js           # 应用入口
│   │   ├── db.js            # 数据库连接
│   │   ├── initDb.js        # 数据库初始化（建表 + 示例数据）
│   │   ├── controllers/     # 控制器
│   │   ├── routes/          # 路由
│   │   └── middleware/      # 中间件
│   ├── uploads/             # 上传文件存储目录
│   └── package.json
├── frontend/                # 前端应用
│   ├── src/
│   │   ├── views/           # 页面组件
│   │   ├── store/           # Pinia 状态管理
│   │   ├── router/          # 路由配置
│   │   └── api/             # API 封装
│   └── package.json
└── data/                    # SQLite 数据库文件（自动创建）
```

---

## 🌐 API 接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | /api/auth/login | 用户登录 |
| GET  | /api/patients | 患者列表（分页+搜索）|
| POST | /api/patients | 创建患者 |
| GET  | /api/examinations | 检查列表 |
| POST | /api/examinations | 创建检查 |
| GET  | /api/examinations/:id | 检查详情（含影像）|
| POST | /api/images/upload | 上传影像（multipart）|
| GET  | /api/images/:id/file | 获取影像文件 |
| GET  | /api/images/stats | 统计数据 |

---

## 📄 许可证

MIT License
