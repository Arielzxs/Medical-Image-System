import { searchImages} from '../apis/ImageApi';
import { Image } from '../viewmodel/ImageModel';
import {ImageSearchParams} from  '../params/request/ImageSearchParams'
@Entry
@Component
struct ImageSearchPage {
  // 搜索表单的@State变量
  @State patientName: string = '';
  @State patientIdCard: string = '';
  @State modality: string = '';
  @State tags: string = '';
  @State startDate: Date = new Date();
  @State endDate: Date = new Date();

  // 用于控制日期选择器是否启用的状态变量
  @State isStartDateEnabled: boolean = false;
  @State isEndDateEnabled: boolean = false;

  // 存储搜索结果的@State变量
  @State imageList: Image[] = [];
  @State isLoading: boolean = false;
  @State searchMessage: string = '请输入条件进行搜索';

  // 执行搜索的方法
  async performSearch() {
    this.isLoading = true;
    this.searchMessage = '';

    // 动态构建搜索参数
    const params: ImageSearchParams = {
      patientName: this.patientName,
      patientIdCard: this.patientIdCard,
      modality: this.modality,
      tags: this.tags
    };

    // 只有当用户启用了日期选择，才将日期参数添加到请求中
    if (this.isStartDateEnabled) {
      params.startDate = this.startDate.toISOString();
    }
    if (this.isEndDateEnabled) {
      params.endDate = this.endDate.toISOString();
    }
    console.log(JSON.stringify(params))
    const results = await searchImages(params);
    this.imageList = results;

    if (results.length === 0) {
      this.searchMessage = '未找到符合条件的影像';
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 页面标题
      Text('影像查询')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      // 搜索表单
      Column() {
        TextInput({ placeholder: '患者姓名' }).onChange((value) => {
          this.patientName = value;
        }).margin({ bottom: 5 })

        TextInput({ placeholder: '患者身份证' }).onChange((value) => {
          this.patientIdCard = value;
        }).margin({ bottom: 5 })

        TextInput({ placeholder: '影像类型 (e.g., CT)' }).onChange((value) => {
          this.modality = value;
        }).margin({ bottom: 5 })

        TextInput({ placeholder: '影像标签 (e.g., 头部)' }).onChange((value) => {
          this.tags = value;
        }).margin({ bottom: 5 })

        // 日期选择
        // 开始日期
        Row({ space: 10 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.isStartDateEnabled })
            .onChange((isOn) => { this.isStartDateEnabled = isOn; })
          Text('开始日期').fontColor(this.isStartDateEnabled ? Color.Black : Color.Gray)
          if (this.isStartDateEnabled) {
            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2099-12-31'),
              selected: this.startDate
            })
              .onChange((date) => {
                const now = new Date();
                this.startDate = new Date(
                  date.year ?? now.getFullYear(),
                  date.month ?? now.getMonth(),
                  date.day ?? now.getDate()
                );
              })
          }
        }.width('100%').justifyContent(FlexAlign.Start).margin({bottom: 5})

        // 结束日期
        Row({ space: 10 }) {
          Toggle({ type: ToggleType.Switch, isOn: this.isEndDateEnabled })
            .onChange((isOn) => { this.isEndDateEnabled = isOn; })
          Text('结束日期').fontColor(this.isEndDateEnabled ? Color.Black : Color.Gray)
          if (this.isEndDateEnabled) {
            DatePicker({
              start: new Date('2020-01-01'),
              end: new Date('2099-12-31'),
              selected: this.endDate
            })
              .onChange((date) => {
                const now = new Date();
                this.endDate = new Date(
                  date.year ?? now.getFullYear(),
                  date.month ?? now.getMonth(),
                  date.day ?? now.getDate()
                );
              })
          }
        }.width('100%').justifyContent(FlexAlign.Start).margin({ bottom: 10 })

        Button('查询')
          .onClick(() => {
            this.performSearch();
          })
          .width('80%')
          .margin({ bottom: 20 })
      }
      .width('90%')
      .padding(15)
      .backgroundColor(Color.White)
      .borderRadius(10)
      .shadow({ radius: 5, color: '#f0f0f0' })


      // 结果列表
      List({ space: 10 }) {
        ForEach(
          this.imageList,
          (item: Image) => {
            ListItem() {
              this.ImageRow(item)
            }
          },
          (item: Image) => (item.id ?? item.filePath).toString()
        )
      }
      .divider({ strokeWidth: 1, color: '#f0f0f0' })
      .layoutWeight(1) // 占据剩余空间
      .width('90%')

      // 加载中或无结果提示
      if (this.isLoading) {
        Text('正在加载中...')
          .fontSize(16)
          .margin(20)
      } else if (this.imageList.length === 0) {
        Text(this.searchMessage)
          .fontSize(16)
          .fontColor(Color.Gray)
          .margin(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  // 单个影像的显示组件
  @Builder ImageRow(image: Image) {
    Row() {
      Image("http://172.20.10.5:8081" + image.filePath) // 请确保IP地址正确
        .width(80)
        .height(80)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
        .margin({ right: 15 })
      Column() {
        Text(`患者: ${image.patientName || 'N/A'}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Text(`类型: ${image.modality || 'N/A'}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`上传者: ${image.uploadedName || 'N/A'}`)
          .fontSize(14)
          .fontColor(Color.Gray)
        Text(`时间: ${image.uploadedAt ? new Date(image.uploadedAt).toLocaleString() : 'N/A'}`)
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding(10)
    .width('100%')
  }
}