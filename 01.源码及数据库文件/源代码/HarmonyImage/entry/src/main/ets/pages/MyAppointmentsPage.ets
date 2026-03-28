import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import { prompt } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import AppointmentApi from '../apis/AppointmentApi';
import { AppointmentModel } from '../viewmodel/AppointmentModel';
import {User} from '../viewmodel/UserModel'

// 为 admin 对象定义一个接口
interface AdminInfo {
  id: number;
}

// 为 AlertDialog 的成功回调数据定义接口
interface DialogSuccessData {
  index: number;
}

@Entry
@Component
struct MyAppointmentsPage {
  @State appointments: AppointmentModel[] = [];
  private pref: preferences.Preferences | null = null;
  private userId: number = 0;

  async aboutToAppear() {
    const userInfo: User | undefined = AppStorage.get<User>('currentUser');
    if(userInfo?.id)  this.userId = userInfo.id
    this.fetchAppointments();
  }

  async fetchAppointments() {
    try {
      const res = await AppointmentApi.getPatientAppointments(this.userId);
      if (res.state === 0) {
        this.appointments = res.data;
      } else {
        promptAction.showToast({ message: res.message || '获取预约列表失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  getStatusText(status: string): string {
    switch (status) {
      case 'PENDING':
        return '待报道';
      case 'CHECKED_IN':
        return '已报道';
      case 'IN_PROGRESS':
        return '候诊中';
      case 'COMPLETED':
        return '已完成';
      case 'CANCELED':
        return '已取消';
      case 'EXPIRED':
        return '已过期';
      default:
        return '未知';
    }
  }

  getStatusColor(status: string): ResourceColor {
    switch (status) {
      case 'PENDING':
        return '#ffc107';
      case 'CHECKED_IN':
        return '#6c757d';
      case 'IN_PROGRESS':
        return '#007bff';
      case 'COMPLETED':
        return '#28a745';
      case 'CANCELED':
        return '#dc3545';
      case 'EXPIRED':
        return '#6c757d';
      default:
        return '#6c757d';
    }
  }

  handleCancel(id: number) {
    prompt.showDialog({
      title: '取消确认',
      message: '您确定要取消这个预约吗？',
      buttons: [
        { text: '再想想', color: '#666666' },
        { text: '确定', color: '#DC3545' }
      ]
    }).then(async (data: DialogSuccessData) => {
      if (data.index === 1) { // 确定按钮
        try {
          const res = await AppointmentApi.cancelAppointment(id);
          if (res.state === 0) {
            promptAction.showToast({ message: '预约已成功取消' });
            this.fetchAppointments();
          } else {
            promptAction.showToast({ message: res.message || '取消失败' });
          }
        } catch (e) {
          promptAction.showToast({ message: '网络请求失败' });
        }
      } else {
        promptAction.showToast({ message: '已取消操作' });
      }
    }).catch((err: BusinessError) => {
      console.error(`show dialog fail, err: ${JSON.stringify(err)}`);
    });
  }

  @Builder
  AppointmentCard(item: AppointmentModel) {
    Column() {
      Row() {
        Text(`类型: ${item.appointmentType}`).fontSize(16).fontWeight(FontWeight.Bold)
        Badge({
          value: this.getStatusText(item.status),
          style: {
            color: Color.White,
            fontSize: 12,
            badgeColor: this.getStatusColor(item.status),
          }
        })
      }
      .width('100%').justifyContent(FlexAlign.SpaceBetween)

      Text(`预约时间: ${item.appointmentDate} ${item.startTime.substring(0, 5)}`).fontSize(14).margin({ top: 5 })
      Text(`内容: ${item.appointmentContent}`).fontSize(14).margin({ top: 2 })
      Text(`提交时间: ${item.submissionTime}`).fontSize(12).fontColor(Color.Gray).margin({ top: 8 })

      Button('取消预约')
        .width('100%')
        .margin({ top: 10 })
        .type(ButtonType.Capsule)
        .backgroundColor('#dc3545')
        .enabled(!(item.status === 'CANCELED' || item.status === 'COMPLETED' || item.status === 'EXPIRED'))
        .onClick(() => this.handleCancel(item.id))
    }
    .padding(15)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .margin({ bottom: 10 })
  }
  @Builder MenuBuilder() {
    Text('新建')
      .fontColor(Color.Black) // 明确设置文字颜色为黑色，确保可见
      .fontSize(16)
      .padding({ right: 10 })
  }
  build() {
    Column() {
      Navigation() {
        List({ space: 10 }) {
          ForEach(this.appointments, (item: AppointmentModel) => {
            ListItem() {
              this.AppointmentCard(item)
            }
          })
        }.padding(10)
      }
      .title("我的预约")
      .titleMode(NavigationTitleMode.Mini)
      .menus([
        { value: '新建',icon:$r("app.media.add_icon"),  action: () => router.pushUrl({ url: 'pages/CreateAppointmentPage' }) }
      ])
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f3f5')
  }
}