<script setup>
import { ref, onMounted, onUnmounted, reactive, watch, nextTick } from "vue";
import { useAdminStore } from "@/stores/admin";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  getConversations,
  getMessagesWithUser,
  deleteConversation,
  deleteMessage,
} from "@/apis/message";
import { searchUsers } from "@/apis/user";
import { searchImages, getImageById } from "@/apis/image";
import {
  Promotion,
  Plus,
  Search,
  Picture,
  Delete,
  Close,
  Files,
  ArrowUp,
  ArrowDown,
} from "@element-plus/icons-vue";
import Stomp from "stompjs";
import SockJS from "sockjs-client";

const store = useAdminStore();
const currentUserId = store.getAdmin.id;

const conversations = ref([]);
const selectedConversation = ref(null);
const messages = ref([]);
const newMessage = ref("");
const loading = ref(false);
const chatArea = ref(null);
let stompClient = null;

// --- 滚动功能 (Anchor 锚点核心实现) ---
// 该函数通过消息的ID或索引找到对应的DOM元素，并平滑滚动到该位置
const scrollToMessage = (messageId, index) => {
  nextTick(() => {
    const targetId = `message-${messageId || index}`;
    const element = document.getElementById(targetId);
    if (element) {
      // scrollIntoView 是实现锚点滚动的关键方法
      element.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  });
};

const scrollToBottom = () => {
  nextTick(() => {
    if (chatArea.value) {
      chatArea.value.scrollTop = chatArea.value.scrollHeight;
    }
  });
};

// --- 影像信息缓存 ---
const imageCache = reactive(new Map());

const getCachedImage = async (imageId) => {
  if (!imageId) return null;
  if (imageCache.has(imageId)) {
    return imageCache.get(imageId);
  }
  try {
    const res = await getImageById(imageId);
    if (res.state === 0 && res.data) {
      imageCache.set(imageId, res.data);
      return res.data;
    } else {
      imageCache.set(imageId, null);
      return null;
    }
  } catch (error) {
    imageCache.set(imageId, null);
  }
  return null;
};

watch(
  messages,
  async (newMessages) => {
    const imagePromises = newMessages
      .filter(
        (msg) =>
          msg.type === "share" && msg.imageId && !imageCache.has(msg.imageId)
      )
      .map((msg) => getCachedImage(msg.imageId));
    await Promise.all(imagePromises);
    scrollToBottom();
  },
  { deep: true, immediate: true }
);

// --- 新建消息功能 ---
const newConversationDialogVisible = ref(false);
const userSearchKeyword = ref("");
const userSearchResults = ref([]);
const searching = ref(false);

const openNewConversationDialog = () => {
  userSearchKeyword.value = "";
  userSearchResults.value = [];
  newConversationDialogVisible.value = true;
};

const handleUserSearch = async () => {
  if (!userSearchKeyword.value.trim()) return;
  searching.value = true;
  try {
    const res = await searchUsers(userSearchKeyword.value);
    userSearchResults.value = res.data.filter(
      (user) => user.id !== currentUserId
    );
  } catch (error) {
    ElMessage.error("用户搜索失败");
  } finally {
    searching.value = false;
  }
};

const startConversationWith = (user) => {
  const existingConv = conversations.value.find((c) => c.id === user.id);
  if (existingConv) {
    selectConversation(existingConv);
  } else {
    const newConv = {
      id: user.id,
      username: user.username,
      lastMessage: "开始新的对话",
    };
    conversations.value.unshift(newConv);
    selectConversation(newConv);
  }
  newConversationDialogVisible.value = false;
};

const fetchConversations = async () => {
  loading.value = true;
  try {
    const res = await getConversations(currentUserId);
    conversations.value = res.data;
    if (conversations.value.length > 0 && !selectedConversation.value) {
      await selectConversation(conversations.value[0]);
    }
  } catch (error) {
    ElMessage.error("加载会话列表失败");
  } finally {
    loading.value = false;
  }
};

const selectConversation = async (conversation) => {
  selectedConversation.value = conversation;
  messages.value = [];
  try {
    const res = await getMessagesWithUser(currentUserId, conversation.id);
    messages.value = res.data;
  } catch (error) {
    ElMessage.error("加载消息失败");
  }
};

const handleSendMessage = () => {
  if (!newMessage.value.trim() || !selectedConversation.value) return;
  const messageData = {
    senderId: currentUserId,
    recipientId: selectedConversation.value.id,
    content: newMessage.value,
    type: "text",
  };
  if (stompClient && stompClient.connected) {
    stompClient.send("/app/chat", {}, JSON.stringify(messageData));
    messages.value.push({
      ...messageData,
      createdAt: new Date().toISOString(),
    });
    newMessage.value = "";
  } else {
    ElMessage.error("消息发送失败，连接已断开");
  }
};

// --- 发送影像 ---
const imageDialogVisible = ref(false);
const imageSearchResults = ref([]);
const imageSearching = ref(false);
const imageSearchKeyword = ref("");

const openImageDialog = async () => {
  imageDialogVisible.value = true;
  imageSearchKeyword.value = "";
  imageSearchResults.value = [];
};

const handleImageSearch = async () => {
  imageSearching.value = true;
  try {
    const params = { PatientName: imageSearchKeyword.value };
    const res = await searchImages("by-patient-name", params);
    imageSearchResults.value = res.data;
  } catch (error) {
    ElMessage.error("影像搜索失败");
  } finally {
    imageSearching.value = false;
  }
};

const sendImage = (image) => {
  const messageData = {
    senderId: currentUserId,
    recipientId: selectedConversation.value.id,
    content: `向您发送了一张影像`,
    type: "share",
    imageId: image.id,
  };
  if (stompClient && stompClient.connected) {
    stompClient.send("/app/chat", {}, JSON.stringify(messageData));
    messages.value.push({
      ...messageData,
      createdAt: new Date().toISOString(),
    });
    imageCache.set(image.id, image);
  } else {
    ElMessage.error("影像发送失败，连接已断开");
  }
  imageDialogVisible.value = false;
};

const viewImage = (imageId) => {
  if (!imageId) return;
  const imageInfo = imageCache.get(imageId);
  if (imageInfo && imageInfo.filePath) {
    const imageUrl = `http://localhost:8080${imageInfo.filePath}`;
    window.open(imageUrl, "_blank");
  } else {
    ElMessage.error("无法查看，该影像可能已被删除或不存在。");
  }
};

const connectWebSocket = () => {
  const socket = new SockJS("/api/ws");
  stompClient = Stomp.over(socket);
  const headers = { token: store.getToken };

  stompClient.connect(
    headers,
    () => {
      stompClient.subscribe(
        `/user/${currentUserId}/queue/messages`,
        (message) => {
          const receivedMessage = JSON.parse(message.body);

          if (
            selectedConversation.value &&
            (selectedConversation.value.id === receivedMessage.senderId ||
              selectedConversation.value.id === receivedMessage.recipientId)
          ) {
            if (receivedMessage.senderId === currentUserId) {
              const index = messages.value.findIndex(
                (m) => !m.id && m.content === receivedMessage.content
              );
              if (index > -1) {
                messages.value.splice(index, 1);
              }
            }
            messages.value.push(receivedMessage);
          } else {
            ElMessage.info(`收到新消息`);
            fetchConversations();
          }
        }
      );
    },
    (error) => {
      console.error("WebSocket Connection Error:", error);
      ElMessage.error("实时消息服务连接失败，请刷新页面重试");
    }
  );
};

// --- 删除功能 ---
const handleDeleteConversation = (conv, event) => {
  event.stopPropagation();
  ElMessageBox.confirm(
    `确定要删除与 ${conv.username} 的所有聊天记录吗？`,
    "警告",
    {
      confirmButtonText: "确定",
      cancelButtonText: "取消",
      type: "warning",
    }
  )
    .then(async () => {
      try {
        await deleteConversation(currentUserId, conv.id);
        ElMessage.success("删除成功");
        if (
          selectedConversation.value &&
          selectedConversation.value.id === conv.id
        ) {
          selectedConversation.value = null;
          messages.value = [];
        }
        await fetchConversations();
      } catch (error) {
        ElMessage.error("删除失败");
      }
    })
    .catch(() => ElMessage.info("已取消删除"));
};

const handleDeleteMessage = (msgId, index) => {
  ElMessageBox.confirm("确定要删除这条消息吗？", "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning",
  })
    .then(async () => {
      try {
        await deleteMessage(msgId);
        messages.value.splice(index, 1);
        ElMessage.success("删除成功");
      } catch (error) {
        ElMessage.error("删除失败");
      }
    })
    .catch(() => ElMessage.info("已取消删除"));
};

