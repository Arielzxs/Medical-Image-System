import { getConversations, getMessagesWithUser } from '../apis/MessageApi';
import { Conversation, Message } from '../viewmodel/MessageModel';
import webSocket from '@ohos.net.webSocket';
import { User } from '../viewmodel/UserModel';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import { serverIpAndPort } from '../utils/HttpUtil';

// STOMP 命令
enum StompCommand {
  CONNECT = 'CONNECT',
  CONNECTED = 'CONNECTED',
  SUBSCRIBE = 'SUBSCRIBE',
  SEND = 'SEND',
  MESSAGE = 'MESSAGE',
  DISCONNECT = 'DISCONNECT',
  ERROR = 'ERROR'
}

interface StompFrame {
  command: string;
  headers: Record<string, string>;
  body: string;
}

@Entry
@Component
struct MessagePage {
  @State conversations: Conversation[] = [];
  @State messages: Message[] = [];
  @State selectedConversation: Conversation | null = null;
  @State newMessage: string = '';
  @State isLoading: boolean = false;
  private currentUser: User | undefined = AppStorage.get<User>('currentUser');
  private socket: webSocket.WebSocket | null = null;
  private subscriptionId: string = `sub-${Date.now()}`;
  private isStompConnected: boolean = false;
  private messageListRef: Scroller = new Scroller();

  // STOMP 帧构建
  private buildStompFrame(command: StompCommand, headers: Record<string, string>, body: string = ''): string {
    let frame = `${command}\n`;
    for (const key of Object.keys(headers)) {
      frame += `${key}:${headers[key]}\n`;
    }
    frame += `\n${body}\0`; // 帧以空字符结尾
    return frame;
  }

  // 解析 STOMP 帧
  private parseStompFrame(data: string): StompFrame {
    const parts = data.split('\n\n');
    const headerLines = parts[0].split('\n');
    const command = headerLines.shift() || '';
    const headers: Record<string, string> = {};
    headerLines.forEach(line => {
      const lineParts = line.split(':', 2);
      if (lineParts.length === 2) {
        const key = lineParts[0];
        const value = lineParts[1];
        headers[key.trim()] = value.trim();
      }
    });
    // 移除末尾的空字符
    const body = parts[1] ? parts[1].replace(/\0$/, '') : '';
    return { command, headers, body };
  }


  async aboutToAppear() {
    if (!this.currentUser) {
      promptAction.showToast({ message: '用户未登录' });
      router.back();
      return;
    }
    await this.fetchConversations();
    this.connectWebSocket();
  }

  aboutToDisappear() {
    this.disconnectWebSocket();
  }

  // 1. WebSocket 连接管理
  connectWebSocket() {
    if (this.socket || !this.currentUser) return;
    const token = AppStorage.get<string>('token');
    if (!token) {
      promptAction.showToast({ message: '认证失败，无法连接消息服务' });
      return;
    }

    const wsUrl = serverIpAndPort.replace('http', 'ws') + '/ws';
    this.socket = webSocket.createWebSocket();

    this.socket.on('open', () => {
      console.log('WebSocket connected');
      const connectHeaders: Record<string, string> = {};
      connectHeaders['accept-version'] = '1.1,1.0';
      connectHeaders['heart-beat'] = '10000,10000';
      //connectHeaders['token'] = token;

      const frame = this.buildStompFrame(StompCommand.CONNECT, connectHeaders);
      this.socket?.send(frame);
    });

    this.socket.on('message', (err, data) => {
      if (err) {
        console.error('WebSocket on message error:', JSON.stringify(err));
        return;
      }
      const frame = this.parseStompFrame(data as string);
      this.handleStompMessage(frame);
    });

    this.socket.on('error', (err) => {
      console.error('WebSocket connection error:', JSON.stringify(err));
      promptAction.showToast({ message: '消息服务连接失败' });
    });
    const wsHeaders: Record<string, string> = {};
    wsHeaders['token'] = token;

    this.socket.connect(wsUrl, { header: wsHeaders });
  }

  disconnectWebSocket() {
    if (this.socket && this.isStompConnected) {
      const frame = this.buildStompFrame(StompCommand.DISCONNECT, {});
      this.socket.send(frame, (err) => {
        if (!err) {
          this.socket?.close();
          this.socket = null;
          this.isStompConnected = false;
          console.log('WebSocket disconnected');
        }
      });
    }
  }

