import UserApi from '../apis/UserApi'
import { RegisterParam } from '../params/request/UserRequestParam'
import promptAction from '@ohos.promptAction';
import router from '@ohos.router';

// 定义 DatePicker 返回值的结构
interface DatePickerValue {
  year: number;
  month: number;
  day: number;
}

@Entry
@Component
struct RegisterPage {
  @State registerForm: RegisterParam = {
    username: '',
    idCard: '',
    age: 0,
    gender: 0,
    phone: '',
    birthDate: '',
    address: '',
    password: '',
    role: 'patient'
  };
  @State confirmPassword: string = '';

  /**
   * 处理注册逻辑
   */
  async handleRegister() {
    // 表单验证
    if (!this.registerForm.username || !this.registerForm.idCard || !this.registerForm.phone || !this.registerForm.password) {
      promptAction.showToast({ message: '请填写所有必填项' });
      return;
    }
    if (this.registerForm.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }

    try {
      await UserApi.register(this.registerForm);
      promptAction.showToast({ message: '注册成功，请登录' });
      router.back(); // 注册成功后返回登录页面
    } catch (error) {
      console.error('注册失败:', JSON.stringify(error));
    }
  }

  build() {
    Column() {
      // 页面标题和返回按钮
      Row() {
        Image($r('app.media.logo'))
          .width(30)
          .height(30)
          .onClick(() => router.back())
        Text("新用户注册")
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .margin({ right: 30 }) // 平衡返回按钮的占位
      }
      .width('100%')
      .padding({ top: 20, bottom: 20 })

      // 注册表单
      Scroll() {
        Column() {
          Column({ space: 15 }) {
            // 用户名
            Row() {
              Text('用户名').width('25%')
              TextInput({ placeholder: '请输入用户名' })
                .onChange((val) => this.registerForm.username = val)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 身份证号
            Row() {
              Text('身份证号').width('25%')
              TextInput({ placeholder: '请输入身份证号' })
                .onChange((val) => this.registerForm.idCard = val)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 密码
            Row() {
              Text('密码').width('25%')
              TextInput({ placeholder: '请输入密码' })
                .type(InputType.Password)
                .onChange((val) => this.registerForm.password = val)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 确认密码
            Row() {
              Text('确认密码').width('25%')
              TextInput({ placeholder: '请再次输入密码' })
                .type(InputType.Password)
                .onChange((val) => this.confirmPassword = val)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 手机号
            Row() {
              Text('手机号').width('25%')
              TextInput({ placeholder: '请输入手机号' })
                .type(InputType.PhoneNumber)
                .onChange((val) => this.registerForm.phone = val)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 年龄
            Row() {
              Text('年龄').width('25%')
              TextInput({ placeholder: '请输入年龄' })
                .type(InputType.Number)
                .onChange((val) => this.registerForm.age = parseInt(val) || 0)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 地址
            Row() {
              Text('地址').width('25%')
              TextInput({ placeholder: '请输入地址' })
                .onChange((val) => this.registerForm.address = val)
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)

            // 性别
            Row() {
              Text("性别").width('25%')
              Row({ space: 20 }) {
                Radio({ value: "0", group: "gender" })
                  .checked(this.registerForm.gender === 0)
                  .onChange((isChecked: boolean) => { if (isChecked) this.registerForm.gender = 0 })
                Text("男")
                Radio({ value: "1", group: "gender" })
                  .checked(this.registerForm.gender === 1)
                  .onChange((isChecked: boolean) => { if (isChecked) this.registerForm.gender = 1 })
                Text("女")
              }
            }.width('100%')

            // 出生日期
            Row() {
              Text('出生日期').width('25%')
              DatePicker({ start: new Date('1920-01-01'), end: new Date() })
                .onChange((value: DatePickerValue) => {
                  this.registerForm.birthDate = `${value.year}-${(value.month + 1).toString().padStart(2, '0')}-${value.day.toString().padStart(2, '0')}`;
                })
            }.width('100%').justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')

          // 注册按钮
          Button('注 册', { type: ButtonType.Capsule, stateEffect: true })
            .width('100%')
            .height(45)
            .fontSize(18)
            .margin({ top: 30 })
            .onClick(() => this.handleRegister())
        }
        .padding({ bottom: 20 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .backgroundColor($r('app.color.background_background'))
  }
}