onMounted(() => {
  fetchConversations();
  connectWebSocket();
});

onUnmounted(() => {
  if (stompClient) {
    stompClient.disconnect();
  }
});
</script>

<template>
  <el-card class="message-center-card">
    <el-container class="message-container">
      <el-aside width="280px" class="conversation-aside">
        <div class="header">
          <h3>会话列表</h3>
          <el-button
            :icon="Plus"
            circle
            @click="openNewConversationDialog"
          ></el-button>
        </div>
        <el-scrollbar>
          <div
            v-for="conv in conversations"
            :key="conv.id"
            class="conversation-item"
            :class="{
              active:
                selectedConversation && selectedConversation.id === conv.id,
            }"
            @click="selectConversation(conv)"
          >
            <el-avatar class="avatar">{{ conv.username.charAt(0) }}</el-avatar>
            <div class="content">
              <div class="username">{{ conv.username }}</div>
              <div class="last-message">{{ conv.lastMessage }}</div>
            </div>
            <el-button
              type="danger"
              :icon="Delete"
              circle
              size="small"
              class="delete-btn"
              @click="handleDeleteConversation(conv, $event)"
            />
          </div>
        </el-scrollbar>
      </el-aside>

      <el-main class="chat-main">
        <template v-if="selectedConversation">
          <div class="chat-header">
            <h3>{{ selectedConversation.username }}</h3>
            <div class="scroll-controls">
              <el-tooltip content="滚动到顶部" placement="top">
                <el-button
                  :icon="ArrowUp"
                  circle
                  @click="
                    scrollToMessage(
                      messages.length > 0 ? messages[0].id : null,
                      0
                    )
                  "
                />
              </el-tooltip>
              <el-tooltip content="滚动到底部" placement="top">
                <el-button :icon="ArrowDown" circle @click="scrollToBottom" />
              </el-tooltip>
            </div>
          </div>

          <div class="chat-area" ref="chatArea">
            <el-scrollbar height="400px">
              <div
                v-for="(msg, index) in messages"
                :key="msg.id || msg.createdAt"
                :id="`message-${msg.id || index}`"
                class="message-wrapper"
                :class="msg.senderId === currentUserId ? 'sent' : 'received'"
              >
                <el-button
                  v-if="msg.senderId === currentUserId"
                  type="danger"
                  :icon="Close"
                  circle
                  size="small"
                  class="delete-message-btn"
                  @click="handleDeleteMessage(msg.id, index)"
                />
                <div v-if="msg.type === 'text'" class="message-bubble">
                  {{ msg.content }}
                </div>
                <div
                  v-if="msg.type === 'share'"
                  class="message-bubble share-bubble"
                  @click="viewImage(msg.imageId)"
                >
                  <el-icon><Files /></el-icon>
                  <span>{{ `影像 (ID: ${msg.imageId}) - 点击查看` }}</span>
                </div>
              </div>
            </el-scrollbar>
          </div>

          <div class="chat-input-area">
            <el-input
              v-model="newMessage"
              placeholder="输入消息..."
              @keyup.enter="handleSendMessage"
              size="large"
            >
              <template #prepend>
                <el-button :icon="Picture" @click="openImageDialog"></el-button>
              </template>
              <template #append>
                <el-button
                  :icon="Promotion"
                  @click="handleSendMessage"
                  type="primary"
                ></el-button>
              </template>
            </el-input>
          </div>
        </template>
        <div v-else class="no-conversation">
          <p>选择一个会话开始聊天，或新建一个会话</p>
        </div>
      </el-main>
    </el-container>
  </el-card>

  <el-dialog
    v-model="newConversationDialogVisible"
    title="新建消息"
    width="400px"
  >
    <el-input
      v-model="userSearchKeyword"
      placeholder="按用户名搜索"
      @keyup.enter="handleUserSearch"
      class="search-input"
    >
      <template #append>
        <el-button
          :icon="Search"
          @click="handleUserSearch"
          :loading="searching"
        ></el-button>
      </template>
    </el-input>
    <el-scrollbar height="200px">
      <div
        v-for="user in userSearchResults"
        :key="user.id"
        class="user-search-item"
        @click="startConversationWith(user)"
      >
        <el-avatar size="small">{{ user.username.charAt(0) }}</el-avatar>
        <span>{{ user.username }}</span>
      </div>
      <p
        v-if="!userSearchResults.length && !searching"
        style="text-align: center; color: #999"
      >
        无搜索结果
      </p>
    </el-scrollbar>
  </el-dialog>

  <el-dialog
    v-model="imageDialogVisible"
    title="选择要发送的影像"
    width="600px"
  >
    <el-input
      v-model="imageSearchKeyword"
      placeholder="按患者姓名搜索影像"
      @keyup.enter="handleImageSearch"
      class="search-input"
    >
      <template #append>
        <el-button
          :icon="Search"
          @click="handleImageSearch"
          :loading="imageSearching"
        ></el-button>
      </template>
    </el-input>
    <el-scrollbar height="300px">
      <el-table
        :data="imageSearchResults"
        @row-click="sendImage"
        style="width: 100%; cursor: pointer"
      >
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column
          prop="patientName"
          label="患者姓名"
          width="120"
        ></el-table-column>
        <el-table-column prop="modality" label="影像类型"></el-table-column>
        <el-table-column prop="uploadedAt" label="上传时间"></el-table-column>
      </el-table>
    </el-scrollbar>
  </el-dialog>