  // STOMP 消息处理
  handleStompMessage(frame: StompFrame) {
    switch (frame.command) {
      case StompCommand.CONNECTED:
        this.isStompConnected = true;
        console.log('STOMP Connected!');
        this.subscribeToTopic();
        break;
      case StompCommand.MESSAGE:
        this.handleReceivedMessage(JSON.parse(frame.body));
        break;
      case StompCommand.ERROR:
        console.error('STOMP Error:', frame.body);
        promptAction.showToast({ message: `消息错误: ${frame.body}` });
        break;
    }
  }

  subscribeToTopic() {
    if (!this.socket || !this.isStompConnected || !this.currentUser) return;

    const subscribeHeaders: Record<string, string> = {};
    subscribeHeaders['id'] = this.subscriptionId;
    subscribeHeaders['destination'] = `/user/${this.currentUser.id}/queue/messages`;

    const frame = this.buildStompFrame(StompCommand.SUBSCRIBE, subscribeHeaders);
    this.socket.send(frame);
    console.info("Subscribed to user channel");
  }

  handleReceivedMessage(receivedMessage: Message) {
    if (this.selectedConversation &&
      (this.selectedConversation.id === receivedMessage.senderId || this.selectedConversation.id === receivedMessage.recipientId)) {
      this.messages.push(receivedMessage);
      this.scrollToBottom();
    } else {
      promptAction.showToast({ message: '您有新的消息' });
      this.fetchConversations();
    }
  }

  // 3. 数据获取与操作
  async fetchConversations() {
    if (!this.currentUser || !this.currentUser.id) {
      promptAction.showToast({ message: '无法加载会话：用户不存在' });
      return;
    }
    this.isLoading = true;
    try {
      const res = await getConversations(this.currentUser.id);
      if (res.state === 0) {
        this.conversations = res.data;
        if (this.conversations.length > 0 && !this.selectedConversation) {
          await this.selectConversation(this.conversations[0]);
        }
      }
    } catch (e) {
      promptAction.showToast({ message: '加载会话列表失败' });
    } finally {
      this.isLoading = false;
    }
  }

  async selectConversation(conversation: Conversation) {
    if (!this.currentUser || !this.currentUser.id) {
      promptAction.showToast({ message: '无法加载消息：用户不存在' });
      return;
    }
    this.selectedConversation = conversation;
    this.messages = [];
    try {
      const res = await getMessagesWithUser(this.currentUser.id, conversation.id);
      if (res.state === 0) {
        this.messages = res.data;
        this.scrollToBottom();
      }
    } catch (error) {
      promptAction.showToast({ message: '加载消息失败' });
    }
  }

  // 4. 发送消息
  sendMessage() {
    const currentUser = this.currentUser;
    if (!this.newMessage.trim() || !this.selectedConversation || !this.socket || !this.isStompConnected || !currentUser || !currentUser.id) {
      return;
    }

    const messageData: Message = {
      senderId: currentUser.id,
      recipientId: this.selectedConversation.id,
      content: this.newMessage,
      type: "text",
      createdAt: new Date().toISOString()
    };

    const sendHeaders: Record<string, string> = {};
    sendHeaders['destination'] = '/app/chat';

    const frame = this.buildStompFrame(StompCommand.SEND, sendHeaders, JSON.stringify(messageData));

    this.socket.send(frame, (err) => {
      if (err) {
        promptAction.showToast({ message: '消息发送失败' });
        return;
      }
      this.messages.push(messageData);
      this.newMessage = '';
      this.scrollToBottom();
    });
  }

  // (未来可扩展) 发送影像
  sendImage(imageId: number, patientName: string) {
    const currentUser = this.currentUser;
    if (!this.selectedConversation || !this.socket || !this.isStompConnected || !currentUser || !currentUser.id) {
      return;
    }

    const messageData: Message = {
      senderId: currentUser.id,
      recipientId: this.selectedConversation.id,
      content: `向您分享了影像: ${patientName}`,
      type: 'share',
      imageId: imageId,
      createdAt: new Date().toISOString()
    };

    const sendHeaders: Record<string, string> = {};
    sendHeaders['destination'] = '/app/chat';

    const frame = this.buildStompFrame(StompCommand.SEND, sendHeaders, JSON.stringify(messageData));
    this.socket.send(frame, (err) => {
      if (err) {
        promptAction.showToast({ message: '影像分享失败' });
        return;
      }
      this.messages.push(messageData);
      this.scrollToBottom();
      promptAction.showToast({ message: '影像已分享' });
    });
  }


