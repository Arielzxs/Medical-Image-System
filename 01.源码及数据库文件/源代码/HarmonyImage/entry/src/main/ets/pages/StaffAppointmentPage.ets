import promptAction from '@ohos.promptAction';
import webSocket from '@ohos.net.webSocket';
import { BusinessError } from '@kit.BasicServicesKit';
import AppointmentApi from '../apis/AppointmentApi';
import {AppointmentModel} from '../viewmodel/AppointmentModel';

@Entry
@Component
struct StaffAppointmentPage {
  @State checkInList: AppointmentModel[] = [];
  @State waitingList: AppointmentModel[] = [];
  private ws: webSocket.WebSocket | null = null;
  private controller: TabsController = new TabsController();
  async aboutToAppear() {
    this.loadData();
    // WebSocket 功能可以根据您的网络环境和调试需求暂时注释或启用
    // this.connectWebSocket();
  }

  aboutToDisappear() {
    this.ws?.close().catch((err: BusinessError | Error) => {
      console.error('WebSocket close failed', JSON.stringify(err));
    });
  }

  async loadData() {
    try {
      const responses = await Promise.all([
        AppointmentApi.getCheckInList(),
        AppointmentApi.getWaitingList()
      ]);
      const checkInRes = responses[0];
      const waitingRes = responses[1];

      if (checkInRes.state === 0) {
        this.checkInList = checkInRes.data;
      }
      if (waitingRes.state === 0) {
        this.waitingList = waitingRes.data;
      }
    } catch (e) {
      promptAction.showToast({
        message: '列表加载失败'
      });
    }
  }

  async handleCheckIn(id: number) {
    try {
      const res = await AppointmentApi.checkIn(id);
      if (res.state === 0) {
        promptAction.showToast({ message: '报道成功' });
        this.loadData(); // 操作成功后刷新列表
      } else {
        promptAction.showToast({ message: res.message || '报道失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  async handleComplete(id: number) {
    try {
      const res = await AppointmentApi.completeAppointment(id);
      if (res.state === 0) {
        promptAction.showToast({ message: '操作成功' });
        this.loadData(); // 操作成功后刷新列表
      } else {
        promptAction.showToast({ message: res.message || '操作失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  @Builder
  AppointmentCard(item: AppointmentModel, isCheckInList: boolean) {
    Column() {
      Row() {
        Text(item.patientName).fontSize(16).fontWeight(FontWeight.Bold)
        Text(item.status).fontSize(12).fontColor(Color.Gray).margin({ left: 10 })
      }
      .width('100%').justifyContent(FlexAlign.Start)

      Text(`预约时间: ${item.appointmentDate} ${item.startTime.substring(0, 5)}`).fontSize(14).margin({ top: 5 })
      Text(`预约内容: ${item.appointmentContent}`).fontSize(14).margin({ top: 2 })
      if (!isCheckInList && item.checkInTime) {
        Text(`报道时间: ${item.checkInTime}`).fontSize(14).margin({ top: 2 })
      }

      Button(isCheckInList ? '报道' : '完成')
        .width('100%')
        .margin({ top: 10 })
        .type(ButtonType.Capsule)
        .backgroundColor(isCheckInList ? '#28a745' : '#007bff')
        .enabled(isCheckInList ? item.status === 'PENDING' : true)
        .onClick(() => {
          if (isCheckInList) {
            this.handleCheckIn(item.id);
          } else {
            this.handleComplete(item.id);
          }
        })
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }

  build() {
    Column() {
      Navigation() {
        Tabs({ controller: this.controller }) {
          TabContent() {
            Column() {
              List({
                space: 10
              }) {
                ForEach(this.checkInList, (item: AppointmentModel) => {
                  ListItem() {
                    this.AppointmentCard(item, true);
                  }
                });
              }
              .padding({ left: 10, right: 10, bottom: 10 })
            }
            .height('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .tabBar("报道列表")

          TabContent() {
            Column() {
              List({
                space: 10
              }) {
                ForEach(this.waitingList, (item: AppointmentModel) => {
                  ListItem() {
                    this.AppointmentCard(item, true);
                  }
                });
              }
              .padding({ left: 10, right: 10, bottom: 10 })
            }
            .height('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .tabBar("候诊列表")
        }
      }
      .title("医护工作台")
      .titleMode(NavigationTitleMode.Mini)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f3f5')
  }
}