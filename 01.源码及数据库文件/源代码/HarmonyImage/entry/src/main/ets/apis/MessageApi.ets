import { httpRequest, JsonResult } from '../utils/HttpUtil';
import { Conversation, Message } from '../viewmodel/MessageModel';
import { UserIdParam } from '../params/request/MessageParams';

/**
 * 获取当前用户的所有会话列表
 * @param userId 当前用户的ID
 * @returns 返回包含会话列表的 Promise
 */
export async function getConversations(userId: number): Promise<JsonResult<Conversation[]>> {
  const params: UserIdParam = { userId };
  return httpRequest.get<JsonResult<Conversation[]>, UserIdParam>(`/messages`, params);
}

/**
 * 获取与特定用户的消息历史记录
 * @param userId 当前用户的ID
 * @param otherUserId 对方用户的ID
 * @returns 返回包含消息历史的 Promise
 */
export async function getMessagesWithUser(userId: number, otherUserId: number): Promise<JsonResult<Message[]>> {
  const params: UserIdParam = { userId };
  return httpRequest.get<JsonResult<Message[]>, UserIdParam>(`/messages/${otherUserId}`, params);
}

/**
 * 删除与一个人的全部会话
 * @param userId 当前用户的ID
 * @param otherUserId 对方用户的ID
 */
export async function deleteConversation(userId: number, otherUserId: number): Promise<JsonResult<void>> {
  const body: UserIdParam = { userId };
  return httpRequest.post<JsonResult<void>, UserIdParam>(`/messages/conversation/${otherUserId}`, body);
}

/**
 * 删除单条消息
 * @param messageId 消息的ID
 */
export async function deleteMessage(messageId: number): Promise<JsonResult<void>> {
  return httpRequest.post<JsonResult<void>, void>(`/messages/${messageId}`);
}