  scrollToBottom() {
    setTimeout(() => {
      this.messageListRef.scrollEdge(Edge.End);
    }, 100);
  }

  // 5. UI 渲染
  build() {
    Row() {
      // 左侧会话列表
      Column() {
        Text('会话列表').fontSize(20).fontWeight(FontWeight.Bold).padding(10)
        List({ space: 10 }) {
          ForEach(this.conversations, (conv: Conversation) => {
            ListItem() {
              Row() {
                Text(conv.username.charAt(0))
                  .width(40).height(40).fontSize(18)
                  .backgroundColor(this.selectedConversation?.id === conv.id ? '#D3E5FF' : '#EEE')
                  .borderRadius(20).textAlign(TextAlign.Center)
                Column({ space: 5 }) {
                  Text(conv.username).fontWeight(FontWeight.Bold)
                  Text(conv.lastMessage).fontSize(14).fontColor(Color.Gray)
                    .textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }
              .padding(10)
              .backgroundColor(this.selectedConversation?.id === conv.id ? '#E7F1FF' : Color.White)
              .borderRadius(8)
              .onClick(() => this.selectConversation(conv))
            }
          })
        }.layoutWeight(1).padding({ left: 10, right: 10 })
      }.width('35%').backgroundColor('#F7F7F7')


      // 右侧聊天窗口
      Column() {
        if (this.selectedConversation && this.currentUser) {
          // 头部
          Row() {
            Text(this.selectedConversation.username)
              .fontSize(18).fontWeight(FontWeight.Bold)
          }.width('100%').padding(15).border({ width: { bottom: 1 }, color: '#EEE' })

          // 消息区域
          Scroll(this.messageListRef) {
            Column({ space: 10 }) {
              ForEach(this.messages, (msg: Message) => {
                MessageBubble({ message: msg, isMe: msg.senderId === this.currentUser!.id })
              })
            }.width('100%').padding(10)
          }.layoutWeight(1)


          // 输入区域
          Row({ space: 10 }) {
            TextInput({ placeholder: '输入消息...', text: this.newMessage })
              .onChange(val => this.newMessage = val)
              .layoutWeight(1)
            Button('发送')
              .onClick(() => this.sendMessage())
              .enabled(this.newMessage.trim().length > 0)
          }.padding(10).width('100%').border({ width: { top: 1 }, color: '#EEE' })

        } else {
          Text('请选择一个会话开始聊天').fontSize(18).fontColor(Color.Gray).width('100%').height('100%')
            .textAlign(TextAlign.Center)
        }
      }.layoutWeight(1)
    }.width('100%').height('100%')
  }
}

@Component
struct MessageBubble {
  private message: Message = {
    senderId: 0,
    recipientId: 0,
    content: '',
    type: 'text',
    createdAt: ''
  };
  private isMe: boolean = false;

  build() {
    Row() {
      if (this.isMe) {
        Blank() // 占位符，将消息推到右边
      }

      Column() {
        if (this.message.type === 'text') {
          Text(this.message.content)
            .padding(10)
            .borderRadius(10)
            .backgroundColor(this.isMe ? '#409EFF' : '#FFFFFF')
            .fontColor(this.isMe ? Color.White : Color.Black)
            .alignSelf(this.isMe ? ItemAlign.End : ItemAlign.Start)
        } else if (this.message.type === 'share') {
          Row({space: 5}) {
            Image($r('app.media.icon_image')).width(20).height(20)
            Text(`影像分享 (ID: ${this.message.imageId})`)
              .fontColor('#0D47A1')
          }
          .padding(10)
          .borderRadius(10)
          .backgroundColor('#E3F2FD')
          .border({ width: 1, color: '#BBDEFB' })
          .onClick(()=>{
            promptAction.showToast({message: '暂不支持在移动端查看影像，请前往Web端'})
          })
        }
      }
      .constraintSize({ maxWidth: '70%' })

      if (!this.isMe) {
        Blank() // 占位符，将消息推到左边
      }
    }.width('100%')
  }
}
