export interface Message {
  id?: number;
  senderId: number;
  recipientId: number;
  content: string;
  type: 'text' | 'share'; // "text" or "share"
  imageId?: number; // for share type
  createdAt: string; // 使用 ISO 字符串格式，例如 '2023-10-27T10:00:00.000Z'
  isRead?: boolean;
}

// 用于表示会话列表中的一个会话
export interface Conversation {
  id: number;          // 对方用户的ID
  username: string;    // 对方用户的用户名
  lastMessage: string; // 最后一条消息的内容
  lastMessageTime?: string; // 最后一条消息的时间
  unreadCount?: number;   // 未读消息数
}