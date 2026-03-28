import router from '@ohos.router';
import { User } from '../viewmodel/UserModel';

@Component
export struct PatientMainPage {
  @StorageLink('currentUser') loginUser: User = { id: 0, username: '' };

  private swiperImages: Resource[] = [
    $r("app.media.swiper_1"),
    $r("app.media.swiper_2"),
    $r("app.media.swiper_3")
  ];

  // 可复用的功能卡片构建器
  @Builder
  FeatureCard(icon: Resource, title: string, description: string, onClick: () => void) {
    Column() {
      Image(icon)
        .width(48)
        .height(48)
        .margin({ bottom: 10 })
        .fillColor($r('app.color.brand')) // 让图标颜色统一

      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 5 })

      Text(description)
        .fontSize(12)
        .fontColor(Color.Gray)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(140)
    .padding(15)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({ radius: 6, color: '#1F000000', offsetX: 2, offsetY: 4 })
    .onClick(onClick)
  }

  build() {
    Column() {
      // 顶部欢迎栏
      Row() {
        Column({ space: 5 }) {
          Text('欢迎回来,')
            .fontSize(18)
            .fontColor(Color.Gray)
          Text(this.loginUser.username)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Image($r("app.media.logo")) // 您的头像或应用Logo
          .width(50)
          .height(50)
          .borderRadius(25)
          .onClick(() => {
            router.pushUrl({ url: 'pages/ProfileManagementPage' })
          })
      }
      .width('100%')
      .padding({ top: 30, bottom: 20 })

      TextInput({
        placeholder: '搜索功能...',
        controller: new TextInputController()
      }).height(50)
        .backgroundColor(Color.White)
        .borderRadius(25)
        .padding({ left: 20, right: 20 })
        .margin({ bottom: 20 })
        .shadow({ radius: 6, color: '#1F000000', offsetX: 2, offsetY: 2 })
      // 轮播图
      Swiper() {
        ForEach(this.swiperImages, (item: Resource) => {
          Image(item)
            .width('100%')
            .height('100%')
            .borderRadius(15)
            .objectFit(ImageFit.Fill) // 图片填充方式
        })
      }
      .autoPlay(true)
      .interval(3000) // 播放间隔
      .indicator(true) // 显示指示点
      .loop(true) // 循环播放
      .height(150)
      .borderRadius(15)
      .margin({ bottom: 20 })
      .shadow({ radius: 8, color: '#2F000000', offsetX: 2, offsetY: 4 })


      // 功能区网格布局
      GridRow({
        columns: 2,
        gutter: { x: 15, y: 15 }
      }) {
        GridCol() {
          this.FeatureCard($r("app.media.icon_add_appointment"), '新建预约', '快速创建新的检查预约', () => {
            router.pushUrl({ url: 'pages/CreateAppointmentPage' });
          })
        }
        GridCol() {
          this.FeatureCard($r("app.media.icon_appointment"), '我的预约', '查看和管理您的预约', () => {
            router.pushUrl({ url: 'pages/MyAppointmentsPage' });
          })
        }
        GridCol() {
          this.FeatureCard($r("app.media.icon_image"), '我的影像', '浏览您所有的医疗影像', () => {
            router.pushUrl({ url: 'pages/MyImagesPage' });
          })
        }
        GridCol() {
          this.FeatureCard($r("app.media.icon_report"), '我的报告', '查看您的诊断报告', () => {
            router.pushUrl({ url: 'pages/MyReportsPage' });
          })
        }
      }
      .width('100%')

      Column().layoutWeight(1)
    }
    .padding({ left: 20, right: 20 })
    .width('100%')
    .height('100%')
    .backgroundColor('#F7F8FA')
  }
}