</template>

<style scoped>
/* 卡片和容器的弹性布局，确保高度自适应 */
.message-center-card {
  /* display: flex;
  flex-direction: column;
  margin-bottom: 0; */
  /* 移除固定的 vh 高度，让其父容器决定高度 */
  display: flex;
  flex-direction: column;
  margin-bottom: 0;
  height: calc(110vh - 162px);
}
.message-container {
  flex: 1;
  min-height: 0;
}
.chat-main {
  display: flex;
  flex-direction: column;
  padding: 0;
  height: 100%;
}
.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #e0e0e0;
  flex-shrink: 0;
}
.scroll-controls {
  display: flex;
  gap: 10px;
}
.chat-area {
  flex: 1; /* 让聊天区域填充所有可用空间 */
  padding: 20px;
  overflow-y: auto; /* 内容溢出时显示滚动条 */
  background-color: #fafafa;
  min-height: 0; /* flex 布局下的重要属性 */
}
.chat-input-area {
  flex-shrink: 0; /* 确保输入区域高度固定 */
  padding: 15px;
  border-top: 1px solid #e0e0e0;
}
.message-wrapper {
  display: flex;
  margin-bottom: 15px;
  align-items: center;
}
.message-wrapper:hover .delete-message-btn {
  opacity: 1;
}
.delete-message-btn {
  opacity: 0;
  transition: opacity 0.2s;
  margin: 0 8px;
  flex-shrink: 0;
}
.message-bubble {
  padding: 10px 15px;
  border-radius: 18px;
  max-width: 70%;
  line-height: 1.5;
}
.sent {
  justify-content: flex-end;
}
.sent .message-bubble {
  background-color: #409eff;
  color: white;
  border-bottom-right-radius: 4px;
}
.received {
  justify-content: flex-start;
}
.received .message-bubble {
  background-color: #f0f0f0;
  color: #333;
  border-bottom-left-radius: 4px;
}
.share-bubble {
  display: flex;
  align-items: center;
  gap: 8px;
  background-color: #e3f2fd;
  border: 1px solid #bbdefb;
  color: #0d47a1;
  cursor: pointer;
}
.no-conversation {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #aaa;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #e0e0e0;
}
.search-input {
  margin-bottom: 15px;
}
.user-search-item {
  display: flex;
  align-items: center;
  padding: 8px 10px;
  cursor: pointer;
  border-radius: 4px;
}
.user-search-item:hover {
  background-color: #f5f5f5;
}
.user-search-item span {
  margin-left: 10px;
}
.conversation-aside {
  border-right: 1px solid #e0e0e0;
  display: flex;
  flex-direction: column;
}
.conversation-item {
  display: flex;
  align-items: center;
  padding: 15px;
  cursor: pointer;
  transition: background-color 0.2s;
  position: relative;
}
.conversation-item .delete-btn {
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  opacity: 0;
  transition: opacity 0.2s;
}
.conversation-item:hover .delete-btn {
  opacity: 1;
}
.conversation-item:hover {
  background-color: #f5f5f5;
}
.conversation-item.active {
  background-color: #e3f2fd;
}
.avatar {
  margin-right: 12px;
}
.content {
  flex: 1;
  overflow: hidden;
}
.username {
  font-weight: 500;
  color: #333;
}
.last-message {
  font-size: 13px;
  color: #888;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
