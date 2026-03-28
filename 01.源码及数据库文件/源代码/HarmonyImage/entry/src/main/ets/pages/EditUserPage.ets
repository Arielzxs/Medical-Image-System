import AdminApi from '../apis/AdminApi';
import { User } from '../viewmodel/UserModel';
import promptAction from '@ohos.promptAction';
import UserApi from '../apis/UserApi';
import { router, Router } from '@kit.ArkUI'; // 统一导入 @kit.ArkUI 中的 router

@Entry
@Component
struct EditUserPage {
  @State currentUser: User = {
    username: '',
    idCard: '',
    phone: '',
    password: '',
    address: '',
    age: 0,
    gender: 0,
    role: 'patient'
  };
  private userId: number = 0;
  private routerInstance: Router | null = null;

  aboutToAppear() {
    // 获取当前页面的 Router 实例，用于参数获取和页面返回
    this.routerInstance = this.getUIContext()?.getRouter();
    if (!this.routerInstance) {
      promptAction.showToast({ message: '获取路由实例失败' });
      return;
    }

    const params = this.routerInstance.getParams();
    const obj = params as Record<string, number>
    const userIdParam = obj.userId
    console.log(JSON.stringify(userIdParam))
    if (userIdParam) {
      const parsedUserId = Number(userIdParam);
      if (!isNaN(parsedUserId)) {
        this.userId = parsedUserId;
        this.loadUserData(this.userId);
      } else {
        promptAction.showToast({ message: '无效的用户ID格式' });
        this.routerInstance.back();
      }
    } else {
      promptAction.showToast({ message: '未找到用户ID' });
      this.routerInstance.back();
    }
  }

  async loadUserData(userId: number) {
    try {
      const response = await UserApi.getUserById(userId);
      if (response && response.state === 0 && response.data) {
        this.currentUser = response.data;
      } else {
        promptAction.showToast({ message: `加载用户信息失败: ${response?.message || '未知错误'}` });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  async submitUpdate() {
    try {
      if (!this.currentUser.username || !this.currentUser.phone) {
        promptAction.showToast({ message: '用户名和电话不能为空' });
        return;
      }
      const response = await AdminApi.updateUser(this.currentUser);
      if (response && response.state === 0) {
        promptAction.showToast({ message: '用户信息更新成功' });
        this.routerInstance?.back();
      } else {
        promptAction.showToast({ message: `更新失败: ${response?.message || '未知错误'}` });
      }
    } catch (error) {
      promptAction.showToast({ message: '网络请求失败' });
    }
  }

  build() {
    Column() {
      Text('修改用户信息')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 })
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding({ left: 15 })

      Scroll() {
        Column() {
          // --- 用户名输入 ---
          Row() {
            Text('用户名')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ placeholder: '请输入用户名', text: this.currentUser.username ?? '' })
              .type(InputType.Normal)
              .onChange((value) => { this.currentUser.username = value; })
              .layoutWeight(1)
              .fontSize(16)
              .textAlign(TextAlign.End)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(55)
          .padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })

          // --- 身份证输入 ---
          Row() {
            Text('身份证')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ placeholder: '请输入身份证号', text: this.currentUser.idCard ?? '' })
              .type(InputType.Normal)
              .onChange((value) => { this.currentUser.idCard = value; })
              .layoutWeight(1)
              .fontSize(16)
              .textAlign(TextAlign.End)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(55)
          .padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })

          // --- 电话输入 ---
          Row() {
            Text('电话')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ placeholder: '请输入电话号码', text: this.currentUser.phone ?? '' })
              .type(InputType.PhoneNumber)
              .onChange((value) => { this.currentUser.phone = value; })
              .layoutWeight(1)
              .fontSize(16)
              .textAlign(TextAlign.End)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(55)
          .padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })

          // --- 年龄输入 ---
          Row() {
            Text('年龄')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ placeholder: '请输入年龄', text: (this.currentUser.age ?? 0).toString() })
              .type(InputType.Number)
              .onChange((value) => { this.currentUser.age = Number(value) || 0; })
              .layoutWeight(1)
              .fontSize(16)
              .textAlign(TextAlign.End)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(55)
          .padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })

          // --- 地址输入 ---
          Row() {
            Text('地址')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            TextInput({ placeholder: '请输入地址', text: this.currentUser.address ?? '' })
              .type(InputType.Normal)
              .onChange((value) => { this.currentUser.address = value; })
              .layoutWeight(1)
              .fontSize(16)
              .textAlign(TextAlign.End)
              .backgroundColor(Color.Transparent)
          }
          .width('100%')
          .height(55)
          .padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })


          // --- 性别选择 ---
          Row() {
            Text('性别')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            Row({ space: 20 }) {
              Radio({ value: 'male', group: 'gender' }).checked(this.currentUser.gender === 0)
                .onChange((isChecked: boolean) => { if (isChecked) this.currentUser.gender = 0 })
              Text("男").fontSize(16)

              Radio({ value: 'female', group: 'gender' }).checked(this.currentUser.gender === 1)
                .onChange((isChecked: boolean) => { if (isChecked) this.currentUser.gender = 1 })
              Text("女").fontSize(16)
            }
            .justifyContent(FlexAlign.End).layoutWeight(1)
          }
          .width('100%').height(55).padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })

          // --- 身份选择 ---
          Row() {
            Text('身份')
              .width('25%')
              .fontSize(16)
              .fontColor($r('app.color.font_sub'))
            Row({ space: 20 }) {
              Radio({ value: 'patient', group: 'role' }).checked(this.currentUser.role === 'patient')
                .onChange((isChecked: boolean) => { if (isChecked) this.currentUser.role = 'patient' })
              Text("患者").fontSize(16)

              Radio({ value: 'doctor', group: 'role' }).checked(this.currentUser.role === 'doctor')
                .onChange((isChecked: boolean) => { if (isChecked) this.currentUser.role = 'doctor' })
              Text("医生").fontSize(16)
            }
            .justifyContent(FlexAlign.End).layoutWeight(1)
          }
          .width('100%').height(55).padding({ left: 15, right: 15 })
          Divider().strokeWidth(0.5).color('#e8e8e8').margin({ left: 15 })

        }
        .width('100%').backgroundColor(Color.White).borderRadius(15)
      }
      .layoutWeight(1).padding({ left: 10, right: 10 })

      // --- 底部按钮 ---
      Row({ space: 20 }) {
        Button('保存提交').type(ButtonType.Capsule).width('40%').height(45).fontSize(18)
          .backgroundColor('#007DFF')
          .onClick(() => this.submitUpdate())

        Button('取消').type(ButtonType.Capsule).width('40%').height(45).fontSize(18)
          .backgroundColor('#F1F3F5').fontColor(Color.Black)
          .onClick(() => { this.routerInstance?.back(); })
      }
      .width('100%').justifyContent(FlexAlign.Center).margin({ top: 20, bottom: 30 })

    }
    .width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}

