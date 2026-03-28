import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import preferences from '@ohos.data.preferences';
import AppointmentApi, { CreateAppointmentParam } from '../apis/AppointmentApi';
import {AppointmentModel} from '../viewmodel/AppointmentModel';
import {User} from '../viewmodel/UserModel'
// 为 admin 对象定义一个接口
interface AdminInfo {
  id: number;
  username: string;
  idCard: string;
}
@Entry
@Component
struct CreateAppointmentPage {
  // 使用 CreateAppointmentParam 作为表单的数据模型
  @State appointmentForm: CreateAppointmentParam = {
    patientId: 0,
    patientName: '',
    patientIdCard: '',
    appointmentType: '',
    appointmentContent: '',
    appointmentDate: '',
    startTime: ''
  };
  @State availableSlots: Array<string> = [];
  @State selectedDate: Date = new Date();
  private pref: preferences.Preferences | null = null;

  async aboutToAppear() {
    const userInfo: User | undefined = AppStorage.get<User>('currentUser');
    // this.pref = await preferences.getPreferences(getContext(this), { name: 'user_store' });
    // const adminJson = await this.pref.get('admin', '{}') as string;
    // const admin: AdminInfo = JSON.parse(adminJson);
    // 初始化表单的基础信息
    if(userInfo) {
      this.appointmentForm.patientId = userInfo.id || 0;
      this.appointmentForm.patientName = userInfo.username || '';
      this.appointmentForm.patientIdCard = userInfo.idCard || '';
    }
    else {
      this.appointmentForm.patientId =  0;
      this.appointmentForm.patientName = '';
      this.appointmentForm.patientIdCard =  '';
    }
    // 默认设置今天的日期
    const today = new Date();
    this.appointmentForm.appointmentDate = `${today.getFullYear()}-${(today.getMonth() + 1).toString().padStart(2, '0')}-${today.getDate().toString().padStart(2, '0')}`;
  }

  // 获取可用时间段
  async fetchAvailableSlots() {
    if (this.appointmentForm.appointmentDate && this.appointmentForm.appointmentType) {
      try {
        const res = await AppointmentApi.getAvailableSlots({
          date: this.appointmentForm.appointmentDate,
          type: this.appointmentForm.appointmentType
        });
        if (res.state === 0) {
          this.availableSlots = res.data;
        } else {
          promptAction.showToast({ message: res.message || '获取可用时间段失败' });
        }
      } catch (e) {
        promptAction.showToast({ message: '网络请求失败' });
      }
    }
  }

  // 提交预约
  async submitAppointment() {
    if (!this.appointmentForm.appointmentType || !this.appointmentForm.appointmentDate || !this.appointmentForm.startTime || !this.appointmentForm.appointmentContent) {
      promptAction.showToast({ message: '请填写完整的预约信息' });
      return;
    }

    try {
      const res = await AppointmentApi.createAppointment(this.appointmentForm);
      if (res.state === 0) {
        promptAction.showToast({ message: '预约成功' });
        router.back();
      } else {
        promptAction.showToast({ message: res.message || '预约失败' });
      }
    } catch (e) {
      promptAction.showToast({ message: '预约请求失败，请检查网络或联系管理员' });
    }
  }

  build() {
    Column() {
      Navigation() {
        Scroll() {
          Column({ space: 15 }) {
            Text('提交预约').fontSize(24).fontWeight(FontWeight.Bold).margin({ bottom: 20 })

            TextInput({ placeholder: '患者姓名', text: this.appointmentForm.patientName })
              .width('100%')

            TextInput({ placeholder: '患者身份证', text: this.appointmentForm.patientIdCard })
              .onChange((val) => {
                this.appointmentForm.patientIdCard = val;
              })
              .width('100%')

            TextInput({ placeholder: '预约类型 (如: CT, X光)', text: this.appointmentForm.appointmentType })
              .onChange((val) => {
                this.appointmentForm.appointmentType = val;
                this.fetchAvailableSlots(); // 修改类型后重新获取时间
              })
              .width('100%')

            DatePicker({
              start: new Date(),
              selected: this.selectedDate
            })
              .onChange((date) => {
                const newSelectedDate = new Date(
                  date.year ?? this.selectedDate.getFullYear(),
                  date.month ?? this.selectedDate.getMonth(),
                  date.day ?? this.selectedDate.getDate()
                );
                this.selectedDate = newSelectedDate;

                const year = this.selectedDate.getFullYear();
                const month = (this.selectedDate.getMonth() + 1).toString().padStart(2, '0');
                const day = this.selectedDate.getDate().toString().padStart(2, '0');
                this.appointmentForm.appointmentDate = `${year}-${month}-${day}`;
                this.fetchAvailableSlots(); // 修改日期后重新获取时间
              })

            Select(this.availableSlots.map((slot): SelectOption => ({ value: `${slot.substring(0, 5)} - ${this.calculateEndTime(slot)}` })))
              .value(this.appointmentForm.startTime
                ? `${this.appointmentForm.startTime.substring(0, 5)} - ${this.calculateEndTime(this.appointmentForm.startTime)}`
                : '请选择预约时间段')
              .fontColor(this.appointmentForm.startTime ? Color.Black : '#999')
              .onSelect((index) => {
                this.appointmentForm.startTime = this.availableSlots[index];
              })

            TextArea({ placeholder: '预约内容/备注' })
              .onChange((val) => {
                this.appointmentForm.appointmentContent = val;
              })
              .width('100%')
              .height(100)

            Button('提交预约')
              .onClick(() => this.submitAppointment())
              .width('100%')
              .type(ButtonType.Capsule)
              .margin({ top: 20 })
          }
          .padding(20)
        }
      }
      .title('新建预约')
      .titleMode(NavigationTitleMode.Mini)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f3f5')
  }

  // 辅助函数，用于在Select中显示结束时间
  calculateEndTime(startTime: string): string {
    if (!startTime || !startTime.includes(':')) {
      return '';
    }
    const timeParts = startTime.split(':');
    const hourStr = timeParts[0];
    const minuteStr = timeParts[1];
    const hour = parseInt(hourStr);
    const minute = parseInt(minuteStr);
    if (minute === 30) {
      return `${(hour + 1).toString().padStart(2, '0')}:00`;
    }
    return `${hour.toString().padStart(2, '0')}:30`;
  }
}