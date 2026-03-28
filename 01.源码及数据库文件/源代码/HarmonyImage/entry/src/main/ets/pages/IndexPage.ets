import router from '@ohos.router';
import { BusinessError } from '@ohos.base';

@Entry
@Component
struct IndexPage {

  /**
   * aboutToAppear 是页面即将显示时的生命周期回调。
   * 我们在这里设置一个定时器，2秒后自动跳转到登录页。
   */
  aboutToAppear() {
    setTimeout(() => {
      // 检查AppStorage中是否已存储token
      const token = AppStorage.get<string>('token')
      if (token) {
        // 如果token存在，说明用户已登录，跳转到主页
        router.replaceUrl({
          url: 'pages/MainPage'
        }, (err: BusinessError) => {
          if (err) {
            console.error(`Failed to replace url to MainPage. Code is ${err.code}, message is ${err.message}`);
          }
        });
      } else {
        // 如果token不存在，说明用户未登录，跳转到登录页
        router.replaceUrl({
          url: 'pages/LoginPage'
        }, (err: BusinessError) => {
          if (err) {
            console.error(`Failed to replace url to LoginPage. Code is ${err.code}, message is ${err.message}`);
          }
        });
      }
    }, 2000); // 2000毫秒 = 2秒
  }

  build() {
    Column() {
      // 应用图标/Logo
      Image($r('app.media.logo'))
        .width(120)
        .height(120)
        .margin({ bottom: 20 })

      // 应用标题
      Text('智慧医疗影像系统')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')

      // Loading 指示器，给用户反馈应用正在加载
      LoadingProgress()
        .width(40)
        .margin({ top: 40 })
        .color('#0D9FFB')

    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center) // 垂直居中对齐
    .backgroundColor('#F7F8FA') // 设置一个柔和的背景色
  }
}