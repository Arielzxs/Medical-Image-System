import UserApi from '../apis/UserApi';
import { User } from '../viewmodel/UserModel';
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

// 定义日期选择器返回的值的接口
interface DatePickerValue {
  year: number;
  month: number;
  day: number;
}

@Component
export struct ProfileManagementPage {
  // 使用 @State 装饰器使UI能够响应数据变化
  @State currentUser: User = {
    username: '',
    idCard: '',
    phone: '',
    address: '',
    age: 0,
    gender: 0,
    birthDate: ''
  };
  // 用于存储原始用户信息，方便在取消编辑时恢复
  private originalUser: User = {
    username: '',
    idCard: '',
    phone: '',
    address: '',
    age: 0,
    gender: 0,
    birthDate: ''
  };
  @State private isEditing: boolean = false;

  // aboutToAppear是页面即将显示时的生命周期回调
  aboutToAppear() {
    // 从应用级存储中获取当前用户信息
    const userInfo: User | undefined = AppStorage.get<User>('currentUser');
    if (userInfo && userInfo.id) {
      this.loadUserData(userInfo.id);
    } else {
      promptAction.showToast({ message: '用户未登录' });
    }
  }

  // 异步方法，根据用户ID从API加载用户数据
  async loadUserData(userId: number) {
    try {
      const response = await UserApi.getUserById(userId);
      if (response.state === 0 && response.data) {
        this.currentUser = response.data;
        // 使用深拷贝保存原始数据
        this.originalUser = JSON.parse(JSON.stringify(response.data));
      } else {
        promptAction.showToast({ message: `加载用户信息失败: ${response.message}` });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  // 异步方法，提交用户信息更新
  async submitUpdate() {
    try {
      const response = await UserApi.updateUser(this.currentUser);
      if (response.state === 0) {
        promptAction.showToast({ message: '用户信息更新成功' });
        this.isEditing = false;
        this.originalUser = JSON.parse(JSON.stringify(this.currentUser));
      } else {
        promptAction.showToast({ message: `更新失败: ${response.message}` });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  // 退出登录方法
  logout() {
    // 清除应用级存储中的用户信息
    AppStorage.delete('currentUser');
    // 使用 replaceUrl 跳转到登录页，避免用户可以返回到前一页
    router.replaceUrl({ url: 'pages/LoginPage' });
    promptAction.showToast({ message: '已退出登录' });
  }

  build() {
    Column() {
      Text('个人资料管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
        .width('90%')
        .textAlign(TextAlign.Start)

      Scroll() {
        Column({ space: 5 }) {
          // 用户名
          Row() {
            Text('用户名').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            TextInput({ text: this.currentUser.username })
              .enabled(this.isEditing)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.currentUser.username = val)
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 身份证号 (不可编辑)
          Row() {
            Text('身份证号').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            TextInput({ text: this.currentUser.idCard })
              .enabled(false)
              .fontColor(Color.Gray)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 电话
          Row() {
            Text('电话').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            TextInput({ text: this.currentUser.phone })
              .type(InputType.PhoneNumber)
              .enabled(this.isEditing)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.currentUser.phone = val)
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 年龄
          Row() {
            Text('年龄').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            TextInput({ text: this.currentUser.age ? this.currentUser.age.toString() : '0' })
              .type(InputType.Number)
              .enabled(this.isEditing)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.currentUser.age = parseInt(val) || 0)
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 性别
          Row() {
            Text('性别').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            Row({ space: 20 }) {
              Radio({ value: '0', group: 'gender' }).checked(this.currentUser.gender === 0).onChange((isChecked: boolean) => {
                if (isChecked) this.currentUser.gender = 0
              })
              Text("男")
              Radio({ value: '1', group: 'gender' }).checked(this.currentUser.gender === 1).onChange((isChecked: boolean) => {
                if (isChecked) this.currentUser.gender = 1
              })
              Text("女")
            }
            .enabled(this.isEditing)
            .justifyContent(FlexAlign.Start).flexGrow(1)
            .onClick(() => {
              if (!this.isEditing) {
                promptAction.showToast({ message: "请先点击修改信息" });
              }
            })
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 出生日期
          Row() {
            Text('出生日期').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            DatePicker({
              start: new Date('1920-01-01'),
              end: new Date(),
              selected: this.currentUser.birthDate ? new Date(this.currentUser.birthDate) : new Date()
            })
              .enabled(this.isEditing)
              .backgroundColor(Color.Transparent)
              .onChange((value: DatePickerValue) => {
                this.currentUser.birthDate = `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
              })
              .width("50%")
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })
          Divider().color($r('app.color.border'))

          // 地址
          Row() {
            Text('地址').width('25%').fontSize(16).fontColor($r('app.color.font_sub'))
            TextInput({ text: this.currentUser.address })
              .enabled(this.isEditing)
              .fontSize(16)
              .textAlign(TextAlign.Start)
              .backgroundColor(Color.Transparent)
              .onChange(val => this.currentUser.address = val)
          }
          .width('100%').height(50).justifyContent(FlexAlign.SpaceBetween).padding({ left: 10, right: 10 })

        }
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(15)
        .padding({ top: 10, bottom: 10 })

      }.layoutWeight(1).padding({ left: 15, right: 15 })

      // 操作按钮区域
      Column({ space: 10 }) {
        if (this.isEditing) {
          Row({ space: 20 }) {
            Button('保存提交').type(ButtonType.Capsule).width('40%').height(45).fontSize(18).onClick(() => this.submitUpdate())
            Button('取消').type(ButtonType.Capsule).width('40%').height(45).fontSize(18).backgroundColor(Color.Gray).onClick(() => {
              this.currentUser = JSON.parse(JSON.stringify(this.originalUser));
              this.isEditing = false;
            })
          }
        } else {
          Button('修改信息').type(ButtonType.Capsule).width('85%').height(45).fontSize(18).onClick(() => this.isEditing = true)
        }
        Button('退出登录').type(ButtonType.Capsule).width('85%').height(45).fontSize(18).backgroundColor(Color.Red).onClick(() => this.logout())
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 20, bottom: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background_background'))
    .justifyContent(FlexAlign.Start)
  }
}
